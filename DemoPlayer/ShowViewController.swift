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

class ShowViewController: UIViewController, L5MultiPlayerDelegate {
    
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
    
    /// The assets corresponding the trailers of each product to be eventually played
    var manager: L5PreloadingManagerProtocol!
    
    var bufferer: L5BufferPreloaderProtocol!
    
    var downloader: L5DownloadPreloaderProtocol?

    var didStartPlayback = false
    
    // MARK: Computed Properties
    
    var playerLayer: AVPlayerLayer? {
        return playerView.playerLayer
    }
    
    // MARK: - INSTANCE OPERATIONS
    
    // MARK: Exposed Operations
    
    internal func setup(player: L5PlayerProtocol,
                        manager: L5PreloadingManagerProtocol,
                        bufferer: L5BufferPreloaderProtocol,
                        downloader: L5DownloadPreloaderProtocol?) {
        
        self.player = player
        
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

        if let multiPlayer = player as? L5MultiPlayer {
            multiPlayer.delegate = self
        }
        
        player.settle()

        if let currentPlayer = player.currentPlayer {
            playerView.playerLayer.player = currentPlayer
        }
        
        manager.delegate = self
        
        manager.startPreloading()
        
        self.showLoadingScreen()
        
        self.setupPoster()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        player.pause()
        
        player.loosen()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        player.play()
        player.automaticallyReplay = true
    }

    func didChange(player: AVPlayer?) {
        playerView.playerLayer.player = player
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// Shows poster image if available in the product model and is a valid base 64 image
    fileprivate func setupPoster() {
        guard let currentAsset = manager.currentAsset else {
            log.error("Current assets is nil: \(player.currentIndex)")
            return
        }
        
        if let poster = currentAsset.poster {
            posterImageView.image = UIImage(data: poster)
        }
    }
    
    /// Change elements to display loading screen. Specially designed for giving time for loading assets
    internal func showLoadingScreen() {
        leftButton.isUserInteractionEnabled = false
        rightButton.isUserInteractionEnabled = false
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    /// Change elements to hide loading screen. Should be run when assets are ready to play smoothly
    internal func hideLoadingScreen() {
        leftButton.isUserInteractionEnabled = true
        rightButton.isUserInteractionEnabled = true
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
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
    func didPreload(_ asset: L5Asset) {
        if let currentAsset = self.manager?.currentAsset, currentAsset === asset, didStartPlayback {
            DispatchQueue.main.async { [unowned self] in
                self.hideLoadingScreen()
                self.player.play()
            }
        }
    }

    
    func managerIsReadyForPlayback() {
        didStartPlayback = true
        DispatchQueue.main.async { [unowned self] in
            log.debug("Finished buffering minimum required assets!!!")
            self.hideLoadingScreen()
            self.player.play()
        }
    }
    
    var playingIndex: Int {
        return player.currentIndex
    }
    
}
