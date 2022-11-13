//
//  City.swift
//  TDX
//
//  Created by scchn on 2022/10/29.
//

import Foundation

enum City: String, CaseIterable, CustomStringConvertible, Codable {
    
    case keelung        = "Keelung"
    case taipei         = "Taipei"
    case newTaipei      = "NewTaipei"
    case taoyuan        = "Taoyuan"
    case hsinchu        = "Hsinchu"
    case hsinchuCounty  = "HsinchuCounty"
    case miaoliCounty   = "MiaoliCounty"
    case taichung       = "Taichung"
    case changhuaCounty = "ChanghuaCounty"
    case nantouCounty   = "NantouCounty"
    case yunlinCounty   = "YunlinCounty"
    case chiayi         = "Chiayi"
    case chiayiCounty   = "ChiayiCounty"
    case tainan         = "Tainan"
    case kaohsiung      = "Kaohsiung"
    case pingtungCounty = "PingtungCounty"
    case taitungCounty  = "TaitungCounty"
    case hualienCounty  = "HualienCounty"
    case yilanCounty    = "YilanCounty"
    
    var description: String {
        switch self {
        case .keelung:          return "基隆市"
        case .taipei:           return "台北市"
        case .newTaipei:        return "新北市"
        case .taoyuan:          return "桃園市"
        case .hsinchu:          return "新竹市"
        case .hsinchuCounty:    return "新竹縣"
        case .miaoliCounty:     return "苗栗縣"
        case .taichung:         return "台中市"
        case .changhuaCounty:   return "彰化縣"
        case .nantouCounty:     return "南投縣"
        case .yunlinCounty:     return "雲林縣"
        case .chiayi:           return "嘉義市"
        case .chiayiCounty:     return "嘉義縣"
        case .tainan:           return "台南市"
        case .kaohsiung:        return "高雄市"
        case .pingtungCounty:   return "屏東縣"
        case .taitungCounty:    return "台東縣"
        case .hualienCounty:    return "花蓮縣"
        case .yilanCounty:      return "宜蘭縣"
        }
    }
    
}
