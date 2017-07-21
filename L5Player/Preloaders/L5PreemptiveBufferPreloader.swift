//
//  L5BufferPreloader.swift
//  L5Player
//
//  Created by Sergio Daniel Lozano on 7/19/17.
//  Copyright © 2017 Li5. All rights reserved.
//

import Foundation


public protocol L5PreemptiveBufferPreloaderProtocol : L5BufferPreloaderProtocol {
    
}


public class L5PreemptiveBufferPreloader : L5PreemptiveBufferPreloaderProtocol {
    
    // MARK: - CLASS PROPERTIES
    
    private static var propertiesToPreload = ["playable",
                                              "tracks",
                                              "duration",
                                              "hasProtectedContent"]
    
    // MARK: - STORED PROPERTIES
    
    public var delegate: L5PreloaderDelegate
    
    // MARK: - INITIALIZERS
    
    public init(delegate: L5PreloaderDelegate) {
        self.delegate = delegate
    }
    
    // MARK: - EXPOSED OPERATIONS
    
    public func preload(asset: L5Asset, completion: @escaping PreloadCompletion) {
        asset.bufferStatus = .buffering
        
        asset.media?.loadValuesAsynchronously(forKeys: L5PreemptiveBufferPreloader.propertiesToPreload) {
            [weak self] in
            
            asset.bufferStatus = .buffered
            
            self?.delegate.didFinishPreloading(asset: asset)
            completion(asset, nil)
        }
    }
    
}
