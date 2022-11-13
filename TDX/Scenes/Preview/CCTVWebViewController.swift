//
//  CCTVWebViewController.swift
//  TDX
//
//  Created by scchn on 2022/10/29.
//

import Cocoa
import WebKit

extension CCTVWebViewController {
    
    static func instantiate(url: URL, title: String, subtitle: String) -> CCTVWebViewController {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateController(withIdentifier: "CCTVWebViewController")
            as! CCTVWebViewController
        vc.url = url
        vc.defaultTitle = title
        vc.defaultSubtitle = subtitle
        return vc
    }
    
}

class CCTVWebViewController: NSViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var titleLabel: NSTextField!
    @IBOutlet private weak var subtitleLabel: NSTextField!
    @IBOutlet private weak var webView: WKWebView!
    
    // MARK: - Data
    
    private var didClose: (() -> Void)?
    private var url: URL!
    private var defaultTitle = ""
    private var defaultSubtitle = ""
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    // MARK: - UI Methods
    
    private func setupUI() {
        setTitle(defaultTitle)
        setSubtitle(defaultSubtitle)
        
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    // MARK: - UI Actions
    
    @IBAction private func closeButtonAction(_ sender: Any) {
        parent?.dismiss(nil)
    }
    
    @IBAction private func backButtonAction(_ sender: Any) {
        view.removeFromSuperview()
        removeFromParent()
    }
    
    @IBAction private func refreshButtonAction(_ sender: Any) {
        webView.reload()
    }
    
    // MARK: - Public Methods
    
    func setTitle(_ title: String) {
        titleLabel.stringValue = title
    }
    
    func setSubtitle(_ subtitle: String) {
        subtitleLabel.stringValue = subtitle
        subtitleLabel.isHidden = subtitle.isEmpty
    }
    
}
