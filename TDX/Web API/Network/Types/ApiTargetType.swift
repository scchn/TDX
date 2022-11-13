//
//  ApiTargetType.swift
//  TDX
//
//  Created by scchn on 2022/10/26.
//

import Foundation

import Moya

protocol ApiTargetType: TargetType, AccessTokenAuthorizable {
    var category: ApiCategory { get }
    var version: ApiVersion { get }
}

extension ApiTargetType {
    
    var baseURL: URL {
        TDXApp.server
            .appendingPathComponent("api")
            .appendingPathComponent(category.rawValue)
            .appendingPathComponent(version.rawValue)
    }
    
    var headers: [String: String]? {
        nil
    }
    
    var validationType: ValidationType {
        .successCodes
    }
    
    var authorizationType: AuthorizationType? {
        .bearer
    }
    
}
