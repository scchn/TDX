//
//  CCTVHighwayApiTarget.swift
//  TDX
//
//  Created by scchn on 2022/10/28.
//

import Foundation

import Moya

struct CCTVHighwayApiTarget: ApiTargetType {
    
    var category: ApiCategory {
        .basic
    }
    
    var version: ApiVersion {
        .v2
    }
    
    var path: String {
        "Road/Traffic/CCTV/Highway"
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
