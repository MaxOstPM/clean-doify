import SwiftUI

public extension DesignSystem {
    enum ShadowStyle {
        case sm, technical, md, elevated, cta, glow, inner
    }

    /// Returns the shadow color and geometry for a given style in the specified color scheme.
    static func shadow(_ style: ShadowStyle, for scheme: ColorScheme) -> (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
        switch style {
        case .sm:
            return (
                color: scheme == .dark
                    ? Color.fromHSL(hue: 0, saturation: 0, lightness: 0, alpha: 0.15)
                    : Color.fromHSL(hue: 210, saturation: 65, lightness: 16, alpha: 0.05),
                radius: 2,
                x: 0,
                y: 1
            )

        case .technical:
            return (
                color: scheme == .dark
                    ? Color.fromHSL(hue: 0, saturation: 0, lightness: 0, alpha: 0.40)
                    : Color.fromHSL(hue: 210, saturation: 65, lightness: 16, alpha: 0.12),
                radius: 8,
                x: 0,
                y: 2
            )

        case .md:
            return (
                color: scheme == .dark
                    ? Color.fromHSL(hue: 0, saturation: 0, lightness: 0, alpha: 0.45)
                    : Color.fromHSL(hue: 210, saturation: 65, lightness: 16, alpha: 0.15),
                radius: 12,
                x: 0,
                y: 4
            )

        case .elevated:
            return (
                color: scheme == .dark
                    ? Color.fromHSL(hue: 0, saturation: 0, lightness: 0, alpha: 0.50)
                    : Color.fromHSL(hue: 210, saturation: 65, lightness: 16, alpha: 0.18),
                radius: 16,
                x: 0,
                y: 4
            )

        case .cta:
            return (
                color: scheme == .dark
                    ? Color.fromHSL(hue: 27, saturation: 90, lightness: 58, alpha: 0.4)
                    : Color.fromHSL(hue: 27, saturation: 82, lightness: 52, alpha: 0.3),
                radius: 12,
                x: 0,
                y: 4
            )

        case .glow:
            return (
                color: scheme == .dark
                    ? Color.fromHSL(hue: 210, saturation: 100, lightness: 65, alpha: 0.25)
                    : Color.fromHSL(hue: 210, saturation: 65, lightness: 16, alpha: 0.15),
                radius: 16,
                x: 0,
                y: 0
            )

        case .inner:
            return (
                color: scheme == .dark
                    ? Color.fromHSL(hue: 0, saturation: 0, lightness: 0, alpha: 0.20)
                    : Color.fromHSL(hue: 210, saturation: 65, lightness: 16, alpha: 0.06),
                radius: 4,
                x: 0,
                y: 2
            )
        }
    }
}
