//
//  NSViewController+Ext.swift
//  TDX
//
//  Created by scchn on 2022/10/28.
//

import Cocoa

import Moya

extension NSViewController {
    
    func showAlert(title: String, message: String? = nil, _ completion: (() -> Void)? = nil) {
        guard let window = view.window else {
            return
        }
        
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message ?? ""
        alert.beginSheetModal(for: window) { _ in
            completion?()
        }
    }
    
    func showError(error: Error) {
        guard let moyaError = error as? MoyaError,
              case let .underlying(error, _) = moyaError,
              let apiError = error as? ApiError
        else {
            showAlert(title: "發生錯誤")
            return
        }
        
        showAlert(title: apiError.localizedDescription)
    }
    
}
