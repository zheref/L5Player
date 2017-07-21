//
//  ViewController.swift
//  DemoPlayer
//
//  Created by Sergio Daniel on 7/13/17.
//  Copyright © 2017 Li5. All rights reserved.
//

import UIKit
import StackScrollView

class ViewController: UIViewController {
    
    // MARK: - UI INSTANCES
    
    private var stackScrollView = StackScrollView()
    
    private lazy var sameTimeBufferAmountTextFieldStackCell: TextFieldStackCell = {
        let v = TextFieldStackCell()
        v.set(placeholder: "Videos amount")
        return v
    }()
    
    private lazy var minimumVideosToBufferBeforePlaybackTextFieldStackCell: TextFieldStackCell = {
        let v = TextFieldStackCell()
        v.set(placeholder: "Videos amount")
        return v
    }()
    
    // MARK: - LIFECYCLE

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configFormViews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - CONFIG OPERATIONS
    
    func configFormViews() {
        var views: [UIView] = []
        
        let marginColor = UIColor(white: 0.98, alpha: 1)
        
        views.append(MarginStackCell(height: 96, backgroundColor: marginColor))
        views.append(HeaderStackCell(title: "Videos to buffer at the same time", backgroundColor: marginColor))
        views.append(fullSeparator())
        
        views.append(sameTimeBufferAmountTextFieldStackCell)
        
        views.append(fullSeparator())
        views.append(HeaderStackCell(title: "Minimum videos to buffer before start playing", backgroundColor: marginColor))
        views.append(fullSeparator())
        
        views.append(minimumVideosToBufferBeforePlaybackTextFieldStackCell)
        
        views.append(fullSeparator())
        
        views.append(MarginStackCell(height: 40, backgroundColor: marginColor))
        views.append(HeaderStackCell(title: "Buffer mechanism", backgroundColor: marginColor))
        
        views.append({
            let v = PickerStackCell()
            v.set(title: " ")
            return v
            }())
        
        views.append(fullSeparator())
        views.append(HeaderStackCell(title: "Assets management mechanism", backgroundColor: marginColor))
        
        views.append({
            let v = PickerStackCell()
            v.set(title: " ")
            return v
        }())
        
        views.append(fullSeparator())
        views.append(HeaderStackCell(title: "Caching mechanism", backgroundColor: marginColor))
        
        views.append({
            let v = PickerStackCell()
            v.set(title: " ")
            return v
        }())
        
        views.append(fullSeparator())
        views.append(HeaderStackCell(title: "Player", backgroundColor: marginColor))
        
        views.append({
            let v = PickerStackCell()
            v.set(title: " ")
            return v
        }())
        
        views.append(MarginStackCell(height: 40, backgroundColor: marginColor))
        views.append(fullSeparator())
        
        views.append({ [unowned self] in
            let v = ButtonStackCell(buttonTitle: "Start")
            v.tapped = self.userDidTapStart
            return v
        }())
        
        stackScrollView.append(views: views)
        
        stackScrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        stackScrollView.frame = view.bounds
        view.addSubview(stackScrollView)
    }
    
    
    private func fullSeparator() -> SeparatorStackCell {
        return SeparatorStackCell(leftMargin: 0, rightMargin: 0, backgroundColor: .clear, separatorColor: UIColor(white: 0.90, alpha: 1))
    }
    
    
    private func semiSeparator() -> SeparatorStackCell {
        return SeparatorStackCell(leftMargin: 8, rightMargin: 8, backgroundColor: .clear, separatorColor: UIColor(white: 0.90, alpha: 1))
    }
    
    // MARK: - ACTIONS
    
    func userDidTapStart() {
        self.performSegue(withIdentifier: K.Segue.configToShow.rawValue, sender: self)
    }


}

