//
//  CCTVMapWindowController.swift
//  TDX
//
//  Created by scchn on 2022/10/27.
//

import Cocoa

class CCTVMapWindowController: NSWindowController {
    
    @IBAction func locateButtonAction(_ sender: Any) {
        NSApplication.shared.sendAction(#selector(CCTVMapViewController.showBoundary(_:)),
                                        to: contentViewController,
                                        from: nil)
    }
    
    @IBAction func refreshButtonAction(_ sender: Any) {
        NSApplication.shared.sendAction(#selector(CCTVMapViewController.refresh(_:)),
                                        to: contentViewController,
                                        from: nil)
    }
    
    @IBAction func settingsButtonAction(_ sender: Any) {
        NSApplication.shared.sendAction(#selector(CCTVMapViewController.showSettings(_:)),
                                        to: contentViewController,
                                        from: nil)
    }
    
}
