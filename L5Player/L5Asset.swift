//
//  L5Asset.swift
//  L5Player
//
//  Created by Sergio Daniel Lozano on 7/19/17.
//  Copyright © 2017 Li5. All rights reserved.
//

import Foundation
import AVFoundation


class L5Asset {
    
    // MARK: - STORED PROPERTIES
    
    /// The model identifier of the asset. Usually the same id as its corresponding model from API
    let id: String
    
    /// The URL this asset is representing. The validity should be checked before creating the asset.
    let url: URL
    
    /// The buffering status of the asset.
    var bufferStatus: L5AssetBufferStatus = .notStarted
    
    /// The download (caching) status of the asset.
    var downloadStatus: L5AssetDownloadStatus = .notStarted
    
    /// The local URL where the video has been stored after it has been successfully downloaded.
    var localUrl: URL?
    
    /// The AVAsset representing the actual in-memory asset with its seconds and its metadata.
    var media: AVAsset?
    
    // MARK: - INITIALIZERS
    
    init(url: URL, forId id: String) {
        self.url = url
        self.media = AVAsset(url: url)
        
        self.id = id
    }
    
}
