//
//  SeparatorStackCell.swift
//  L5Player
//
//  Created by Sergio Daniel on 7/20/17.
//  Copyright © 2017 Li5. All rights reserved.
//

import UIKit

import EasyPeasy

final class SeparatorStackCell: StackCellBase {
    
    private let borderView = UIView()
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 1 / UIScreen.main.scale)
    }
    
    public init(
        leftMargin: CGFloat = 0,
        rightMargin: CGFloat = 0,
        backgroundColor: UIColor = UIColor.white,
        separatorColor: UIColor = UIColor(white: 0, alpha: 0.2)) {
        
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 1 / UIScreen.main.scale))
        
        self.backgroundColor = backgroundColor
        borderView.backgroundColor = separatorColor
        addSubview(borderView)
        
        borderView <- [
            Top(),
            Left(leftMargin),
            Right(rightMargin),
            Height(1 / UIScreen.main.scale),
            Bottom()
        ]
    }
}
