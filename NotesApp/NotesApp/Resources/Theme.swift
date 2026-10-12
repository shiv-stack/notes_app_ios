// Theme.swift
// NotesApp
//
// Design tokens: colours, fonts, spacing, and card palette.

import SwiftUI

// MARK: - App Colour Palette

extension Color {
    // Backgrounds
    static let appBackground     = Color("AppBackground")      // near-black  / light blue-gray
    static let cardBackground    = Color("CardBackground")     // slightly lighter than bg
    static let surfaceSecondary  = Color("SurfaceSecondary")

    // Text
    static let primaryText       = Color("PrimaryText")
    static let secondaryText     = Color("SecondaryText")

    // Accent / FAB
    static let fabColor          = Color("FABColor")           // black in dark / dark in light

    // Card accent colours (always fixed regardless of colour scheme)
    static let cardPink          = Color(hex: "#FFD6D6")
    static let cardYellow        = Color(hex: "#FAEAB1")
    static let cardBlueGray      = Color(hex: "#D6E4F0")
    static let cardGreen         = Color(hex: "#D6F5E3")
    static let cardPurple        = Color(hex: "#E8D6FA")
    static let cardOrange        = Color(hex: "#FFE5CC")

    /// Resolves a card colour by its stored name string.
    static func cardColor(named name: String) -> Color {
        switch name {
        case "cardPink":     return .cardPink
        case "cardYellow":   return .cardYellow
        case "cardBlueGray": return .cardBlueGray
        case "cardGreen":    return .cardGreen
        case "cardPurple":   return .cardPurple
        case "cardOrange":   return .cardOrange
        default:             return .cardPink
        }
    }

    // Convenience hex initialiser
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red:   Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Card Colour Options (for picker)

struct CardColorOption: Identifiable {
    let id   = UUID()
    let name : String
    let color: Color
}

let cardColorOptions: [CardColorOption] = [
    CardColorOption(name: "cardPink",     color: .cardPink),
    CardColorOption(name: "cardYellow",   color: .cardYellow),
    CardColorOption(name: "cardBlueGray", color: .cardBlueGray),
    CardColorOption(name: "cardGreen",    color: .cardGreen),
    CardColorOption(name: "cardPurple",   color: .cardPurple),
    CardColorOption(name: "cardOrange",   color: .cardOrange),
]

// MARK: - Typography Scale

struct AppFont {
    static func largeTitle() -> Font { .system(size: 38, weight: .bold, design: .rounded) }
    static func title1()     -> Font { .system(size: 24, weight: .bold, design: .rounded) }
    static func title2()     -> Font { .system(size: 20, weight: .semibold, design: .rounded) }
    static func body()       -> Font { .system(size: 14, weight: .regular, design: .rounded) }
    static func caption()    -> Font { .system(size: 12, weight: .regular, design: .rounded) }
    static func tab()        -> Font { .system(size: 13, weight: .medium, design: .rounded) }
}

// MARK: - Spacing

enum AppSpacing {
    static let xs:  CGFloat = 4
    static let sm:  CGFloat = 8
    static let md:  CGFloat = 12
    static let lg:  CGFloat = 16
    static let xl:  CGFloat = 24
    static let xxl: CGFloat = 32
}

// MARK: - Corner Radius

enum AppRadius {
    static let sm:  CGFloat = 8
    static let md:  CGFloat = 16
    static let lg:  CGFloat = 24
    static let fab: CGFloat = 28
}
