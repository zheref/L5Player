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
    case DVPlaylistPlayer
    case L5PlaylistPlayer
}

public protocol L5PlayerProtocol : class {
    
    var originalPlayer: AVPlayer { get }
    
    var currentIndex: Int { get }
    
    var currentItem: AVPlayerItem? { get }
    
    var status: AVPlayerStatus { get }
    
    var automaticallyReplay: Bool { get set }
    
    func play()
    
    func pause()
    
    func goToZero()
    
    func clearItems()
    
    func goNext()
    
    func goPrevious()
    
    func insert(_ item: AVPlayerItem, after afterItem: AVPlayerItem?)
    
    func canInsert(_ item: AVPlayerItem, after afterItem: AVPlayerItem?) -> Bool
    
}
