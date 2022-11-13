//
//  CCTVStream.swift
//  TDX
//
//  Created by scchn on 2022/10/27.
//

import Cocoa

extension CCTVStream {
    
    enum State {
        case stopped
        case loading
        case playing
    }
    
}

final class CCTVStream: NSObject {
    
    private let maxRetryCount: Int
    private let maxInvalidFrames: Int
    
    private var session: URLSession?
    private var dataTask: URLSessionDataTask?
    private var receivedData = Data()
    private var invalidFrameCount = 0
    private var retryCount = 0
    
    private(set) var state: State = .stopped
    private(set) var cachedFrame: NSImage?
    
    var url: URL? {
        dataTask?.originalRequest?.url
    }
    
    var didStart: (() -> Void)?
    var didReceiveFrame: ((NSImage) -> Void)?
    var didDisconnect: (() -> Void)?
    
    init(maxRetryCount: Int = 1, maxInvalidFrames: Int = 60) {
        self.maxRetryCount = maxRetryCount
        self.maxInvalidFrames = maxInvalidFrames
        
        super.init()
    }
    
    private func refresh(url: URL) {
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let dataTask = session.dataTask(with: request)
        
        dataTask.resume()
        
        self.session = session
        self.dataTask = dataTask
    }
    
    func start(url: URL) {
        guard state == .stopped || url != self.url else {
            return
        }
        
        stop()
        refresh(url: url)
        state = .loading
    }
    
    func stop() {
        guard state != .stopped else {
            return
        }
        
        session?.invalidateAndCancel()
        session = nil
        dataTask = nil
        receivedData.removeAll()
        invalidFrameCount = 0
        retryCount = 0
        cachedFrame = nil
        state = .stopped
    }
    
}

extension CCTVStream: URLSessionDataDelegate {
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        receivedData.append(data)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        if let image = NSImage(data: receivedData) {
            if state == .loading {
                state = .playing
                didStart?()
            }
            
            didReceiveFrame?(image)
            
            cachedFrame = image
            receivedData.removeAll()
            invalidFrameCount = 0
            retryCount = 0
            
            completionHandler(.allow)
        } else if invalidFrameCount < maxInvalidFrames {
            receivedData.removeAll()
            invalidFrameCount += 1
            
            completionHandler(.allow)
        } else {
            receivedData.removeAll()
            invalidFrameCount = 0
            
            completionHandler(.cancel)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard state != .stopped && task == dataTask else {
            return
        }
        guard retryCount < maxRetryCount, let url = task.originalRequest?.url else {
            stop()
            didDisconnect?()
            return
        }
        
        retryCount += 1
        refresh(url: url)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        var disposition: URLSession.AuthChallengeDisposition = .performDefaultHandling
        var credential: URLCredential?
        
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if let trust = challenge.protectionSpace.serverTrust {
                credential = URLCredential(trust: trust)
                disposition = .useCredential
            }
        }
        
        completionHandler(disposition, credential)
    }
    
}
