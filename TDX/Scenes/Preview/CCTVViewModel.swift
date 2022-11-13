//
//  CCTVswift
//  TDX
//
//  Created by scchn on 2022/10/27.
//

import Foundation

import RxSwift
import RxCocoa
import XcapRxKit

extension CCTVViewModel {
    
    struct Input {
        var state: Driver<CCTVStream.State>
        var play: Driver<Void>
        var openWebView: Driver<Void>
    }
    
    struct Output {
        var canRefresh: Driver<Bool>
        var canCapture: Driver<Bool>
        var canOpenWebView: Driver<Bool>
        var openWebView: Driver<WebInfo>
        var hidesNoVideoWarning: Driver<Bool>
        var isLoadingVideo: Driver<Bool>
        var play: Driver<URL>
    }
    
    typealias WebInfo = (url: URL, title: String, subtitle: String)
    
}

struct CCTVViewModel {
    
    // MARK: - Data
    
    private let activityTracker = ActivityIndicator()
    private let cctv: CCTV
    
    let isLoading: Driver<Bool>
    let title: Driver<String>
    let subtitle: Driver<String>
    let videoURL: Driver<URL?>
    
    // MARK: - Life Cycle
    
    init(cctv: CCTV) {
        let location = MapApi.geoLocatingDistrictApi(longitude: cctv.PositionLon, latitude: cctv.PositionLat)
            .trackActivity(activityTracker)
            .map(\.first)
            .catchAndReturn(nil)
            .startWith(nil)
            .asDriverOnErrorJustComplete()
        let url: URL? = {
            guard let urlString = cctv.VideoStreamURL else {
                return nil
            }
            return .init(string: urlString)
        }()
        
        self.cctv = cctv
        self.isLoading = activityTracker.asDriver()
        self.title = location.map(cctv.makeTitle(location:))
        self.subtitle = .just(cctv.makeSubtitle(showsTags: true))
        self.videoURL = .just(url)
    }
    
    // MARK: - Transform
    
    private func webInfo() -> Driver<WebInfo> {
        Driver.combineLatest(videoURL, title, subtitle)
            .compactMap { (url, title, subtitle) -> WebInfo? in
                guard let url = url else {
                    return nil
                }
                return (url, title, subtitle)
            }
    }
    
    private func play(trigger: Driver<Void>) -> Driver<URL> {
        videoURL
            .flatMapLatest { url -> Driver<URL> in
                guard let url = url else {
                    return .empty()
                }
                return trigger
                    .map { url }
            }
    }
    
    func transform(_ input: Input) -> Output {
        let canCapture = input.state
            .map { $0 == .playing }
        let canRefresh = Driver.combineLatest(videoURL, input.state)
            .map { url, state in
                url != nil && state == .stopped
            }
        let canOpenWeb = videoURL
            .map { $0 != nil }
        let openWebView = input.openWebView
            .withLatestFrom(webInfo())
        let hidesNoVideoWarning = videoURL
            .map { $0 != nil }
        let isLoadingVideo = input.state
            .map { $0 == .loading }
        let play = play(trigger: input.play)
        
        return .init(
            canRefresh: canRefresh,
            canCapture: canCapture,
            canOpenWebView: canOpenWeb,
            openWebView: openWebView,
            hidesNoVideoWarning: hidesNoVideoWarning,
            isLoadingVideo: isLoadingVideo,
            play: play
        )
    }
    
}
