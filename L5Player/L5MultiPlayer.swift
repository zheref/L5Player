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

public protocol L5MultiPlayerProtocol : L5PlayerProtocol {
    var currentPlayer: AVPlayer? { get }

    func append(asset: L5Asset)
}


public class L5MultiPlayer: NSObject, L5MultiPlayerProtocol {

    // MARK: - STORED PROPERTIES

    /// Backup array of the items enqueued to be played
    var enqueuedItems = [L5Asset]()

    /// The object observing when the playback of the current item ends
    private var endPlayObserver: NSObjectProtocol?

    public var currentPlayer: AVPlayer? { return currentAsset?.player }

    /// The instance to the original AVPlayer
    public var originalPlayer: AVPlayer { return currentAsset!.player! }

    /// The index of the item currently being played
    public var currentIndex: Int = 0

    internal var currentAsset: L5Asset? {
        if enqueuedItems.count > currentIndex {
            return enqueuedItems[currentIndex]
        }

        return nil
    }

    public var currentItem: AVPlayerItem? {
        if enqueuedItems.count > currentIndex {
            return enqueuedItems[currentIndex].playerItem
        }

        return nil
    }

    public func append(asset: L5Asset) {
        enqueuedItems.append(asset)
    }

    /// Whether the current item should be played all over again once it ends
    public var automaticallyReplay: Bool = false {
        didSet {
//            if automaticallyReplay {
//                actionAtItemEnd = .none
//
//                if endPlayObserver != nil {
//                    NotificationCenter.default.removeObserver(endPlayObserver!)
//                    endPlayObserver = nil
//                }
//
//                endPlayObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
//                                                                         object: currentItem,
//                                                                         queue: nil)
//                { [weak self] _ in
//                    DispatchQueue.main.async { [weak self] in
//                        self?.goToZero()
//                    }
//                }
//            }
        }
    }


    private func goToZero() {
//        self.seek(to: kCMTimeZero)
        self.currentItem?.seek(to: kCMTimeZero)
    }


    public func goNext() {
        if currentIndex == enqueuedItems.count - 1 {
            log.error("Trying to go to next player item when there are no more enqueued")
        } else {
            pause()
            currentIndex += 1
            currentItem?.seek(to: kCMTimeZero)
            play()
            automaticallyReplay = true
        }
    }

    public var status: AVPlayerStatus {
        if let currentPlayer = currentPlayer {
            return currentPlayer.status
        }

        return .unknown
    }

    public func goPrevious() {
        if currentIndex == 0 {
            log.error("Trying to go to previous player item when the cursor is on zero position")
        } else {
            pause()
            currentIndex -= 1

            currentItem?.seek(to: kCMTimeZero)
            if status == .readyToPlay {
                play()
                automaticallyReplay = true
            } else {
                log.warning("Tried to play but not ready yet for index: \(currentIndex)")
            }
        }
    }

    public func play() {
        currentPlayer?.play()
    }

    public func pause() {
        currentPlayer?.pause()
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
