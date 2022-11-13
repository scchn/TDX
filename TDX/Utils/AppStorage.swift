//
//  AppStorage.swift
//  TDX
//
//  Created by scchn on 2022/10/26.
//

import Foundation
import MapKit

import KeychainAccess

struct AppStorage {
    
    static let shared = AppStorage()
    
    private let keychain = Keychain(service: "com.scchn.TDX")
    
    // MARK: - Settings
    
    var token: String? {
        keychain[string: "token"]
    }
    
    var sourceCategory: CCTVSourceCategory {
        get { read(CCTVSourceCategory.self, forKey: "sourceCategory") ?? .freeway }
        nonmutating set { write(newValue, forKey: "sourceCategory") }
    }
    
    var sourceCity: City {
        get { read(City.self, forKey: "sourceCity") ?? .kaohsiung }
        nonmutating set { write(newValue, forKey: "sourceCity") }
    }
    
    // MARK: - Life Cycle
    
    private init() {
        
    }
    
    // MARK: - Utils
    
    private func write<T: Encodable>(_ value: T?, forKey key: String) {
        guard let data = try? JSONEncoder().encode(value) else {
            return
        }
        
        UserDefaults.standard.set(data, forKey: key)
    }
    
    private func read<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = UserDefaults.standard.value(forKey: key) as? Data else {
            return nil
        }
        
        return try? JSONDecoder().decode(type, from: data)
    }
    
    func setToken(_ token: String?, _ completion: (() -> Void)? = nil) {
        DispatchQueue.global().async {
            keychain[string: "token"] = token
            
            DispatchQueue.main.async {
                completion?()
            }
        }
    }
    
}
