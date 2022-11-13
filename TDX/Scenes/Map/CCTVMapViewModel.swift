//
//  CCTVMapViewModel.swift
//  TDX
//
//  Created by scchn on 2022/10/26.
//

import Foundation
import MapKit

import RxSwift
import RxCocoa
import XcapRxKit

extension CCTVMapViewModel {
    
    struct Input {
        var fetchCCTVs: Driver<Void>
        var changeSource: Driver<CCTVSource>
        var play: Driver<Void>
    }
    
    struct Output {
        var isLoading: Driver<Bool>
        var error: Driver<Error>
        var boundaryRegion: Driver<MKCoordinateRegion?>
        var fetchCCTVs: Driver<[CCTV]>
        var play: Driver<Bool>
    }
    
}

struct CCTVMapViewModel {
    
    private var sourceCategoryRelay = BehaviorRelay<CCTVSourceCategory>(value: AppStorage.shared.sourceCategory)
    private var sourceCityRelay = BehaviorRelay<City>(value: AppStorage.shared.sourceCity)
    
    let stateDesc: Driver<String>
    
    // MARK: - Life Cycle
    
    init() {
        stateDesc = Observable.combineLatest(sourceCategoryRelay, sourceCityRelay)
            .map { category, city in
                switch category {
                case .city: return "來源範圍：\(city)"
                default:    return "來源範圍：\(category)"
                }
            }
            .asDriverOnErrorJustComplete()
    }
    
    // MARK: - Transform
    
    private func findTaiwan(activityTracker: ActivityIndicator) -> Driver<MKCoordinateRegion?> {
        Single.create { single in
            let request: MKLocalSearch.Request = {
                let request = MKLocalSearch.Request()
                request.naturalLanguageQuery = "Taiwan"
                return request
            }()
            let search = MKLocalSearch(request: request)
            
            search.start { response, error in
                single(.success(response?.boundingRegion))
            }
            
            return Disposables.create(with: search.cancel)
        }
        .trackActivity(activityTracker)
        .asDriverOnErrorJustComplete()
    }
    
    private func fetchCCTVs(trigger: Driver<Void>, activityTracker: ActivityIndicator, errorTracker: ErrorTracker) -> Driver<[CCTV]> {
        func fetch() -> Single<CCTVList> {
            switch AppStorage.shared.sourceCategory {
            case .freeway:  return RoadApi.cctvFreewayApi()
            case .highway:  return RoadApi.cctvHighwayApi()
            case .city:     return RoadApi.cctvCityApi(city: AppStorage.shared.sourceCity)
            }
        }
        
        return trigger
            .flatMapLatest {
                fetch()
                    .map(\.CCTVs)
                    .trackActivity(activityTracker)
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }
    }
    
    private func changeSource(trigger: Driver<CCTVSource>) -> Driver<Void> {
        trigger
            .filter { source in
                AppStorage.shared.sourceCategory != source.category ||
                AppStorage.shared.sourceCity != source.city
            }
            .do(onNext: { source in
                AppStorage.shared.sourceCategory = source.category
                AppStorage.shared.sourceCity = source.city
                self.sourceCategoryRelay.accept(source.category)
                self.sourceCityRelay.accept(source.city)
            })
            .mapToVoid()
    }
    
    private func play(trigger: Driver<Void>) -> Driver<Bool> {
        Observable.combineLatest(sourceCategoryRelay, sourceCityRelay)
            .flatMapLatest { category, city in
                trigger
                    .map { category == .city && city.opensWebViewByDefault }
            }
            .asDriverOnErrorJustComplete()
    }
    
    func transform(_ input: Input) -> Output {
        let activityTracker = ActivityIndicator()
        let errorTracker = ErrorTracker()
        let boundaryRegion = findTaiwan(activityTracker: activityTracker)
        let changeSource = changeSource(trigger: input.changeSource)
        let fetchCCTVsTrigger = Driver.of(input.fetchCCTVs, changeSource)
            .merge()
        let fetchCCTVs = fetchCCTVs(trigger: fetchCCTVsTrigger,
                                    activityTracker: activityTracker,
                                    errorTracker: errorTracker)
        let play = play(trigger: input.play)
        
        return .init(
            isLoading: activityTracker.asDriver(),
            error: errorTracker.asDriver(),
            boundaryRegion: boundaryRegion,
            fetchCCTVs: fetchCCTVs,
            play: play
        )
    }
    
}
