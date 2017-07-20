//
//  L5AssetStatus.swift
//  L5Player
//
//  Created by Sergio Daniel Lozano on 7/19/17.
//  Copyright © 2017 Li5. All rights reserved.
//

import Foundation

public enum L5AssetBufferStatus {
    
    case notStarted
    case buffering
    case buffered
    case discarded
    
}

public enum L5AssetDownloadStatus {
    
    case notStarted
    case downloading
    case downloaded
    
}
