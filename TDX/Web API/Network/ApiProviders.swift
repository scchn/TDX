//
//  ApiProviders.swift
//  TDX
//
//  Created by scchn on 2022/10/26.
//

import Foundation

import Moya

struct ApiProviders {
    
    private static let requestPlugin = ApiRequestPlugin()
    
    #if DEBUG
    private static let monitorPlugin = ApiMonitorPlugin()
    #endif
    
    // MAKR: - Normal
    
    static let normal: MoyaProvider<MultiTarget> = {
        #if DEBUG
        return .init(plugins: [requestPlugin, monitorPlugin])
        #else
        return .init(plugins: [requestPlugin])
        #endif
    }()
    
    // MARK: - Auth
    
    static let auth: MoyaProvider<MultiTarget> = {
        let session = Session(interceptor: ApiRequestRetrier())
        let accessTokenPlugin = Moya.AccessTokenPlugin { _ in
            AppStorage.shared.token ?? ""
        }
        
        #if DEBUG
        return .init(session: session, plugins: [accessTokenPlugin, requestPlugin, monitorPlugin])
        #else
        return .init(session: session, plugins: [accessTokenPlugin, requestPlugin])
        #endif
    }()
    
    // MARK: - Life Cycle
    
    private init() {
        
    }
    
}
