//
//  MKCoordinateRegion+Ext.swift
//  TDX
//
//  Created by scchn on 2022/10/28.
//

import Foundation
import MapKit

extension MKCoordinateRegion: Codable {
    
    enum CodingKeys: String, CodingKey {
        case center
        case span
    }
    
    public func encode(to encoder: Encoder) throws {
        let center = CGPoint(x: center.longitude, y: center.latitude)
        let span = CGVector(dx: span.longitudeDelta, dy: span.latitudeDelta)
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(center, forKey: .center)
        try container.encode(span, forKey: .span)
    }
    
    public init(from decoder: Decoder) throws {
        self.init()
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let center = try container.decode(CGPoint.self, forKey: .center)
        let span = try container.decode(CGVector.self, forKey: .span)
        
        self.center = .init(latitude: center.y, longitude: center.x)
        self.span = .init(latitudeDelta: span.dy, longitudeDelta: span.dx)
    }
    
}
