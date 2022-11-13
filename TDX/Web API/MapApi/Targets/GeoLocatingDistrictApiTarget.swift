//
//  GeoLocatingDistrictApiTarget.swift
//  TDX
//
//  Created by scchn on 2022/10/27.
//

import Foundation

import Moya

struct GeoLocatingDistrictApiTarget: ApiTargetType {
    
    var category: ApiCategory {
        .advanced
    }
    
    var version: ApiVersion {
        .v3
    }
    
    var path: String {
        "Map/GeoLocating/District/LocationX/\(longitude)/LocationY/\(latitude)"
    }
    
    var method: Moya.Method {
        .get
    }
    
    var task: Moya.Task {
        .requestPlain
    }
    
    var longitude: Double
    
    var latitude: Double
    
}
