//
//  AuthApi.swift
//  TDX
//
//  Created by scchn on 2022/10/26.
//

import Foundation

import Moya
import RxSwift
import RxMoya

struct AuthApi {
    
    static func token() -> Single<Token> {
        let target = MultiTarget(TokenApiApiTarget())
        
        return ApiProviders.normal.rx.request(target)
            .map(Token.self)
    }
    
}
