//
//  MapApi.swift
//  TDX
//
//  Created by scchn on 2022/10/27.
//

import Foundation

import RxSwift
import Moya
import RxMoya

struct MapApi {
    
    static func geoLocatingDistrictApi(longitude: Double, latitude: Double) -> Single<[DistrictLocation]> {
        let target = MultiTarget(GeoLocatingDistrictApiTarget(longitude: longitude, latitude: latitude))
        
        return ApiProviders.auth.rx.request(target)
            .map([DistrictLocation].self)
    }
    
}
