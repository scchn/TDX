//
//  DistrictLocation.swift
//  TDX
//
//  Created by scchn on 2022/10/27.
//

import Foundation

/// 行政區定位查詢資料輸出模型
struct DistrictLocation: Codable {
    /// 縣市英文
    var City: String
    /// 縣市名稱
    var CityName: String
    /// 鄉鎮代碼
    var TownCode: String
    /// 鄉鎮名稱
    var TownName: String
}
