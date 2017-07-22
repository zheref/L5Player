//
//  ShowViewController.swift
//  L5Player
//
//  Created by Sergio Daniel on 7/20/17.
//  Copyright © 2017 Li5. All rights reserved.
//

import UIKit
import AVFoundation
import L5Player


private var playerViewControllerKVOContext = 0

class ShowViewController: UIViewController {
    
    // MARK: - PROPERTIES
    
    // MARK: Outlets
    
    @IBOutlet weak var playerView: L5PlayerView!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    // MARK: Stored Properties
    
    /// The player responsible of the media playback
    var player: L5PlayerProtocol!
    
    var originalPlayer: AVPlayer!
    
    /// The asset models which URLs should be played
    var assets = [L5Asset]()
    
    /// The assets corresponding the trailers of each product to be eventually played
    var manager: L5PreloadingManagerProtocol!
    
    var bufferer: L5BufferPreloaderProtocol!
    
    var downloader: L5DownloadPreloaderProtocol?
    
    // MARK: Computed Properties
    
    var playerLayer: AVPlayerLayer? {
        return playerView.playerLayer
    }
    
    var currentAsset: L5Asset? {
        if player.currentIndex >= 0 && player.currentIndex < assets.count {
            return assets[player.currentIndex]
        } else {
            return nil
        }
    }
    
    // MARK: - INSTANCE OPERATIONS
    
    // MARK: Exposed Operations
    
    internal func setup(player: L5PlayerProtocol,
                        manager: L5PreloadingManagerProtocol,
                        bufferer: L5BufferPreloaderProtocol,
                        downloader: L5DownloadPreloaderProtocol) {
        
        self.player = player
        
        self.originalPlayer = player.originalPlayer
        
        self.manager = manager
        self.bufferer = bufferer
        self.downloader = downloader
    }
    
    // MARK: LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addObserver(self, forKeyPath: #keyPath(ShowViewController.originalPlayer.currentItem.status),
                    options: [.new, .initial], context: &playerViewControllerKVOContext)
        addObserver(self, forKeyPath: #keyPath(ShowViewController.originalPlayer.currentItem),
                    options: [.new, .initial], context: &playerViewControllerKVOContext)
        
        self.showLoadingScreen()
        
        playerView.playerLayer.player = originalPlayer
        
        manager.delegate = self
        
        manager.startPreloading()
        
        self.setupPoster()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        player.pause()
        
        removeObserver(self, forKeyPath: #keyPath(ShowViewController.originalPlayer.currentItem.status),
                       context: &playerViewControllerKVOContext)
        
        removeObserver(self, forKeyPath: #keyPath(ShowViewController.originalPlayer.currentItem),
                       context: &playerViewControllerKVOContext)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        player.play()
        player.automaticallyReplay = true
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: KVO Observation
    
    // Update our UI when player or `player.currentItem` changes.
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // Make sure the this KVO callback was intended for this view controller.
        guard context == &playerViewControllerKVOContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        if keyPath == #keyPath(ShowViewController.originalPlayer.currentItem) {
            //queueDidChangeWithOldPlayerItems(oldPlayerItems: [], newPlayerItems: player.items())
        } else if keyPath ==  #keyPath(ShowViewController.originalPlayer.currentItem.status) {
            // Display an error if status becomes `.Failed`.
            
            /*
             Handle `NSNull` value for `NSKeyValueChangeNewKey`, i.e. when
             `player.currentItem` is nil.
             */
            let newStatus: AVPlayerItemStatus
            
            if let newStatusAsNumber = change?[NSKeyValueChangeKey.newKey] as? NSNumber {
                newStatus = AVPlayerItemStatus(rawValue: newStatusAsNumber.intValue)!
                
                if newStatus == .readyToPlay {
                    player.goToZero()
                    player.play()
                }
            }
            else {
                newStatus = .unknown
            }
            
            if newStatus == .failed {
                handleError(with: player.currentItem?.error?.localizedDescription, error: player.currentItem?.error)
            }
        }
    }
    
    /// Shows poster image if available in the product model and is a valid base 64 image
    fileprivate func setupPoster() {
        guard let currentAsset = currentAsset else {
            log.error("Current assets is nil: \(player.currentIndex)")
            return
        }
        
        if let poster = currentAsset.poster {
            posterImageView.image = UIImage(data: poster)
        }
    }
    
    /// Change elements to display loading screen. Specially designed for giving time for loading assets
    private func showLoadingScreen() {
        leftButton.isUserInteractionEnabled = false
        rightButton.isUserInteractionEnabled = false
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    /// Change elements to hide loading screen. Should be run when assets are ready to play smoothly
    fileprivate func hideLoadingScreen() {
        leftButton.isUserInteractionEnabled = true
        rightButton.isUserInteractionEnabled = true
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    fileprivate func enqueue(asset: L5Asset) {
        if let originalAsset = asset.media {
            let playerItem = AVPlayerItem(asset: originalAsset)
            player.insert(playerItem, after: nil)
        } else {
            log.error("Asset not enqued because media is not available: \(asset.id)")
        }
    }
    
    // MARK: Error Handling
    
    func handleError(with message: String?, error: Error? = nil) {
        log.error("Error occurred with message: \(message), error: \(error).")
        
        let alertTitle = NSLocalizedString("alert.error.title", comment: "Alert title for errors")
        
        let alertMessage = message ?? NSLocalizedString("error.default.description", comment: "Default error message when no NSError provided")
        
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        
        let alertActionTitle = NSLocalizedString("alert.error.actions.OK", comment: "OK on error alert")
        let alertAction = UIAlertAction(title: alertActionTitle, style: .default, handler: nil)
        
        alert.addAction(alertAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: Actions
    
    @IBAction func userDidTapLeftActiveSection(_ sender: Any) {
        player.goPrevious()
    }
    
    @IBAction func userDidTapRightActiveSection(_ sender: Any) {
        player.goNext()
    }
    
    
}

extension ShowViewController : L5PreloadingManagerDelegate {
    
    var playingIndex: Int {
        return player.currentIndex
    }
    
    func requiredAssetIsBuffering(_ asset: L5Asset) {
        log.debug("Enqueuing buffering asset(\(asset.id))")
        enqueue(asset: asset)
    }
    
    func requiredAssetIsReady(_ asset: L5Asset) {
        log.debug("Finished buffering asset(\(asset.id))")
    }
    
    func requiredAssetIsDownloaded(_ asset: L5Asset) {
        log.debug("Finished downloading asset(\(asset.id))")
    }
    
    func managerDidFinishBufferingMinimumRequiredAssets() {
        DispatchQueue.main.async { [unowned self] in
            log.debug("Finished buffering minimum required assets!!!")
            self.hideLoadingScreen()
            self.player.play()
        }
    }
    
    func managerDidFinishDownloadingRequiredAssets() {
        log.verbose("Finished downloading")
    }
}
