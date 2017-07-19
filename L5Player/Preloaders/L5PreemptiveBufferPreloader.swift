//
//  L5BufferPreloader.swift
//  L5Player
//
//  Created by Sergio Daniel Lozano on 7/19/17.
//  Copyright © 2017 Li5. All rights reserved.
//

import Foundation


protocol L5PreemptiveBufferPreloaderProtocol : L5BufferPreloaderProtocol {
    
}


class L5PreemptiveBufferPreloader : L5PreemptiveBufferPreloaderProtocol {
    
    // MARK: - CLASS PROPERTIES
    
    static var propertiesToPreload = ["playable",
                                      "tracks",
                                      "duration",
                                      "hasProtectedContent"]
    
    // MARK: - STORED PROPERTIES
    
    var delegate: L5PreloaderDelegate
    
    // MARK: - INITIALIZERS
    
    init(delegate: L5PreloaderDelegate) {
        self.delegate = delegate
    }
    
    // MARK: - EXPOSED OPERATIONS
    
    func preload(asset: L5Asset, completion: @escaping PreloadCompletion) {
        asset.bufferStatus = .buffering
        
        asset.media?.loadValuesAsynchronously(forKeys: L5PreemptiveBufferPreloader.propertiesToPreload) {
            [weak self] in
            
            asset.bufferStatus = .buffered
            
            self?.delegate.didFinishPreloading(asset: asset)
            completion(asset, nil)
        }
    }
    
}
