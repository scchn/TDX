//
//  CCTVList.swift
//  TDX
//
//  Created by scchn on 2022/10/26.
//

import Foundation

struct CCTVList: Codable {
    /// 本平台資料更新時間(ISO8601格式:yyyy-MM-ddTHH:mm:sszzz)
    var UpdateTime: String
    /// 本平台資料更新週期(秒)
    var UpdateInterval: Int
    /// 來源端平台資料更新時間(ISO8601格式:yyyy-MM-ddTHH:mm:sszzz)
    var SrcUpdateTime: String
    /// 來源端平台資料更新週期(秒) : [-1:'不定期更新']
    var SrcUpdateInterval: Int
    /// 業管機關簡碼
    var AuthorityCode: String
    /// 版號
    var LinkVersion: String?
    /// 清單
    var CCTVs: [CCTV]
    /// 資料總筆數
    var Count: Int?
}
