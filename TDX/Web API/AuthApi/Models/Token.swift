//
//  Token.swift
//  TDX
//
//  Created by scchn on 2022/10/26.
//

import Foundation

extension Token {
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
    }
    
}

struct Token: Codable {
    var accessToken: String
    var expiresIn: Int
}
