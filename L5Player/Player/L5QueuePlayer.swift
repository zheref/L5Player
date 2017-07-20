//
//  L5QueuePlayer.swift
//  L5Player
//
//  Created by Sergio Daniel on 7/20/17.
//  Copyright © 2017 Li5. All rights reserved.
//

import Foundation
import AVFoundation

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
    
}
