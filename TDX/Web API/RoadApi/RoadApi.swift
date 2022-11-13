//
//  RoadApi.swift
//  TDX
//
//  Created by scchn on 2022/10/26.
//

import Foundation

import RxSwift
import Moya
import RxMoya

struct RoadApi {
    
    static func cctvFreewayApi(query: Query = .init()) -> Single<CCTVList> {
        let target = MultiTarget(CCTVFreewayApiTarget(query: query))
        
        return ApiProviders.auth.rx.request(target)
            .map(CCTVList.self)
    }
    
    static func cctvCityApi(city: City, query: Query = .init()) -> Single<CCTVList> {
        let target = MultiTarget(CCTVCityApiTarget(city: city, query: query))
        
        return ApiProviders.auth.rx.request(target)
            .map(CCTVList.self)
    }
    
    static func cctvHighwayApi(query: Query = .init()) -> Single<CCTVList> {
        let target = MultiTarget(CCTVHighwayApiTarget(query: query))
        
        return ApiProviders.auth.rx.request(target)
            .map(CCTVList.self)
    }
    
}
