//
//  HeaderStackCell.swift
//  L5Player
//
//  Created by Sergio Daniel on 7/20/17.
//  Copyright © 2017 Li5. All rights reserved.
//

import Foundation

import EasyPeasy

import StackScrollView

final class HeaderStackCell: StackCellBase {
    
    let label = UILabel()
    
    init(title: String, backgroundColor: UIColor) {
        
        super.init()
        self.backgroundColor = backgroundColor
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        addSubview(label)
        
        label <- [
            Top(4),
            Left(8),
            Right(16),
            Bottom(4),
        ]
        
        label.text = title
    }
}
