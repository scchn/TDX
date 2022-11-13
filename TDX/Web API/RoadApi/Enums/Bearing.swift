//
//  Bearing.swift
//  TDX
//
//  Created by scchn on 2022/10/26.
//

import Foundation

/// 方位
enum Bearing: String, CustomStringConvertible, Codable {
    
    case none
    case E
    case N
    case NE
    case NW
    case S
    case SE
    case SW
    case W
    case A
    case CW
    case CCW
    
    var description: String {
        switch self {
        case .none: return "無"
        case .E:    return "東"
        case .N:    return "北"
        case .NE:   return "東北"
        case .NW:   return "西北"
        case .S:    return "南"
        case .SE:   return "東南"
        case .SW:   return "西南"
        case .W:    return "西"
        case .A:    return "圓環"
        case .CW:   return "順時針"
        case .CCW:  return "逆時針"
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        
        self = Bearing(rawValue: value) ?? .none
    }
    
}
