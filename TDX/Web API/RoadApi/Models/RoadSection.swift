//
//  RoadSection.swift
//  TDX
//
//  Created by scchn on 2022/10/26.
//

import Foundation

/// 所在道路路段描述
struct RoadSection: Codable {
    /// 路段起點描述
    var Start: String
    /// 路段迄點描述
    var End: String
}
