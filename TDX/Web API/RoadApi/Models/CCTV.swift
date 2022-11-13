//
//  CCTV.swift
//  TDX
//
//  Created by scchn on 2022/10/26.
//

import Foundation

struct CCTV: Codable {
    /// CCTV設備代碼
    var CCTVID: String
    /// 業管子機關簡碼
    var SubAuthorityCode: String?
    /// 基礎路段代碼, 請參閱[基礎路段代碼表]
    var LinkID: String
    /// CCTV監看方向參考影像圖片
    var LookingViews: [LookingView]?
    /// 動態影像串流網址
    var VideoStreamURL: String?
    /// 靜態影像(快照)網址網址
    var VideoImageURL: String?
    /// 靜態影像(快照)更新頻率
    var ImageRefreshRate: Int?
    /// 設置地點位置類型 : [1:'路側',2:'道路中央分隔島',3:'快慢分隔島',4:'車道上門架',5:'車道鋪面',6:'其他']
    var LocationType: Int
    /// 設備架設位置 X 坐標
    var PositionLon: Double
    /// 設備架設位置 Y 坐標
    var PositionLat: Double
    /// CCTV監視類別 : [1:'路段',2:'路口',3:'匝道出入口',4:'未定義']
    var SurveillanceType: Int?
    /// 拍攝地點描述
    var SurveillanceDescription: String?
    /// 道路代碼, 請參閱[路名碼基本資料]
    var RoadID: String?
    /// 道路名稱
    var RoadName: String?
    /// 道路分類 : [0:'國道',1:'快速道路',2:'市區快速道路',3:'省道',4:'縣道',5:'鄉道',6:'市區一般道路',7:'匝道']
    var RoadClass: Int?
    /// 基礎路段所屬道路方向, 請參閱[道路方向資料表]
    var RoadDirection: Bearing?
    /// 所在道路路段描述
    var RoadSection: RoadSection?
    /// 所在方向里程數
    var LocationMile: String?
    /// 路側設備布設簡圖URL
    var LayoutMapURL: String?
}
