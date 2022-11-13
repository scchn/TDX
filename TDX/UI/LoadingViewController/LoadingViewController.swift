//
//  LoadingViewController.swift
//  TDX
//
//  Created by scchn on 2022/10/27.
//

import Cocoa

class LoadingViewController: NSViewController {
    
    // MARK: - Outlets

    @IBOutlet private weak var activityIndicator: NSProgressIndicator!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        activityIndicator.startAnimation(nil)
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        
        activityIndicator.stopAnimation(nil)
    }
    
}
