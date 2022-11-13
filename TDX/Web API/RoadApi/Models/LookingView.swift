//
//  LookingView.swift
//  TDX
//
//  Created by scchn on 2022/10/26.
//

import Foundation

/// CCTV監看方向參考影像圖片
struct LookingView: Codable {
    /// 參考影像圖片的看方位
    var Bearing: Bearing?
    /// 參考影像圖片
    var Image: String
}
