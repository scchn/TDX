//
//  ApiRequestRetrier.swift
//  TDX
//
//  Created by scchn on 2022/10/26.
//

import Foundation

import Alamofire
import RxSwift

class ApiRequestRetrier: RequestInterceptor {
    
    private let disposeBag = DisposeBag()
    
    /// 更新 Token 的 Operation Queue
    private let refreshTokenQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    /// 更新 Token
    private func refreshToken(_ completion: @escaping (Bool) -> Void) {
        let oldToken = AppStorage.shared.token
        
        refreshTokenQueue.addOperation { [weak self] in
            guard let self = self else { return }
            
            // Token 已被更新，視為成功
            if AppStorage.shared.token != oldToken {
                DispatchQueue.main.async {
                    completion(true)
                }
                return
            }
            
            let sema = DispatchSemaphore(value: 0)
            
            AuthApi.token()
                .subscribe { event in
                    if let token = try? event.get() {
                        AppStorage.shared.setToken(token.accessToken) {
                            completion(true)
                        }
                    } else {
                        completion(false)
                    }
                    sema.signal()
                }
                .disposed(by: self.disposeBag)
            
            sema.wait()
        }
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let response = request.response, response.statusCode == 401, request.retryCount < 1 else {
            return completion(.doNotRetry)
        }
        refreshToken { ok in
            completion(ok ? .retry : .doNotRetry)
        }
    }
    
}
