//
//  CCTVClusterAnnotationView.swift
//  TDX
//
//  Created by scchn on 2022/10/29.
//

import Foundation
import MapKit

class CCTVClusterAnnotationView: MKAnnotationView {
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        collisionMode = .circle
        centerOffset = CGPoint(x: 0, y: -10)
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
        
        if let cluster = annotation as? MKClusterAnnotation {
            image = makeImage()
            
            displayPriority = cluster.memberAnnotations.isEmpty ? .defaultHigh : .defaultLow
        }
    }
    
    private func makeImage() -> NSImage {
        guard let cluster = annotation as? MKClusterAnnotation, !cluster.memberAnnotations.isEmpty else {
            return .cctv
        }
        
        let cameraSize = CGSize(width: 28, height: 28)
        let circleSize = CGSize(width: 24, height: 24)
        let size = CGSize(width: cameraSize.width / 2 + circleSize.width,
                          height: cameraSize.height / 2 + circleSize.height)
        let total = cluster.memberAnnotations.count
        
        return NSImage(size: size, flipped: false) { rect in
            let cameraRect = CGRect(origin: .zero, size: cameraSize)
                .applying(.init(translationX: 0, y: rect.height - cameraSize.height))
            NSImage.cctv.draw(in: cameraRect)
            
            let circleRect = CGRect(origin: .zero, size: circleSize)
                .applying(.init(translationX: cameraSize.width / 2 , y: 0))
            let circlePath = NSBezierPath(ovalIn: circleRect)
            NSColor.green.withAlphaComponent(0.7).setFill()
            circlePath.fill()
            
            let textAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: NSColor.black,
                .font: NSFont.boldSystemFont(ofSize: total >= 100 ? 10 : 11)
            ]
            let text = total >= 100 ? "99+" : "\(total)"
            let textSize = text.size(withAttributes: textAttributes)
            let textOrigin = CGPoint(x: circleRect.midX - textSize.width / 2,
                                     y: circleRect.midY - textSize.height / 2)
            let rect = CGRect(origin: textOrigin, size: textSize)
            text.draw(in: rect, withAttributes: textAttributes)
            
            return true
        }
    }
    
}
