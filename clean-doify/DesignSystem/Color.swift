import SwiftUI

/// Extension to create a SwiftUI ``Color`` from HSL components (0–360, 0–100%, 0–100%).
public extension Color {
    static func fromHSL(hue: Double, saturation: Double, lightness: Double, alpha: Double = 1.0) -> Color {
        let h = hue.truncatingRemainder(dividingBy: 360) / 360.0
        let s = saturation / 100.0
        let l = lightness / 100.0

        var r = l, g = l, b = l
        if s != 0 {
            let q = l < 0.5 ? l * (1 + s) : l + s - l * s
            let p = 2 * l - q

            func hue2rgb(_ p: Double, _ q: Double, _ t: Double) -> Double {
                var t = t
                if t < 0 { t += 1 }
                if t > 1 { t -= 1 }
                if t < 1 / 6 { return p + (q - p) * 6 * t }
                if t < 1 / 2 { return q }
                if t < 2 / 3 { return p + (q - p) * (2 / 3 - t) * 6 }
                return p
            }

            r = hue2rgb(p, q, h + 1 / 3)
            g = hue2rgb(p, q, h)
            b = hue2rgb(p, q, h - 1 / 3)
        }

        return Color(red: r, green: g, blue: b, opacity: alpha)
    }
}

/// Namespace for design system tokens.
public enum DesignSystem {
    /// All semantic color token names in the design system.
    public enum ColorTokenName: CaseIterable {
        case primary, secondary, accent, background, card, muted
        case onPrimary, onCard, onMuted
        case success, failure, canceled, inProgress, idle
        case titlePrimary, titleSecondary, subtitle, subtitleMuted
        case border, separator, separatorStrong, input, focusRing
    }

    /// Internal struct holding a pair of light & dark mode colors.
    private struct ColorToken {
        let light: Color
        let dark: Color

        func color(for scheme: ColorScheme) -> Color {
            scheme == .dark ? dark : light
        }
    }

    /// Dictionary mapping each token name to its light/dark color values.
    private static let colorTokens: [ColorTokenName: ColorToken] = [
        .primary: ColorToken(
            light: .fromHSL(hue: 210, saturation: 65, lightness: 16),
            dark: .fromHSL(hue: 210, saturation: 100, lightness: 65)
        ),
        .secondary: ColorToken(
            light: .fromHSL(hue: 210, saturation: 25, lightness: 47),
            dark: .fromHSL(hue: 210, saturation: 45, lightness: 55)
        ),
        .accent: ColorToken(
            light: .fromHSL(hue: 27, saturation: 82, lightness: 52),
            dark: .fromHSL(hue: 27, saturation: 90, lightness: 58)
        ),
        .background: ColorToken(
            light: .fromHSL(hue: 220, saturation: 15, lightness: 92),
            dark: .fromHSL(hue: 210, saturation: 50, lightness: 8)
        ),
        .card: ColorToken(
            light: .fromHSL(hue: 0, saturation: 0, lightness: 100),
            dark: .fromHSL(hue: 210, saturation: 45, lightness: 12)
        ),
        .muted: ColorToken(
            light: .fromHSL(hue: 210, saturation: 20, lightness: 88),
            dark: .fromHSL(hue: 210, saturation: 30, lightness: 18)
        ),
        .onPrimary: ColorToken(
            light: .fromHSL(hue: 0, saturation: 0, lightness: 100),
            dark: .fromHSL(hue: 0, saturation: 0, lightness: 100)
        ),
        .onCard: ColorToken(
            light: .fromHSL(hue: 210, saturation: 65, lightness: 16),
            dark: .fromHSL(hue: 210, saturation: 100, lightness: 65)
        ),
        .onMuted: ColorToken(
            light: .fromHSL(hue: 210, saturation: 15, lightness: 45),
            dark: .fromHSL(hue: 210, saturation: 20, lightness: 65)
        ),
        .success: ColorToken(
            light: .fromHSL(hue: 142, saturation: 76, lightness: 36),
            dark: .fromHSL(hue: 142, saturation: 70, lightness: 45)
        ),
        .failure: ColorToken(
            light: .fromHSL(hue: 0, saturation: 84, lightness: 60),
            dark: .fromHSL(hue: 0, saturation: 72, lightness: 51)
        ),
        .canceled: ColorToken(
            light: .fromHSL(hue: 0, saturation: 0, lightness: 55),
            dark: .fromHSL(hue: 0, saturation: 0, lightness: 50)
        ),
        .inProgress: ColorToken(
            light: .fromHSL(hue: 199, saturation: 89, lightness: 48),
            dark: .fromHSL(hue: 199, saturation: 89, lightness: 55)
        ),
        .idle: ColorToken(
            light: .fromHSL(hue: 270, saturation: 50, lightness: 60),
            dark: .fromHSL(hue: 270, saturation: 60, lightness: 65)
        ),
        .titlePrimary: ColorToken(
            light: .fromHSL(hue: 210, saturation: 65, lightness: 16),
            dark: .fromHSL(hue: 210, saturation: 30, lightness: 95)
        ),
        .titleSecondary: ColorToken(
            light: .fromHSL(hue: 210, saturation: 25, lightness: 47),
            dark: .fromHSL(hue: 210, saturation: 100, lightness: 65)
        ),
        .subtitle: ColorToken(
            light: .fromHSL(hue: 210, saturation: 15, lightness: 45),
            dark: .fromHSL(hue: 210, saturation: 20, lightness: 70)
        ),
        .subtitleMuted: ColorToken(
            light: .fromHSL(hue: 210, saturation: 10, lightness: 60),
            dark: .fromHSL(hue: 210, saturation: 15, lightness: 55)
        ),
        .border: ColorToken(
            light: .fromHSL(hue: 210, saturation: 20, lightness: 80),
            dark: .fromHSL(hue: 210, saturation: 30, lightness: 22)
        ),
        .separator: ColorToken(
            light: .fromHSL(hue: 210, saturation: 20, lightness: 80),
            dark: .fromHSL(hue: 210, saturation: 30, lightness: 22)
        ),
        .separatorStrong: ColorToken(
            light: .fromHSL(hue: 210, saturation: 25, lightness: 70),
            dark: .fromHSL(hue: 210, saturation: 35, lightness: 28)
        ),
        .input: ColorToken(
            light: .fromHSL(hue: 210, saturation: 20, lightness: 80),
            dark: .fromHSL(hue: 210, saturation: 30, lightness: 22)
        ),
        .focusRing: ColorToken(
            light: .fromHSL(hue: 210, saturation: 65, lightness: 16),
            dark: .fromHSL(hue: 210, saturation: 100, lightness: 65)
        )
    ]

    /// Returns the SwiftUI ``Color`` for a given token in the specified color scheme.
    public static func token(_ name: ColorTokenName, for colorScheme: ColorScheme) -> Color {
        guard let token = colorTokens[name] else {
            return Color.clear
        }

        return token.color(for: colorScheme)
    }
}
