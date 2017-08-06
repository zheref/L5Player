//
//  L5PlayerProtocol.swift
//  L5Player
//
//  Created by Sergio Daniel on 7/20/17.
//  Copyright © 2017 Li5. All rights reserved.
//

import Foundation
import AVFoundation

public enum L5PlayerOption : String {
    case L5QueuePlayer
    case L5DVPlaylistPlayer
    case L5PlaylistPlayer
    case L5MultiPlayer
}

public protocol L5PlayerProtocol : class {
    
    var currentPlayer: AVPlayer? { get }
    
    var currentIndex: Int { get }
    
    var automaticallyReplay: Bool { get set }
    
    func play()
    
    func pause()
    
    func goNext()
    
    func goPrevious()

    func append(asset: L5Asset)
    
    func settle()
    
    func loosen()
    
}
