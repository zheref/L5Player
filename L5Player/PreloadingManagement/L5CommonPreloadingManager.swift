//
//  L5PreloadingManager.swift
//  L5Player
//
//  Created by Sergio Daniel Lozano on 7/19/17.
//  Copyright © 2017 Li5. All rights reserved.
//

import Foundation
import AVFoundation


protocol L5CommonPreloadingManagerProtocol : L5PreloadingManagerProtocol {
    
    
    
}


class L5CommonPreloadingManager {
    
    // MARK: - CLASS PROPERTIES
    
    fileprivate static var surroundBy = 1
    
    fileprivate static var minimumRequiredPreloadedAssets = 4
    
    // MARK: - STORED PROPERTIES
    
    /// The array where assets are stored along with its media, metadata and status
    private var assets = [L5Asset]()
    
    /// The responsible of handling the progress and completion of buffering and caching of assets
    private var delegate: L5PreloadingManagerDelegate?
    
    /// The instance responsible of buffering the video to play it
    private var bufferer: L5BufferPreloaderProtocol?
    
    /// The instance responsible of downloading into local storage to cache content
    private var downloader: L5DownloadPreloaderProtocol?
    
    // MARK: - INSTANCE OPERATIONS
    
    
    /// MARK: - Initializers
    
    /// Initializes a new L5PreloadingManager with the given assets, delegate, bufferer and downloader
    ///
    /// - Parameters:
    ///   - assets: The list of assets to be managed
    ///   - delegate: The responsible to answer for the different events during the assets management
    ///   - bufferer: The responsible to provide a mechanism to preemptively load videos by buffering
    ///   - downloader: The reponsible to provide a mechanism to cache videos by downloading
    init(assets: [L5Asset],
         delegate: L5PreloadingManagerDelegate,
         bufferer: L5BufferPreloaderProtocol? =  nil,
         downloader: L5DownloadPreloaderProtocol? = nil) {
        
        self.assets = assets
        self.delegate = delegate
        
        setup(bufferer: bufferer, downloader: downloader)
    }
    
    // MARK: Public Operations
    
    /// Sets up a new bufferer or downloader.
    /// This method should be used to switch between mechanisms.
    /// - Parameters:
    ///   - bufferer: The responsible to provide a mechanism to preemptively load videos by buffering
    ///   - downloader: The reponsible to provide a mechanism to cache videos by downloading
    func setup(bufferer: L5BufferPreloaderProtocol? = nil,
               downloader: L5DownloadPreloaderProtocol? = nil) {
        
        self.bufferer = bufferer
        self.downloader = downloader
    }
    
    /// Starts preloading videos by buffering and/or caching according to the configuration
    func startPreloading() {
        for i in 0...L5CommonPreloadingManager.surroundBy {
            preload(index: i)
        }
    }
    
    /// Returns an AVPlayerItem ready with the already downloaded or pending to download asset
    /// - Parameter index: Required index
    /// - Returns: AVPlayerItem with its corresponding asset attached
    func itemReady(forIndex index: Int) -> AVPlayerItem? {
        if let media = assets[index].media {
            return AVPlayerItem(asset: media)
        } else {
            return nil
        }
    }
    
    // MARK: Private Operations
    
    /// Preload the video corresponding to the given index by buffering and/or downloading
    /// according to the setup configuration.
    /// - Parameter index: The index to be preloaded
    func preload(index: Int) {
        let asset = assets[index]
        
        log.debug("Starting preloading: \(index) -> \(asset.url.absoluteURL)")
        
        bufferer?.preload(asset: asset) { [weak self] (asset, error) in
            guard let this = self else {
                log.warning("Lost reference of L5PreloadingManager.self")
                return
            }
            
            self?.delegate?.requiredAssetIsReady(asset)
            
            if let nextIndexToDownload = this.assets.index(where: { $0.bufferStatus == .notStarted }) {
                self?.preload(index: nextIndexToDownload)
            } else {
                log.verbose("No index found to continue buffering")
            }
            
            let alreadyBufferedAssets = this.assets.filter { $0.bufferStatus == .buffered }
            
            if this.isEnough(bufferedAssetsAmount: alreadyBufferedAssets.count) {
                
                self?.delegate?.managerDidFinishBufferingMinimumRequiredAssets()
            }
        }
        
        delegate?.requiredAssetIsBuffering(asset)
    }
    
    /// Determines whether the given amount of buffered assets is enough to satisfy the setup
    /// requirements or not.
    /// - Parameter bufferedAssetsAmount: The amount of already buffered assets
    /// - Returns: Whether it is enough to satisfy requirements or not
    private func isEnough(bufferedAssetsAmount: Int) -> Bool {
        return bufferedAssetsAmount > L5CommonPreloadingManager.minimumRequiredPreloadedAssets &&
            bufferedAssetsAmount < L5CommonPreloadingManager.minimumRequiredPreloadedAssets + 2
    }
    
}


extension L5CommonPreloadingManager : L5PreloaderDelegate {
    
    func didPreload(asset: L5Asset, by amount: Double) {
        
    }
    
    func didFinishPreloading(asset: L5Asset) {
        
    }
    
    func didFailPreloading(asset: L5Asset, withError error: Error) {
        
    }
    
}