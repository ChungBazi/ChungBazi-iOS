//
//  UIColor+Extensions.swift
//  ChungBazi
//
//  Created by 이현주 on 1/14/25.
//

import UIKit

struct AppColor {
    static let blue50 = UIColor(hex: "#E2F2FF")
    static let blue100 = UIColor(hex: "#BADFFF")
    static let blue200 = UIColor(hex: "#8BCBFF")
    static let blue300 = UIColor(hex: "#53B6FF")
    static let blue400 = UIColor(hex: "#1BA5FF")
    static let blue500 = UIColor(hex: "#0095FF")
    static let blue600 = UIColor(hex: "#0085FF")
    static let blue700 = UIColor(hex: "#1A72FF")
    static let blue800 = UIColor(hex: "#245FEC")
    static let blue900 = UIColor(hex: "#2E3BCC")
    
    static let green50 = UIColor(hex: "#F2FBEB")
    static let green100 = UIColor(hex: "#DFF4CC")
    static let green200 = UIColor(hex: "#CAEDAC")
    static let green300 = UIColor(hex: "#B5E689")
    static let green400 = UIColor(hex: "#A2E06D")
    static let green500 = UIColor(hex: "#92D954")
    static let green600 = UIColor(hex: "#83C84B")
    static let green700 = UIColor(hex: "#6EB341")
    static let green800 = UIColor(hex: "#5A9F38")
    static let green900 = UIColor(hex: "#367C27")
    
    static let gray50 = UIColor(hex: "#F5F5F5")
    static let gray100 = UIColor(hex: "#E9E9E9")
    static let gray200 = UIColor(hex: "#D9D9D9")
    static let gray300 = UIColor(hex: "#C4C4C4")
    static let gray400 = UIColor(hex: "#9D9D9D")
    static let gray500 = UIColor(hex: "#7B7B7B")
    static let gray600 = UIColor(hex: "#555555")
    static let gray700 = UIColor(hex: "#434343")
    static let gray800 = UIColor(hex: "#262626")
}

extension UIColor {
    // HEX 문자열을 UIColor로 변환하는 초기화 메서드
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let length = hexSanitized.count

        let r, g, b, a: CGFloat
        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
            a = 1.0
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
        } else {
            return nil
        }

        self.init(red: r, green: g, blue: b, alpha: a)
    }
    
    func toHex() -> String? {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        if self.getRed(&r, green: &g, blue: &b, alpha: &a) {
            let rgb: Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
            return String(format: "#%06x", rgb)
        }
        return nil
    }
}
