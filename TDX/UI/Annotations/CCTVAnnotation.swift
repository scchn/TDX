//
//  CCTVAnnotation.swift
//  TDX
//
//  Created by scchn on 2022/10/27.
//

import Foundation
import MapKit

class CCTVAnnotation: NSObject, MKAnnotation {
    
    @objc dynamic var coordinate: CLLocationCoordinate2D
    
    var title: String?
    
    var subtitle: String?
    
    var cctv: CCTV
    
    init(coordinate: CLLocationCoordinate2D, cctv: CCTV) {
        let title = cctv.makeTitle()
        let subtitle = cctv.makeSubtitle(showsTags: false)
        
        self.coordinate = coordinate
        self.cctv = cctv
        self.title = title.ifEmpty(subtitle.ifEmpty("無"))
        self.subtitle = title.isEmpty ? nil : subtitle
    }
    
}
