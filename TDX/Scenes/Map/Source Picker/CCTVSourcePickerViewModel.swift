//
//  CCTVSourcePickerViewModel.swift
//  TDX
//
//  Created by scchn on 2022/10/28.
//

import Foundation

import RxSwift
import RxCocoa

extension CCTVSourcePickerViewModel {
    
    struct Input {
        var selectCategory: Driver<Int>
        var selectCity: Driver<Int>
        var makeCategory: Driver<Void>
    }
    
    struct Output {
        var categoryIndex: Driver<Int>
        var canSelectCity: Driver<Bool>
        var cityIndex: Driver<Int>
        var makeSource: Driver<CCTVSource>
    }
    
}

class CCTVSourcePickerViewModel {
    
    // MARK: - Transform
    
    private func categoryIndex(category: BehaviorRelay<CCTVSourceCategory>, select: Driver<Int>) -> Driver<Int> {
        select
            .compactMap(CCTVSourceCategory.allCases.get)
            .do(onNext: category.accept(_:))
            .startWith(category.value)
            .compactMap(CCTVSourceCategory.allCases.firstIndex(of:))
    }
    
    private func cityIndex(city: BehaviorRelay<City>, select: Driver<Int>) -> Driver<Int> {
        select
            .compactMap(City.allCases.get)
            .do(onNext: city.accept(_:))
            .startWith(city.value)
            .compactMap(City.allCases.firstIndex(of:))
    }
    
    private func makeSource(
        trigger: Driver<Void>,
        category: BehaviorRelay<CCTVSourceCategory>,
        city: BehaviorRelay<City>
    ) -> Driver<CCTVSource> {
        Driver.combineLatest(category.asDriver(), city.asDriver())
            .map(CCTVSource.init(category:city:))
            .flatMapLatest { source in
                trigger.map {
                    source
                }
            }
    }
    
    func transform(_ input: Input) -> Output {
        let categoryRelay = BehaviorRelay(value: AppStorage.shared.sourceCategory)
        let cityRelay = BehaviorRelay(value: AppStorage.shared.sourceCity)
        let categoryIndex = categoryIndex(category: categoryRelay, select: input.selectCategory)
        let canSelectCity = categoryRelay
            .map { $0 == .city }
            .asDriverOnErrorJustComplete()
        let cityIndex = cityIndex(city: cityRelay, select: input.selectCity)
        let makeSource = makeSource(trigger: input.makeCategory, category: categoryRelay, city: cityRelay)
        
        return Output(
            categoryIndex: categoryIndex,
            canSelectCity: canSelectCity,
            cityIndex: cityIndex,
            makeSource: makeSource
        )
    }
    
}
