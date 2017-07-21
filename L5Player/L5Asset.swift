//
//  L5Asset.swift
//  L5Player
//
//  Created by Sergio Daniel Lozano on 7/19/17.
//  Copyright © 2017 Li5. All rights reserved.
//

import Foundation
import AVFoundation


public class L5Asset {
    
    // MARK: - STORED PROPERTIES
    
    /// The model identifier of the asset. Usually the same id as its corresponding model from API
    public let id: String
    
    /// The URL this asset is representing. The validity should be checked before creating the asset.
    public let url: URL
    
    public var poster: Data?
    
    /// The buffering status of the asset.
    public var bufferStatus: L5AssetBufferStatus = .notStarted
    
    /// The download (caching) status of the asset.
    public var downloadStatus: L5AssetDownloadStatus = .notStarted
    
    /// The local URL where the video has been stored after it has been successfully downloaded.
    public var localUrl: URL?
    
    /// The AVAsset representing the actual in-memory asset with its seconds and its metadata.
    public var media: AVAsset?
    
    // MARK: - INITIALIZERS
    
    public init(url: URL, forId id: String) {
        self.url = url
        self.media = AVAsset(url: url)
        
        self.id = id
    }
    
}
