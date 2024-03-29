//
//  UIImage+Extensions.swift
//  macOS (Helper)
//  https://www.swiftbysundell.com/tips/making-uiimage-macos-compatible/
//
//  Created by Tanner on 8/17/21.
//

import Cocoa

// Step 1: Typealias UIImage to NSImage
typealias UIImage = NSImage

// Step 2: You might want to add these APIs that UIImage has but NSImage doesn't.
extension NSImage {
    var cgImage: CGImage? {
        var proposedRect = CGRect(origin: .zero, size: size)
        
        return cgImage(forProposedRect: &proposedRect,
                       context: nil,
                       hints: nil)
    }
    
    convenience init?(named name: String) {
        self.init(named: Name(name))
    }
}
