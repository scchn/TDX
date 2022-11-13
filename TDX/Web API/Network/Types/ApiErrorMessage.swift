//
//  ApiErrorMessage.swift
//  TDX
//
//  Created by scchn on 2022/10/29.
//

import Foundation

struct ApiErrorMessage: Decodable {
    
    var content: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: MessageKey.self)
        
        self.content = try container.decode(String.self, forKey: .message)
    }
    
}

private struct MessageKey: CodingKey {
    
    var intValue: Int?
    var stringValue: String
    
    init?(intValue: Int) {
        nil
    }
    
    init?(stringValue: String) {
        guard stringValue.lowercased() == "message" else {
            return nil
        }
        self.stringValue = stringValue
    }
    
    static let message = MessageKey(stringValue: "message")!
    
}
