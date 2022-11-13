//
//  City+Ext.swift
//  TDX
//
//  Created by scchn on 2022/10/30.
//

import Foundation

extension City {
    
    var opensWebViewByDefault: Bool {
        switch self {
        case .keelung:          return false
        case .taipei:           return true
        case .newTaipei:        return true
        case .taoyuan:          return false
        case .hsinchu:          return false
        case .hsinchuCounty:    return false
        case .miaoliCounty:     return false
        case .taichung:         return true
        case .changhuaCounty:   return false
        case .nantouCounty:     return true
        case .yunlinCounty:     return true
        case .chiayi:           return false
        case .chiayiCounty:     return false
        case .tainan:           return false
        case .kaohsiung:        return false
        case .pingtungCounty:   return true
        case .taitungCounty:    return false
        case .hualienCounty:    return true
        case .yilanCounty:      return true
        }
    }
    
}
