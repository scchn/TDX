//
//  File.swift
//  TDX
//
//  Created by scchn on 2022/10/28.
//

import Foundation

import Moya

struct CCTVCityApiTarget: ApiTargetType {
    
    var category: ApiCategory {
        .basic
    }
    
    var version: ApiVersion {
        .v2
    }
    
    var path: String {
        "Road/Traffic/CCTV/City/\(city.rawValue)"
    }
    
    var method: Moya.Method {
        .get
    }
    
    var task: Moya.Task {
        .requestParameters(
            parameters: query.toDictionary(),
            encoding: URLEncoding.default
        )
    }
    
    let city: City
    
    let query: Query
    
}
