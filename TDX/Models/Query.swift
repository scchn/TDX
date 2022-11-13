//
//  Query.swift
//  TDX
//
//  Created by scchn on 2022/10/26.
//

import Foundation

struct Query: Encodable {
    /// 挑選
    var select: String?
    /// 過濾
    var filter: String?
    /// 排序
    var orderby: String?
    /// 取前幾筆
    var top: Int?
    /// 跳過前幾筆
    var skip: Int?
    /// 指定來源格式
    let format: String = "JSON"
    
    func toDictionary() -> [String: Any] {
        do {
            let data = try JSONEncoder().encode(self)
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            return jsonObject as? [String: Any] ?? [:]
        } catch {
            return [:]
        }
    }
    
}
