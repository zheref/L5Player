//
//  L5PreloadingManager.swift
//  L5Player
//
//  Created by Sergio Daniel Lozano on 7/19/17.
//  Copyright © 2017 Li5. All rights reserved.
//

import Foundation


protocol L5PreloadingManagerProtocol {
    
    
    
}


class L5PreloadingManager {
    
    // MARK: - STORED PROPERTIES
    
    
    
}


extension L5PreloadingManager : L5PreloaderDelegate {
    
    func didPreload(asset: L5Asset, by amount: Double) {
        
    }
    
    func didFinishPreloading(asset: L5Asset) {
        
    }
    
    func didFailPreloading(asset: L5Asset, withError error: Error) {
        
    }
    
}
