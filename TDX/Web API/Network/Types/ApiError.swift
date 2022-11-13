//
//  ApiError.swift
//  TDX
//
//  Created by scchn on 2022/10/29.
//

import Foundation

enum ApiError: LocalizedError {
    
    case unauthorized
    case message(ApiErrorMessage)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "認證失敗"
        case .message(let message):
            return message.content
        case .unknown:
            return "發生錯誤"
        }
    }
    
}
