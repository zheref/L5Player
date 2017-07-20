//
//  L5PreloaderProtocol.swift
//  L5Player
//
//  Created by Sergio Daniel Lozano on 7/19/17.
//  Copyright © 2017 Li5. All rights reserved.
//

import Foundation

public typealias PreloadProgressClosure = (L5Asset, Double) -> Void
public typealias PreloadCompletion = (L5Asset, Error?) -> Void

/// Determines a contract of how to preload certain asset and trigger the corresponding events
/// on progress, error or completion
public protocol L5PreloaderProtocol {
    
    var delegate: L5PreloaderDelegate { get set }
    
    func preload(asset: L5Asset, completion: @escaping PreloadCompletion)
    
}

/// Specialization of L5PreloaderProtocol focused on buffering purposes meaning preemptive loading
/// that doesn't persist.
public protocol L5BufferPreloaderProtocol : L5PreloaderProtocol {
    
}

/// Specialization of L5PreloaderProtocol focused on downloading purposes meaning caching
/// that persis on storage even after the app has been killed.
public protocol L5DownloadPreloaderProtocol : L5PreloaderProtocol {
    
}

/// Delegate contract of class instance that should respond to the completion events
public protocol L5PreloaderDelegate : class {
    
    func didPreload(asset: L5Asset, by amount: Double)
    
    func didFinishPreloading(asset: L5Asset)
    
    func didFailPreloading(asset: L5Asset, withError error: Error)
    
}
