import SwiftUI
import UIKit

/// Primary namespace for design system level utilities that do not belong to a
/// specific token group. The enum remains empty and is used for existing
/// extensions such as typography helpers.
public enum DesignSystem {}

// MARK: - Color Helpers

public extension Color {
    /// Creates a SwiftUI ``Color`` using HSL components.
    /// - Parameters:
    ///   - hue: Hue value between 0 and 360 degrees.
    ///   - saturation: Saturation percentage between 0 and 100.
    ///   - lightness: Lightness percentage between 0 and 100.
    ///   - alpha: Optional opacity value between 0 and 1. Defaults to 1.
    static func fromHSL(
        hue: Double,
        saturation: Double,
        lightness: Double,
        alpha: Double = 1.0
    ) -> Color {
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

    /// Initializes a color that adapts automatically to light and dark mode.
    /// - Parameters:
    ///   - light: Color used when the system is in light mode.
    ///   - dark: Color used when the system is in dark mode.
    init(light: Color, dark: Color) {
        self = Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }

    /// Describes the color's hue, saturation, and brightness values for a given trait collection.
    /// Falls back to ``nil`` if the underlying color cannot provide HSB components (e.g. pattern images).
    @MainActor
    func hsbDescription(in traitCollection: UITraitCollection) -> HSBDescription? {
        let resolvedColor = UIColor(self).resolvedColor(with: traitCollection)

        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0

        guard resolvedColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) else {
            return nil
        }

        return HSBDescription(
            hue: Int((hue * 360).rounded()),
            saturation: Int((saturation * 100).rounded()),
            brightness: Int((brightness * 100).rounded())
        )
    }
}

public extension Color {
    struct HSBDescription: Hashable {
        public let hue: Int
        public let saturation: Int
        public let brightness: Int

        public init(hue: Int, saturation: Int, brightness: Int) {
            self.hue = hue
            self.saturation = saturation
            self.brightness = brightness
        }
    }
}

// MARK: - Semantic Colors

/// Design system color tokens grouped by semantic usage. Each token provides a
/// dynamic SwiftUI ``Color`` that adapts to the current color scheme.
public enum DesignColor {
    // MARK: Primary & Accent Colors

    /// Primary brand color (soft blue in light mode, vibrant accent blue in dark mode).
    /// Suitable for headers, primary buttons, and high emphasis elements.
    public static let primary = Color(
        light: .fromHSL(hue: 210, saturation: 45, lightness: 68),
        dark: .fromHSL(hue: 210, saturation: 55, lightness: 72)
    )

    /// Secondary accent color used for supporting actions and secondary emphasis.
    public static let secondary = Color(
        light: .fromHSL(hue: 210, saturation: 30, lightness: 75),
        dark: .fromHSL(hue: 210, saturation: 40, lightness: 65)
    )

    /// Call-to-action accent color (soft orange in light mode, warm orange in dark mode).
    public static let accent = Color(
        light: .fromHSL(hue: 27, saturation: 65, lightness: 72),
        dark: .fromHSL(hue: 27, saturation: 95, lightness: 60)
    )

    // MARK: Background & Foreground

    /// Main application background color (very light gray in light mode, pure black in dark mode).
    public static let background = Color(
        light: .fromHSL(hue: 220, saturation: 25, lightness: 96),
        dark: .fromHSL(hue: 0, saturation: 0, lightness: 0)
    )

    /// Primary foreground color for text shown on the background or surfaces.
    public static let foreground: Color = DesignColor.Text.primary

    /// Muted foreground color suitable for secondary text treatment.
    public static let mutedForeground: Color = DesignColor.Text.secondary

    // MARK: Surfaces

    public enum Surface {
        /// Card and elevated surface color (off-white in light mode, dark gray in dark mode).
        public static let card = Color(
            light: .fromHSL(hue: 0, saturation: 0, lightness: 98),
            dark: .fromHSL(hue: 0, saturation: 0, lightness: 13)
        )

        /// Popover and overlay surface color.
        public static let popover = Color(
            light: .fromHSL(hue: 0, saturation: 0, lightness: 98),
            dark: .fromHSL(hue: 0, saturation: 0, lightness: 13)
        )

        /// Muted surface used for disabled or subtle interface elements.
        public static let muted = Color(
            light: .fromHSL(hue: 210, saturation: 25, lightness: 92),
            dark: .fromHSL(hue: 0, saturation: 0, lightness: 18)
        )
    }

    /// Border color for outlines and dividers.
    public static let border = Color(
        light: .fromHSL(hue: 210, saturation: 25, lightness: 88),
        dark: .fromHSL(hue: 0, saturation: 0, lightness: 22)
    )

    /// Input background/border color, matching the border token.
    public static let input = Color(
        light: .fromHSL(hue: 210, saturation: 25, lightness: 88),
        dark: .fromHSL(hue: 0, saturation: 0, lightness: 22)
    )

    // MARK: Text Tokens

    public enum Text {
        /// Primary text color (dark navy in light mode, near-white in dark mode).
        public static let primary = Color(
            light: .fromHSL(hue: 210, saturation: 30, lightness: 25),
            dark: .fromHSL(hue: 0, saturation: 0, lightness: 95)
        )

        /// Secondary text color (muted gray-blue in light mode, lighter gray in dark mode).
        public static let secondary = Color(
            light: .fromHSL(hue: 210, saturation: 20, lightness: 50),
            dark: .fromHSL(hue: 0, saturation: 0, lightness: 70)
        )

        /// Tertiary text color for captions and metadata.
        public static let tertiary = Color(
            light: .fromHSL(hue: 210, saturation: 15, lightness: 65),
            dark: .fromHSL(hue: 0, saturation: 0, lightness: 60)
        )

        /// Text color for content placed on top of the primary color.
        public static let onPrimary = Color(
            light: .fromHSL(hue: 0, saturation: 0, lightness: 100),
            dark: .fromHSL(hue: 0, saturation: 0, lightness: 100)
        )

        /// Text color for content placed on top of the accent color.
        public static let onAccent = Color(
            light: .fromHSL(hue: 0, saturation: 0, lightness: 100),
            dark: .fromHSL(hue: 0, saturation: 0, lightness: 0)
        )
    }

    // MARK: Status Tokens

    public enum Status {
        /// Success state color (soft green in light, brighter green in dark mode).
        public static let success = Color(
            light: .fromHSL(hue: 142, saturation: 50, lightness: 65),
            dark: .fromHSL(hue: 142, saturation: 50, lightness: 68)
        )

        /// Failure state color (soft red in light, bright red in dark mode).
        public static let failure = Color(
            light: .fromHSL(hue: 0, saturation: 55, lightness: 75),
            dark: .fromHSL(hue: 0, saturation: 60, lightness: 72)
        )

        /// Canceled state color (neutral gray across modes).
        public static let canceled = Color(
            light: .fromHSL(hue: 0, saturation: 0, lightness: 68),
            dark: .fromHSL(hue: 0, saturation: 0, lightness: 62)
        )

        /// In-progress state color (soft cyan in light mode, bright cyan in dark mode).
        public static let inProgress = Color(
            light: .fromHSL(hue: 199, saturation: 60, lightness: 72),
            dark: .fromHSL(hue: 199, saturation: 55, lightness: 72)
        )

        /// Idle state color (soft purple consistent across modes).
        public static let idle = Color(
            light: .fromHSL(hue: 270, saturation: 45, lightness: 75),
            dark: .fromHSL(hue: 270, saturation: 45, lightness: 75)
        )
    }

}
