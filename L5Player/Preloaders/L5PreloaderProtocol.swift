//
//  L5PreloaderProtocol.swift
//  L5Player
//
//  Created by Sergio Daniel Lozano on 7/19/17.
//  Copyright © 2017 Li5. All rights reserved.
//

import Foundation


typealias PreloadProgressClosure = (L5Asset, Double) -> Void
typealias PreloadCompletion = (L5Asset, Error?) -> Void


protocol L5PreloaderProtocol {
    
    var delegate: L5PreloaderDelegate { get set }
    
    func preload(asset: L5Asset, completion: @escaping PreloadCompletion)
    
}


protocol L5BufferPreloaderProtocol : L5PreloaderProtocol {
    
}


protocol L5DownloadPreloaderProtocol : L5PreloaderProtocol {
    
}


protocol L5PreloaderDelegate {
    
    func didPreload(asset: L5Asset, by amount: Double)
    
    func didFinishPreloading(asset: L5Asset)
    
    func didFailPreloading(asset: L5Asset, withError error: Error)
    
}
