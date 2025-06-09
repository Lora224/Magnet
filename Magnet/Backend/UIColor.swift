//
//  UIColor.swift
//  Magnet
//
//  Created by Siddharth Wani on 9/6/2025.
//
import UIKit
import SwiftUI

extension UIColor {
    convenience init(_ color: Color) {
        let scanner = Scanner(string: color.description.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
        var hexNumber: UInt64 = 0
        if scanner.scanHexInt64(&hexNumber) {
            let r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
            let g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
            let b = CGFloat(hexNumber & 0x0000ff) / 255
            self.init(red: r, green: g, blue: b, alpha: 1)
            return
        }
        self.init(red: 1, green: 1, blue: 1, alpha: 1)
    }

    func toHex() -> String? {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard self.getRed(&r, green: &g, blue: &b, alpha: &a) else { return nil }

        let rgb: Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | Int(b*255)<<0
        return String(format: "#%06x", rgb)
    }
}
