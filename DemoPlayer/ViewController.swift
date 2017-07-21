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
    
    private var stackScrollView = StackScrollView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configFormViews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configFormViews() {
        var views: [UIView] = []
        
        let marginColor = UIColor(white: 0.98, alpha: 1)
        
        views.append(MarginStackCell(height: 96, backgroundColor: marginColor))
        
        views.append(HeaderStackCell(title: "Videos to buffer at the same time", backgroundColor: marginColor))
        
        views.append(fullSeparator())
        
        views.append({
            let v = TextFieldStackCell()
            v.set(placeholder: "Videos amount")
            return v
        }())
        
        views.append(fullSeparator())
        
        views.append(HeaderStackCell(title: "Minimum videos to buffer before start playing", backgroundColor: marginColor))
        
        views.append(fullSeparator())
        
        views.append({
            let v = TextFieldStackCell()
            v.set(placeholder: "Videos amount")
            return v
        }())
        
        views.append(fullSeparator())
        
        views.append(MarginStackCell(height: 40, backgroundColor: marginColor))
        
        views.append(HeaderStackCell(title: "Buffer mechanism", backgroundColor: marginColor))
        
        views.append({
            let v = PickerStackCell()
            v.set(title: "Buffer method")
            return v
            }())
        
        views.append(fullSeparator())
        
        views.append(HeaderStackCell(title: "Buffer mechanism", backgroundColor: marginColor))
        
        views.append({
            let v = PickerStackCell()
            v.set(title: "Buffer method")
            return v
            }())
        
        views.append(fullSeparator())
        
        views.append(HeaderStackCell(title: "Caching mechanism", backgroundColor: marginColor))
        
        views.append({
            let v = PickerStackCell()
            v.set(title: "Caching method")
            return v
        }())
        
        views.append(MarginStackCell(height: 40, backgroundColor: marginColor))
        
        views.append(fullSeparator())
        
        views.append({
            let v = ButtonStackCell(buttonTitle: "Start")
            v.tapped = { [unowned self] in
                self.performSegue(withIdentifier: K.Segue.configToShow.rawValue, sender: self)
            }
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


}

