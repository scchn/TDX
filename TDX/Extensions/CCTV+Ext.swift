//
//  CCTV+Ext.swift
//  TDX
//
//  Created by scchn on 2022/10/29.
//

import Foundation

import XcapAppKit

extension CCTV {
    
    func makeTitle(location: DistrictLocation? = nil) -> String {
        let directionDesc: String? = {
            guard let direction = RoadDirection else {
                return nil
            }
            return "[\(direction)]"
        }()
        let locationDesc: String? = {
            guard let location else {
                return nil
            }
            return "\(location.CityName) \(location.TownName)"
        }()
        return [directionDesc, locationDesc, RoadName]
            .compactMap { $0 }
            .filterNot(\.isEmpty)
            .joined(separator: " ")
    }
    
    func makeSubtitle(showsTags: Bool) -> String {
        let surveillanceDesc: String? = {
            guard let desc = SurveillanceDescription, !desc.isEmpty else {
                return nil
            }
            return "\(showsTags ? "簡述：" : "")\(desc)"
        }()
        let sectionDesc: String? = {
            guard let start = RoadSection?.Start.trimmingCharacters(in: .whitespaces),
                  let end = RoadSection?.End.trimmingCharacters(in: .whitespaces),
                  !start.isEmpty, !end.isEmpty
            else {
                return nil
            }
            return "\(showsTags ? "路段：" : "")\(start) 至 \(end)"
        }()
        let mileDesc: String? = {
            guard let mile = LocationMile, !mile.isEmpty else {
                return nil
            }
            return "\(showsTags ? "里程：" : "")\(mile)"
        }()
        let viewDirectionsDesc: String? = {
            guard let lookViews = LookingViews, !lookViews.isEmpty else {
                return nil
            }
            return "\(showsTags ? "觀看方向：" : "")" + lookViews
                .compactMap(\.Bearing?.description)
                .joined(separator: "、")
        }()
        
        return [surveillanceDesc, sectionDesc, mileDesc, viewDirectionsDesc]
            .compactMap { $0 }
            .filterNot(\.isEmpty)
            .joined(separator: "\n")
    }
    
}
