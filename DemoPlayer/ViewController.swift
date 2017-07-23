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
        v.set(value: "1")
        return v
    }()
    
    private lazy var minimumVideosToBufferBeforePlaybackTextFieldStackCell: TextFieldStackCell = {
        let v = TextFieldStackCell()
        v.set(placeholder: "Videos amount")
        v.set(value: "2")
        return v
    }()
    
    fileprivate lazy var selectedBufferMechanism: L5BufferPreloaderOption = .L5PreemptiveBufferPreloader
    
    fileprivate var bufferMechanisms: [L5BufferPreloaderOption] = [
        .L5PreemptiveBufferPreloader,
        .L5BuffereXPreloader
    ]
    
    fileprivate lazy var bufferMechanismPickerStackCell: PickerStackCell = { [unowned self] in
        let v = PickerStackCell()
        v.datasource = self
        v.delegate = self
        v.set(title: " ")
        return v
    }()
    
    fileprivate var selectedManagementMechanism: L5PreloadingManagerOption = .L5CommonPreloadingManager
    
    fileprivate var managementMechanisms: [L5PreloadingManagerOption] = [
        .L5CommonPreloadingManager,
        .L5InstantPreloadingManager
    ]
    
    fileprivate lazy var managingMechanismPickerStackCell: PickerStackCell = { [unowned self] in
        let v = PickerStackCell()
        v.datasource = self
        v.delegate = self
        v.set(title: " ")
        return v
    }()
    
    fileprivate var selectedCachingMechanism: L5DownloadPreloaderOption = .L5AssetDownloadTaskPreloader
    
    fileprivate var cachingMechanisms: [L5DownloadPreloaderOption] = [
        .L5AssetDownloadTaskPreloader,
        .L5HLSionDownloadPreloader
    ]
    
    fileprivate lazy var cachingMechanismPickerStackCell: PickerStackCell = { [unowned self] in
        let v = PickerStackCell()
        v.datasource = self
        v.delegate = self
        v.set(title: " ")
        return v
    }()
    
    fileprivate var selectedPlayerMechanism: L5PlayerOption = .L5QueuePlayer
    
    fileprivate var playerMechanisms: [L5PlayerOption] = [
        L5PlayerOption.L5QueuePlayer,
        L5PlayerOption.L5DVPlaylistPlayer,
        L5PlayerOption.L5PlaylistPlayer
    ]
    
    fileprivate lazy var playerMechanismPickerStackCell: PickerStackCell = { [unowned self] in
        let v = PickerStackCell()
        v.datasource = self
        v.delegate = self
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
                             sameTimeBufferAmount: Int,
                             minimumBufferedVideosToStart: Int) -> L5PreloadingManagerProtocol
    {
        switch selectedManagementMechanism {
        case .L5CommonPreloadingManager:
            return L5CommonPreloadingManager(assets: assets,
                                             sameTimeBufferAmount: sameTimeBufferAmount,
                                             minimumBufferedVideosToStartPlaying: minimumBufferedVideosToStart)
        case .L5InstantPreloadingManager:
            return L5InstantPreloadingManager(assets: assets,
                                              sameTimeBufferAmount: sameTimeBufferAmount,
                                              minimumBufferedVideosToStartPlaying: minimumBufferedVideosToStart)
        }
        
        
    }
    
    func playerMechanism() -> L5PlayerProtocol {
        switch selectedPlayerMechanism {
        case .L5QueuePlayer:
            return L5QueuePlayer()
        case .L5DVPlaylistPlayer:
            return L5DVPlaylistPlayer()
        default:
            return L5QueuePlayer()
        }
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
            let manager = managementMechanism(assets: assets,
                                              sameTimeBufferAmount: sameTimeBufferAmount!,
                                              minimumBufferedVideosToStart: minimumVideosToBufferBeforePlayback!)
            let bufferer = bufferMechanism(delegate: manager)
            let downloader = cachingMechanism(delegate: manager)
            manager.setup(bufferer: bufferer, downloader: downloader)
            
            let player = playerMechanism()
            
            vc.setup(player: player,
                     manager: manager,
                     bufferer: bufferer,
                     downloader: downloader)
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
        bufferMechanismPickerStackCell.set(title: selectedBufferMechanism.rawValue)
        
        views.append(fullSeparator())
        views.append(HeaderStackCell(title: "Assets management mechanism",
                                     backgroundColor: marginColor))
        
        views.append(managingMechanismPickerStackCell)
        managingMechanismPickerStackCell.set(title: selectedManagementMechanism.rawValue)
        
        views.append(fullSeparator())
        views.append(HeaderStackCell(title: "Caching mechanism",
                                     backgroundColor: marginColor))
        
        views.append(cachingMechanismPickerStackCell)
        cachingMechanismPickerStackCell.set(title: selectedCachingMechanism.rawValue)
        
        views.append(fullSeparator())
        views.append(HeaderStackCell(title: "Player",
                                     backgroundColor: marginColor))
        
        views.append(playerMechanismPickerStackCell)
        playerMechanismPickerStackCell.set(title: selectedPlayerMechanism.rawValue)
        
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


extension ViewController : UIPickerViewDataSource {
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case bufferMechanismPickerStackCell.pickerView:
            return bufferMechanisms.count
        case managingMechanismPickerStackCell.pickerView:
            return managementMechanisms.count
        case cachingMechanismPickerStackCell.pickerView:
            return cachingMechanisms.count
        case playerMechanismPickerStackCell.pickerView:
            return playerMechanisms.count
        default:
            return 0
        }
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
}


extension ViewController : UIPickerViewDelegate {
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case bufferMechanismPickerStackCell.pickerView:
            return bufferMechanisms[row].rawValue
        case managingMechanismPickerStackCell.pickerView:
            return managementMechanisms[row].rawValue
        case cachingMechanismPickerStackCell.pickerView:
            return cachingMechanisms[row].rawValue
        case playerMechanismPickerStackCell.pickerView:
            return playerMechanisms[row].rawValue
        default:
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case bufferMechanismPickerStackCell.pickerView:
            selectedBufferMechanism = bufferMechanisms[row]
            bufferMechanismPickerStackCell.set(title: selectedBufferMechanism.rawValue)
        case managingMechanismPickerStackCell.pickerView:
            selectedManagementMechanism = managementMechanisms[row]
            managingMechanismPickerStackCell.set(title: selectedManagementMechanism.rawValue)
        case cachingMechanismPickerStackCell.pickerView:
            selectedCachingMechanism = cachingMechanisms[row]
            cachingMechanismPickerStackCell.set(title: selectedCachingMechanism.rawValue)
        case playerMechanismPickerStackCell.pickerView:
            selectedPlayerMechanism = playerMechanisms[row]
            playerMechanismPickerStackCell.set(title: selectedPlayerMechanism.rawValue)
        default:
            return
        }
    }
    
}

