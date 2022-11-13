//
//  TDXApp.swift
//  TDX
//
//  Created by scchn on 2022/10/26.
//

import Foundation

private struct TDXConfig: Codable {
    
    enum CodingKeys: String, CodingKey {
        case clientID = "CLIENT_ID"
        case clientSecret = "CLIENT_SECRET"
    }
    
    var clientID: String
    var clientSecret: String
    
}

struct TDXApp {
    
    private static let config: TDXConfig = readConfig()
    
    static var clientID: String {
        config.clientID
    }
    
    static var clientSecret: String {
        config.clientSecret
    }
    
    static var server: URL {
        URL(string: "https://tdx.transportdata.tw/")!
    }
    
    private static func readConfig() -> TDXConfig {
        guard let fileURL = Bundle.main.url(forResource: "TDX-Config", withExtension: "plist") else {
            fatalError("找不到 API 設定檔")
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            
            return try PropertyListDecoder().decode(TDXConfig.self, from: data)
        } catch {
            fatalError("讀取 API 設定檔失敗：\(error)")
        }
    }
    
    private init() {
        
    }
    
}
