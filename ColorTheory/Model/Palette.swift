//
//  Palette.swift
//  ColorTheory
//

import SwiftUI
import UIKit

extension UIColor {
    /// Creates a color from a `#rrggbb` string. Malformed strings fall back to gray.
    convenience init(hex: String) {
        var digits = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if digits.hasPrefix("#") { digits.removeFirst() }
        guard digits.count == 6, let value = UInt32(digits, radix: 16) else {
            self.init(white: 0.5, alpha: 1)
            return
        }
        self.init(red: CGFloat((value >> 16) & 0xFF) / 255,
                  green: CGFloat((value >> 8) & 0xFF) / 255,
                  blue: CGFloat(value & 0xFF) / 255,
                  alpha: 1)
    }

    /// A spoken description that tells similar shades apart, e.g. "orange, hue 21 degrees, brightness 95 percent".
    var spokenDescription: String {
        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
        getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return "\(accessibilityName), hue \(Int((hue * 360).rounded())) degrees, brightness \(Int((brightness * 100).rounded())) percent"
    }
}

extension Color {
    init(hex: String) {
        self.init(UIColor(hex: hex))
    }
}

/// The traditional (red, yellow, blue) color wheel used throughout the game.
enum Palette {
    static let red = "#e42535"
    static let redOrange = "#f35932"
    static let orange = "#fe8134"
    static let yellowOrange = "#fdb444"
    static let yellow = "#f8e16c"
    static let yellowGreen = "#8eb348"
    static let green = "#178138"
    static let blueGreen = "#007b8a"
    static let blue = "#336699"
    static let bluePurple = "#594e9a"
    static let purple = "#8a1c7c"
    static let redPurple = "#c40061"

    /// The twelve wheel segments, clockwise from red at the top.
    static let wheel: [(name: String, hex: String)] = [
        ("red", red), ("red-orange", redOrange), ("orange", orange), ("yellow-orange", yellowOrange),
        ("yellow", yellow), ("yellow-green", yellowGreen), ("green", green), ("blue-green", blueGreen),
        ("blue", blue), ("blue-purple", bluePurple), ("purple", purple), ("red-purple", redPurple)
    ]

    static let levelBackground = Color(hex: "#212121")
    static let iconBackground = Color(hex: "#111111")
}
