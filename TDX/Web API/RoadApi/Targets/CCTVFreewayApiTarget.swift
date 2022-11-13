//
//  CCTVFreewayApiTarget.swift
//  TDX
//
//  Created by scchn on 2022/10/26.
//

import Foundation

import Moya

struct CCTVFreewayApiTarget: ApiTargetType {
    
    var category: ApiCategory {
        .basic
    }
    
    var version: ApiVersion {
        .v2
    }
    
    var path: String {
        "Road/Traffic/CCTV/Freeway"
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
    
    let query: Query
    
}
