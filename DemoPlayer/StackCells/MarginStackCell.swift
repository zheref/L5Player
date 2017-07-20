//
//  MarginStackCell.swift
//  L5Player
//
//  Created by Sergio Daniel on 7/20/17.
//  Copyright © 2017 Li5. All rights reserved.
//

import UIKit

import StackScrollView

final class MarginStackCell: StackCellBase {
    
    let height: CGFloat
    
    init(height: CGFloat, backgroundColor: UIColor) {
        self.height = height
        super.init()
        self.backgroundColor = backgroundColor
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: height)
    }
}
