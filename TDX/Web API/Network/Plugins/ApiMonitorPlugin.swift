//
//  ApiMonitorPlugin.swift
//  TDX
//
//  Created by scchn on 2022/10/26.
//

#if DEBUG

import Foundation

import Alamofire
import Moya

/// 監聽
class ApiMonitorPlugin: PluginType {
    
    func willSend(_ request: RequestType, target: TargetType) {
        printHeader("Request", message: request.request?.url?.absoluteString ?? "-")
        
        guard let request = request.request else { return }
        
        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            print()
            print("Headers:")
            for (name, value) in headers {
                print("\t\(name) = \(value)")
            }
        }
        
        if let body = request.httpBody, let string = String(data: body, encoding: .utf8) {
            print()
            print("Body:")
            print("\(prettyPrintedJsonString(string) ?? string)")
        }
        
        print()
    }
    
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        switch result {
        case let .success(response):
            guard let url = response.response?.url else { break }
            
            printHeader("Response(\(response.statusCode)):", message: url.absoluteString)
            
            print()
            print("Data:")
            if let string = String(data: response.data, encoding: .utf8) {
                print(prettyPrintedJsonString(string) ?? string)
            } else {
                print("<Empty>")
            }
            
        case let .failure(error):
            if let response = error.response?.response, let url = response.url {
                printHeader("Response(\(response.statusCode)):", message: url.absoluteString)
            } else if case let .underlying(error, _) = error,
                      let realError = error.asAFError?.underlyingError as? NSError,
                      let url = realError.userInfo[NSURLErrorFailingURLStringErrorKey] as? String
            {
                printHeader("Response(Error):", message: url)
            }
            
            print()
            print("❌ Failed:", error.localizedDescription)
            
            if case let .underlying(_, info) = error,
               let data = info?.data,
               let errorDataString = String(data: data, encoding: .utf8)
            {
                print()
                print("\(errorDataString)")
            }
        }
        
        print()
    }
    
}

extension ApiMonitorPlugin {
    
    private func printHeader(_ title: String, message: String) {
        let maxLen = max(title.unicodeScalars.count, message.unicodeScalars.count)
        
        print("""
        +-\(String(repeating: "-", count: maxLen))-+
        | \(title.padding(toLength: maxLen, withPad: " ", startingAt: 0)) |
        | \(message.padding(toLength: maxLen, withPad: " ", startingAt: 0)) |
        +-\(String(repeating: "-", count: maxLen))-+
        """)
    }
    
    /// 格式化的 JSON 字串
    private func prettyPrintedJsonString(_ string: String) -> String? {
        guard let data = string.data(using: .utf8),
              let object = try? JSONSerialization.jsonObject(with: data, options: []),
              let jsonData = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted])
        else { return nil }
        return String(data: jsonData, encoding: .utf8)
    }
    
}

#endif
