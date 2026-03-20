//
//  Color+EXT.swift
//  AIChat
//
//  Created by Aman on 10/03/26.
//

import SwiftUI
import UIKit

extension Color {
    
    init(hex: String) {
        let sanitizedHex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var hexValue: UInt64 = 0
        Scanner(string: sanitizedHex).scanHexInt64(&hexValue)
        
        let redComponent: UInt64
        let greenComponent: UInt64
        let blueComponent: UInt64
        
        switch sanitizedHex.count {
        case 6: // RRGGBB
            redComponent = (hexValue >> 16) & 0xFF
            greenComponent = (hexValue >> 8) & 0xFF
            blueComponent = hexValue & 0xFF
        default:
            redComponent = 1
            greenComponent = 1
            blueComponent = 1
        }
        
        self.init(
            .sRGB,
            red: Double(redComponent) / 255,
            green: Double(greenComponent) / 255,
            blue: Double(blueComponent) / 255,
            opacity: 1
        )
    }
    
    func toHex() -> String? {
        let uiColor = UIColor(self)
        
        var redComponent: CGFloat = 0
        var greenComponent: CGFloat = 0
        var blueComponent: CGFloat = 0
        var alphaComponent: CGFloat = 0
        
        guard uiColor.getRed(
            &redComponent,
            green: &greenComponent,
            blue: &blueComponent,
            alpha: &alphaComponent
        ) else {
            return nil
        }
        
        let redValue = Int(redComponent * 255)
        let greenValue = Int(greenComponent * 255)
        let blueValue = Int(blueComponent * 255)
        
        return String(format: "#%02X%02X%02X", redValue, greenValue, blueValue)
    }
}
