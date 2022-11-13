//
//  ApiRequestPlugin.swift
//  TDX
//
//  Created by scchn on 2022/10/26.
//

import Foundation

import Moya

class ApiRequestPlugin: PluginType {
    
    internal func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var request = request
        request.setValue("application/json", forHTTPHeaderField: "accept")
        return request
    }
    
    func process(_ result: Result<Response, MoyaError>, target: TargetType) -> Result<Response, MoyaError> {
        guard case .failure(let moyaError) = result else {
            return result
        }
        
        let response = moyaError.response
        
        if response?.statusCode == 401 {
            return .failure(.underlying(ApiError.unauthorized, response))
        } else if let data = response?.data,
                  let message = try? JSONDecoder().decode(ApiErrorMessage.self, from: data)
        {
            return .failure(.underlying(ApiError.message(message), response))
        } else {
            return .failure(.underlying(ApiError.unknown, response))
        }
    }
    
}
