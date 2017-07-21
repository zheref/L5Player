//
//  L5HLSionDownloadPreloader.swift
//  L5Player
//
//  Created by Sergio Daniel on 7/20/17.
//  Copyright © 2017 Li5. All rights reserved.
//

import Foundation
import HLSion


protocol L5HLSionDownloadPreloaderProtocol : L5DownloadPreloaderProtocol {
    
    
    
}


public class L5HLSionDownloadPreloader : L5HLSionDownloadPreloaderProtocol {
    
    // MARK: - STORED PROPERTIES
    
    public var delegate: L5PreloaderDelegate
    
    // MARK: - INITIALIZERS
    
    public init(delegate: L5PreloaderDelegate) {
        self.delegate = delegate
    }
    
    // MARK: - EXPOSED OPERATIONS
    
    public func preload(asset: L5Asset, completion: @escaping PreloadCompletion) {
        asset.downloadStatus = .downloading
        
        let hlsion = HLSion(url: asset.url, name: asset.id).download { [weak self] (progressPercentage) in
            self?.delegate.didPreload(asset: asset, by: progressPercentage)
        }
            
        hlsion.finish { [weak self] (relativePath) in
            asset.localUrl = URL(string: relativePath)
            asset.downloadStatus = .downloaded
            self?.delegate.didFinishPreloading(asset: asset)
            completion(asset, nil)
        }.onError { [weak self] (error) in
            asset.downloadStatus = .notStarted
            self?.delegate.didFailPreloading(asset: asset, withError: error)
            completion(asset, error)
        }
    }
    
}
