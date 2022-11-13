//
//  CCTVViewController.swift
//  TDX
//
//  Created by scchn on 2022/10/27.
//

import Cocoa

import RxSwift
import RxCocoa

extension CCTVViewController {
    
    static func instantiate(cctv: CCTV, opensWebViewByDefault: Bool) -> CCTVViewController {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateController(withIdentifier: "CCTVViewController")
            as! CCTVViewController
        vc.viewModel = .init(cctv: cctv)
        vc.opensWebViewByDefault = opensWebViewByDefault
        return vc
    }
    
    typealias WebInfo = (url: URL, title: String, subtitle: String)
    
}

class CCTVViewController: NSViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var previewView: NSView!
    @IBOutlet private weak var titleLabel: NSTextField!
    @IBOutlet private weak var locationLoadingIndicator: NSProgressIndicator!
    @IBOutlet private weak var subtitleLabel: NSTextField!
    @IBOutlet private weak var refreshButton: NSButton!
    @IBOutlet private weak var captureButton: NSButton!
    @IBOutlet private weak var noVideoWarningLabel: NSTextField!
    @IBOutlet private weak var openWebViewButton: NSButton!
    
    // MARK: - UI
    
    private let loadingVC = LoadingViewController()
    private var webVC: CCTVWebViewController?
    
    // MARK: - Data
    
    private let disposeBag = DisposeBag()
    private var viewModel: CCTVViewModel!
    private var opensWebViewByDefault = false
    private let stream = CCTVStream()
    private let stateRelay = BehaviorRelay<CCTVStream.State>(value: .stopped)
    
    // MARK: - Life Cycle
    
    deinit {
        stream.stop()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupBinding()
    }
    
    // MARK: - UI Methods
    
    private func setupUI() {
        locationLoadingIndicator.isDisplayedWhenStopped = false
        
        let previewLayer: CALayer = {
            let layer = CALayer()
            layer.backgroundColor = .black
            layer.contentsGravity = .resizeAspect
            return layer
        }()
        previewView.layer = previewLayer
        previewView.wantsLayer = true
    }
    
    private func showFrameSavePanel() {
        guard let window = view.window else {
            return
        }
        guard let image = stream.cachedFrame, let imageData = image.representation(using: .png) else {
            showAlert(title: "無法取得截圖")
            return
        }
        
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.png]
        panel.beginSheetModal(for: window) { response in
            guard response == .OK, let fileURL = panel.url else {
                return
            }
            if (try? imageData.write(to: fileURL)) == nil {
                self.showAlert(title: "儲存失敗")
            }
        }
    }
    
    private func showVideoLoadingView() {
        let loadingView = loadingVC.view
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(loadingView)
        
        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: previewView.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: previewView.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: previewView.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: previewView.bottomAnchor),
        ])
    }
    
    private func hideVideoLoadingView() {
        loadingVC.view.removeFromSuperview()
    }
    
    private func showWebView(info: WebInfo) {
        let webVC = CCTVWebViewController.instantiate(url: info.url,
                                                      title: info.title,
                                                      subtitle: info.subtitle)
        addChild(webVC)
        
        let webView = webVC.view
        webView.frame = view.bounds
        webView.autoresizingMask = [.width, .height]
        view.addSubview(webView)
        
        self.webVC = webVC
    }
    
    // MARK: - Utils
    
    private func play(videoURL: URL) {
        guard stream.state == .stopped else {
            return
        }
        
        stream.didStart = { [weak self] in
            guard let self = self else {
                return
            }
            self.stateRelay.accept(self.stream.state)
        }
        
        stream.didReceiveFrame = { [weak self] image in
            guard let self = self else {
                return
            }
            self.previewView.layer?.contents = image
        }
        
        stream.didDisconnect = { [weak self] in
            guard let self = self else {
                return
            }
            self.stateRelay.accept(self.stream.state)
        }
        
        stream.start(url: videoURL)
        
        stateRelay.accept(stream.state)
    }
    
    // MARK: - UI Actions
    
    @IBAction private func closeButtonAction(_ sender: Any) {
        dismiss(nil)
    }
    
    @IBAction private func captureButtonAction(_ sender: Any) {
        showFrameSavePanel()
    }
    
}

// MARK: - Binding

extension CCTVViewController {
    
    private var titleBinding: Binder<String> {
        .init(self) { vc, title in
            vc.titleLabel.stringValue = title
            vc.webVC?.setTitle(title)
        }
    }
    
    private var subtitleBinding: Binder<String> {
        .init(self) { vc, subtitle in
            vc.subtitleLabel.stringValue = subtitle
            vc.webVC?.setSubtitle(subtitle)
        }
    }
    
    private var loadingBinding: Binder<Bool> {
        .init(self) { vc, isLoading in
            isLoading
            ? vc.locationLoadingIndicator.startAnimation(nil)
            : vc.locationLoadingIndicator.stopAnimation(nil)
        }
    }
    
    private var openWebViewBinding: Binder<WebInfo> {
        .init(self) { vc, info in
            vc.showWebView(info: info)
        }
    }
    
    private var loadingVideoBinding: Binder<Bool> {
        .init(self) { vc, isLoading in
            isLoading
                ? vc.showVideoLoadingView()
                : vc.hideVideoLoadingView()
        }
    }
    
    private var playBinding: Binder<URL> {
        .init(self) { vc, url in
            vc.play(videoURL: url)
        }
    }
    
    private func setupBinding() {
        let openWebView = opensWebViewByDefault
            ? openWebViewButton.rx.tap.startWith(()).asDriverOnErrorJustComplete()
            : openWebViewButton.rx.tap.asDriver()
        let input = CCTVViewModel.Input(
            state: stateRelay.asDriver(),
            play: refreshButton.rx.tap.startWith(()).asDriverOnErrorJustComplete(),
            openWebView: openWebView
        )
        let output = viewModel.transform(input)
        
        disposeBag.insert([
            viewModel.isLoading.drive(loadingBinding),
            viewModel.title.drive(titleBinding),
            viewModel.subtitle.drive(subtitleBinding),
            viewModel.subtitle.map(\.isEmpty).drive(subtitleLabel.rx.isHidden)
        ])
        
        disposeBag.insert([
            output.canRefresh.drive(refreshButton.rx.isEnabled),
            output.canCapture.drive(captureButton.rx.isEnabled),
            output.canOpenWebView.drive(openWebViewButton.rx.isEnabled),
            output.openWebView.drive(openWebViewBinding),
            output.hidesNoVideoWarning.drive(noVideoWarningLabel.rx.isHidden),
            output.isLoadingVideo.drive(loadingVideoBinding),
            output.play.drive(playBinding),
        ])
    }
    
}
