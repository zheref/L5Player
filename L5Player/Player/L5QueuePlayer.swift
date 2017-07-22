//
//  L5QueuePlayer.swift
//  L5Player
//
//  Created by Sergio Daniel on 7/20/17.
//  Copyright © 2017 Li5. All rights reserved.
//

import Foundation
import AVFoundation

/// Context for recognizing context where the observer is been invoked from
private var queuePlayerViewKVOContext = 0

public protocol L5QueuePlayerProtocol : L5PlayerProtocol {
    
}


public class L5QueuePlayer : AVQueuePlayer, L5QueuePlayerProtocol {
    
    // MARK: - STORED PROPERTIES
    
    /// Backup array of the items enqueued to be played
    var enqueuedItems = [AVPlayerItem]()
    
    /// The object observing when the playback of the current item ends
    private var endPlayObserver: NSObjectProtocol?
    
    /// The instance to the original AVPlayer
    public var originalPlayer: AVPlayer { return self }
    
    /// The index of the item currently being played
    public var currentIndex: Int = 0
    
    /// Whether the current item should be played all over again once it ends
    public var automaticallyReplay: Bool = false {
        didSet {
            if automaticallyReplay {
                actionAtItemEnd = .none
                
                if endPlayObserver != nil {
                    NotificationCenter.default.removeObserver(endPlayObserver!)
                    endPlayObserver = nil
                }
                
                endPlayObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                                                         object: currentItem,
                                                                         queue: nil)
                { [weak self] _ in
                    DispatchQueue.main.async { [weak self] in
                        self?.goToZero()
                    }
                }
            }
        }
    }
    
    
    public func goToZero() {
        self.seek(to: kCMTimeZero)
        self.currentItem?.seek(to: kCMTimeZero)
    }
    
    
    public func clearItems() {
        self.removeAllItems()
    }
    
    
    public func goNext() {
        if currentIndex == enqueuedItems.count - 1 {
            log.error("Trying to go to next player item when there are no more enqueued")
        } else {
            currentIndex += 1
            pause()
            advanceToNextItem()
            automaticallyReplay = true
        }
    }
    
    
    public func goPrevious() {
        if currentIndex == 0 {
            log.error("Trying to go to previous player item when the cursor is on zero position")
        } else {
            currentIndex -= 1
            
            clearItems()
            
            for index in currentIndex...enqueuedItems.count-1 {
                let item = enqueuedItems[index]
                
                if canInsert(item, after: nil) {
                    pause()
                    currentItem?.seek(to: kCMTimeZero)
                    goToZero()
                    insert(item, after: nil)
                } else {
                    log.warning("Wasn't able to insert av player item while refreshign for specific play")
                }
            }
            
            if status == .readyToPlay {
                play()
                automaticallyReplay = true
            } else {
                log.warning("Tried to play but not ready yet for index: \(currentIndex)")
            }
        }
    }
    
    
    public override func insert(_ item: AVPlayerItem, after afterItem: AVPlayerItem?) {
        enqueuedItems.append(item)
        super.insert(item, after: afterItem)
    }
    
    
    public func settle() {
        addObserver(self, forKeyPath: #keyPath(currentItem.status),
                    options: [.new, .initial], context: &queuePlayerViewKVOContext)
        addObserver(self, forKeyPath: #keyPath(currentItem),
                    options: [.new, .initial], context: &queuePlayerViewKVOContext)
    }
    
    
    public func loosen() {
        removeObserver(self, forKeyPath: #keyPath(currentItem.status),
                       context: &queuePlayerViewKVOContext)
        
        removeObserver(self, forKeyPath: #keyPath(currentItem),
                       context: &queuePlayerViewKVOContext)
    }
    
    
    // MARK: KVO Observation
    
    // Update our UI when player or `player.currentItem` changes.
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // Make sure the this KVO callback was intended for this view controller.
        guard context == &queuePlayerViewKVOContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        if keyPath == #keyPath(currentItem) {
            //queueDidChangeWithOldPlayerItems(oldPlayerItems: [], newPlayerItems: player.items())
        } else if keyPath ==  #keyPath(currentItem.status) {
            // Display an error if status becomes `.Failed`.
            
            /*
             Handle `NSNull` value for `NSKeyValueChangeNewKey`, i.e. when
             `player.currentItem` is nil.
             */
            let newStatus: AVPlayerItemStatus
            
            if let newStatusAsNumber = change?[NSKeyValueChangeKey.newKey] as? NSNumber {
                newStatus = AVPlayerItemStatus(rawValue: newStatusAsNumber.intValue)!
                
                if newStatus == .readyToPlay {
                    goToZero()
                    play()
                }
            }
            else {
                newStatus = .unknown
            }
            
            if newStatus == .failed {
                handleError(with: currentItem?.error?.localizedDescription, error: currentItem?.error)
            }
        }
    }
    
    
    private func handleError(with str: String?, error: Error?) {
        log.error(str ?? error?.localizedDescription ?? "Unknown error")
    }
    
}
