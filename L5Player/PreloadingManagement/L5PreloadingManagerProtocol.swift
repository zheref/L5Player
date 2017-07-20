//
//  L5PreloadingManagerProtocol.swift
//  L5Player
//
//  Created by Sergio Daniel on 7/19/17.
//  Copyright © 2017 Li5. All rights reserved.
//

import Foundation


public protocol L5PreloadingManagerProtocol {
    
    init(assets: [L5Asset],
         bufferer: L5BufferPreloaderProtocol?,
         downloader: L5DownloadPreloaderProtocol?)
    
    var delegate: L5PreloadingManagerDelegate? { get set }
    
    func setup(bufferer: L5BufferPreloaderProtocol?, downloader: L5DownloadPreloaderProtocol?)
    
    func startPreloading()
    
    func preload(index: Int)
    
}


public protocol L5PreloadingManagerDelegate {
    
    var playingIndex: Int { get }
    
    func requiredAssetIsBuffering(_ asset: L5Asset)
    
    func requiredAssetIsReady(_ asset: L5Asset)
    
    func requiredAssetIsDownloaded(_ asset: L5Asset)
    
    func managerDidFinishBufferingMinimumRequiredAssets()
    
    func managerDidFinishDownloadingRequiredAssets()
    
}
