//
//  L5PreloadingManagerProtocol.swift
//  L5Player
//
//  Created by Sergio Daniel on 7/19/17.
//  Copyright © 2017 Li5. All rights reserved.
//

import Foundation


protocol L5PreloadingManagerProtocol {
    
    init(assets: [L5Asset], delegate: L5PreloadingManagerDelegate,
         bufferer: L5BufferPreloaderProtocol?, downloader: L5DownloadPreloaderProtocol?)
    
    func setup(bufferer: L5BufferPreloaderProtocol?, downloader: L5DownloadPreloaderProtocol?)
    
    func startPreloading()
    
    func preload(index: Int)
    
}


protocol L5PreloadingManagerDelegate {
    
    var playingIndex: Int { get }
    
    func requiredAssetIsBuffering(_ asset: L5Asset)
    
    func requiredAssetIsReady(_ asset: L5Asset)
    
    func requiredAssetIsDownloaded(_ asset: L5Asset)
    
    func managerDidFinishBufferingMinimumRequiredAssets()
    
    func managerDidFinishDownloadingRequiredAssets()
    
}
