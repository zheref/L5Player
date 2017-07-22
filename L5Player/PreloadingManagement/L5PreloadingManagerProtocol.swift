//
//  L5PreloadingManagerProtocol.swift
//  L5Player
//
//  Created by Sergio Daniel on 7/19/17.
//  Copyright © 2017 Li5. All rights reserved.
//

import Foundation

public enum L5PreloadingManagerOption : String {
    case L5CommonPreloadingManager
    case L5InstantPreloadingManager
}

public protocol L5PreloadingManagerProtocol : L5PreloaderDelegate {
    
    init(assets: [L5Asset],
         sameTimeBufferAmount: Int,
         minimumBufferedVideosToStartPlaying: Int,
         bufferer: L5BufferPreloaderProtocol?,
         downloader: L5DownloadPreloaderProtocol?)
    
    var delegate: L5PreloadingManagerDelegate? { get set }
    
    func setup(bufferer: L5BufferPreloaderProtocol?, downloader: L5DownloadPreloaderProtocol?)
    
    func startPreloading()
    
    func preload(index: Int)
    
}


public protocol L5PreloadingManagerDelegate {
    
    var playingIndex: Int { get }
    
    func managerIsReadyForPlayback()
    
}
