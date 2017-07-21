//
//  ViewController.swift
//  DemoPlayer
//
//  Created by Sergio Daniel on 7/13/17.
//  Copyright © 2017 Li5. All rights reserved.
//

import UIKit
import StackScrollView
import L5Player

class ViewController: UIViewController {
    
    // MARK: - UI INSTANCES
    
    private var stackScrollView = StackScrollView()
    
    private let marginColor = UIColor(white: 0.98, alpha: 1)
    
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
    
    private lazy var bufferMechanismPickerStackCell: PickerStackCell = {
        let v = PickerStackCell()
        v.set(title: " ")
        return v
    }()
    
    private lazy var managingMechanismPickerStackCell: PickerStackCell = {
        let v = PickerStackCell()
        v.set(title: " ")
        return v
    }()
    
    private lazy var cachingMechanismPickerStackCell: PickerStackCell = {
        let v = PickerStackCell()
        v.set(title: " ")
        return v
    }()
    
    private lazy var playerMechanismPickerStackCell: PickerStackCell = {
        let v = PickerStackCell()
        v.set(title: " ")
        return v
    }()
    
    private lazy var startButton: ButtonStackCell = { [unowned self] in
        let v = ButtonStackCell(buttonTitle: "Start")
        v.tapped = self.userDidTapStart
        return v
    }()
    
    // MARK: - COMPUTED PROPERTIES
    
    var assets: [L5Asset] {
        var i = 0
        
        return MockData.hlsVideoURLs.map({ (urlStr) -> L5Asset in
            let asset = L5Asset(url: URL(string: urlStr)!, forId: i.description)
            i += 1
            return asset
        })
    }
    
    /// Returns the amount of videos to be buffered at the same time specified by the user
    /// by using the corresponding form text field
    var sameTimeBufferAmount: Int? {
        if let val = sameTimeBufferAmountTextFieldStackCell.value {
            return Int(val)
        }
        
        return nil
    }
    
    /// Returns the amount of videos to be buffered before starting playing specified by the user
    /// by using the corresponding form text field
    var minimumVideosToBufferBeforePlayback: Int? {
        if let val = minimumVideosToBufferBeforePlaybackTextFieldStackCell.value {
            return Int(val)
        }
        
        return nil
    }
    
    /// Returns the mechanism for buffering specified by the user by using the corresponding picker
    func bufferMechanism(delegate: L5PreloaderDelegate) -> L5BufferPreloaderProtocol {
        return L5PreemptiveBufferPreloader(delegate: delegate)
    }
    
    /// Returns the mechanism for caching specified by the user by using the corresponding buffer
    func cachingMechanism(delegate: L5PreloaderDelegate) -> L5DownloadPreloaderProtocol {
        return L5HLSionDownloadPreloader(delegate: delegate)
    }
    
    func managementMechanism(assets: [L5Asset],
                             bufferer: L5BufferPreloaderProtocol,
                             downloader: L5DownloadPreloaderProtocol) -> L5PreloadingManagerProtocol
    {
        return L5CommonPreloadingManager(assets: assets, bufferer: bufferer, downloader: downloader)
    }
    
    // MARK: - LIFECYCLE

    override func viewDidLoad() {
        super.viewDidLoad()
        configFormViews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ShowViewController {
            let bufferer = bufferMechanism(delegate: vc)
            let downloader = cachingMechanism(delegate: vc)
            let manager = managementMechanism(assets: assets,
                                              bufferer: bufferer,
                                              downloader: downloader)
            
            vc.setup(player: L5QueuePlayer(),
                     manager: manager,
                     bufferer: bufferer,
                     downloader: downloader,
                     simultaneousBufferAmount: sameTimeBufferAmount!,
                     minimumBufferedVideosToStart: minimumVideosToBufferBeforePlayback!)
        }
    }
    
    // MARK: - CONFIG OPERATIONS
    
    /// Setup every view for building the form.
    func configFormViews() {
        configAmountsTextFields()
        configMechanismsPickers()
        
        stackScrollView.append(view: startButton)
        
        stackScrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        stackScrollView.frame = view.bounds
        view.addSubview(stackScrollView)
    }
    
    /// Setup form views for configurations related with videos amounts.
    private func configAmountsTextFields() {
        var views: [UIView] = []
        
        views.append(MarginStackCell(height: 96, backgroundColor: marginColor))
        views.append(HeaderStackCell(title: "Videos to buffer at the same time", backgroundColor: marginColor))
        views.append(fullSeparator())
        
        views.append(sameTimeBufferAmountTextFieldStackCell)
        
        views.append(fullSeparator())
        views.append(HeaderStackCell(title: "Minimum videos to buffer before start playing",
                                     backgroundColor: marginColor))
        views.append(fullSeparator())
        
        views.append(minimumVideosToBufferBeforePlaybackTextFieldStackCell)
        
        stackScrollView.append(views: views)
    }
    
    /// Setup form views for configurations related with mechanisms by using pickers.
    private func configMechanismsPickers() {
        var views: [UIView] = []
        
        views.append(fullSeparator())
        
        views.append(MarginStackCell(height: 40, backgroundColor: marginColor))
        views.append(HeaderStackCell(title: "Buffer mechanism",
                                     backgroundColor: marginColor))
        
        views.append(bufferMechanismPickerStackCell)
        
        views.append(fullSeparator())
        views.append(HeaderStackCell(title: "Assets management mechanism",
                                     backgroundColor: marginColor))
        
        views.append(managingMechanismPickerStackCell)
        
        views.append(fullSeparator())
        views.append(HeaderStackCell(title: "Caching mechanism",
                                     backgroundColor: marginColor))
        
        views.append(cachingMechanismPickerStackCell)
        
        views.append(fullSeparator())
        views.append(HeaderStackCell(title: "Player",
                                     backgroundColor: marginColor))
        
        views.append(playerMechanismPickerStackCell)
        
        views.append(MarginStackCell(height: 40,
                                     backgroundColor: marginColor))
        views.append(fullSeparator())
        
        stackScrollView.append(views: views)
    }
    
    /// Returns a pre-built full separator ready to append to stack scroll view
    private func fullSeparator() -> SeparatorStackCell {
        return SeparatorStackCell(leftMargin: 0, rightMargin: 0, backgroundColor: .clear, separatorColor: UIColor(white: 0.90, alpha: 1))
    }
    
    /// Returns a pre-built partial separator ready to append to stack scroll view
    private func semiSeparator() -> SeparatorStackCell {
        return SeparatorStackCell(leftMargin: 8, rightMargin: 8, backgroundColor: .clear, separatorColor: UIColor(white: 0.90, alpha: 1))
    }
    
    // MARK: - ACTIONS
    
    func userDidTapStart() {
        self.performSegue(withIdentifier: K.Segue.configToShow.rawValue, sender: self)
    }


}

