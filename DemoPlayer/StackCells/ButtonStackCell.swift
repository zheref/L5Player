//
//  ButtonStackCell.swift
//  L5Player
//
//  Created by Sergio Daniel on 7/20/17.
//  Copyright © 2017 Li5. All rights reserved.
//

import UIKit

import EasyPeasy

final class ButtonStackCell: StackCellBase {
    
    var tapped: () -> Void = { _ in }
    
    private let button = UIButton(type: .system)
    
    init(buttonTitle: String) {
        super.init()
        
        backgroundColor = .white
        
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        addSubview(button)
        
        button <- [
            Center(),
            Top(12),
            Bottom(12),
        ]
        
        button.setTitle(buttonTitle, for: .normal)
    }
    
    @objc private func buttonTapped() {
        tapped()
    }
}
