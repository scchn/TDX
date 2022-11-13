//
//  CCTVSourceCategory.swift
//  TDX
//
//  Created by scchn on 2022/10/28.
//

import Foundation

enum CCTVSourceCategory: CaseIterable, CustomStringConvertible, Codable {
    
    case freeway
    case highway
    case city
    
    var description: String {
        switch self {
        case .freeway:  return "高速公路"
        case .highway:  return "省道"
        case .city:     return "縣市"
        }
    }
    
}
