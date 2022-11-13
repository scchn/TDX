//
//  TokenApiApiTarget.swift
//  TDX
//
//  Created by scchn on 2022/10/26.
//

import Foundation

import Moya

struct TokenApiApiTarget: TargetType {
    
    var baseURL: URL {
        TDXApp.server
    }
    
    var method: Moya.Method {
        .post
    }
    
    var path: String {
        "auth/realms/TDXConnect/protocol/openid-connect/token"
    }
    
    var task: Moya.Task {
        .requestParameters(
            parameters: [
                "grant_type": "client_credentials",
                "client_id": TDXApp.clientID,
                "client_secret": TDXApp.clientSecret
            ],
            encoding: URLEncoding.default
        )
    }
    
    var headers: [String : String]? {
        [
            "content-type": "application/x-www-form-urlencoded"
        ]
    }
    
}
