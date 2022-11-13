//
//  NSImage+Ext.swift
//  TDX
//
//  Created by scchn on 2022/10/27.
//

import Cocoa

extension Data {
    
    fileprivate var bitmapImageRep: NSBitmapImageRep? {
        NSBitmapImageRep(data: self)
    }
    
}

extension NSImage {
    
    func representation(using fileType: NSBitmapImageRep.FileType) -> Data? {
        tiffRepresentation?.bitmapImageRep?.representation(using: fileType, properties: [:])
    }
    
    func resized(size: CGSize) -> NSImage {
        .init(size: size, flipped: false) { rect in
            self.draw(in: rect)
            return true
        }
    }
    
    func resized(width: CGFloat, height: CGFloat) -> NSImage {
        let size = CGSize(width: width, height: height)
        
        return .init(size: size, flipped: false) { rect in
            self.draw(in: rect)
            return true
        }
    }
    
}

extension NSImage {
    
    static let play = NSImage(named: "play")!
    
    static let cctv = NSImage(named: "cctv")!
    
}
