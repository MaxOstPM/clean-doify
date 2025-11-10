import SwiftUI

// MARK: - Shadow Tokens

/// Specifications describing a drop shadow appearance.
public struct ShadowSpec {
    public let radius: CGFloat
    public let x: CGFloat
    public let y: CGFloat
    public let color: Color
    public let opacity: Double

    /// Convenience color with opacity applied.
    public var resolvedColor: Color { color.opacity(opacity) }
}

/// Predefined shadow styles with light and dark variants.
public enum DesignShadow {
    case sm, technical, md, elevated, lg, xl, cta, glow, inner

    /// Resolves the shadow spec for the provided color scheme.
    public func specification(for colorScheme: ColorScheme) -> ShadowSpec {
        shadow(light: colorScheme != .dark)
    }

    /// Returns the shadow spec for the desired interface style.
    public func shadow(light isLightMode: Bool) -> ShadowSpec {
        let radius: CGFloat
        let xOffset: CGFloat
        let yOffset: CGFloat
        let schemeColor: Color

        switch self {
        case .sm:
            radius = 2; xOffset = 0; yOffset = 1
            schemeColor = isLightMode
                ? Color.fromHSL(hue: 210, saturation: 45, lightness: 50, alpha: 0.04)
                : Color.fromHSL(hue: 0, saturation: 0, lightness: 0, alpha: 0.20)
        case .technical:
            radius = 8; xOffset = 0; yOffset = 2
            schemeColor = isLightMode
                ? Color.fromHSL(hue: 210, saturation: 45, lightness: 50, alpha: 0.08)
                : Color.fromHSL(hue: 0, saturation: 0, lightness: 0, alpha: 0.40)
        case .md:
            radius = 12; xOffset = 0; yOffset = 4
            schemeColor = isLightMode
                ? Color.fromHSL(hue: 210, saturation: 45, lightness: 50, alpha: 0.10)
                : Color.fromHSL(hue: 0, saturation: 0, lightness: 0, alpha: 0.50)
        case .elevated:
            radius = 16; xOffset = 0; yOffset = 4
            schemeColor = isLightMode
                ? Color.fromHSL(hue: 210, saturation: 45, lightness: 50, alpha: 0.12)
                : Color.fromHSL(hue: 0, saturation: 0, lightness: 0, alpha: 0.60)
        case .lg:
            radius = 24; xOffset = 0; yOffset = 8
            schemeColor = isLightMode
                ? Color.fromHSL(hue: 210, saturation: 45, lightness: 50, alpha: 0.15)
                : Color.fromHSL(hue: 0, saturation: 0, lightness: 0, alpha: 0.70)
        case .xl:
            radius = 32; xOffset = 0; yOffset = 12
            schemeColor = isLightMode
                ? Color.fromHSL(hue: 210, saturation: 45, lightness: 50, alpha: 0.18)
                : Color.fromHSL(hue: 0, saturation: 0, lightness: 0, alpha: 0.75)
        case .cta:
            radius = 12; xOffset = 0; yOffset = 4
            schemeColor = isLightMode
                ? Color.fromHSL(hue: 27, saturation: 65, lightness: 72, alpha: 0.25)
                : Color.fromHSL(hue: 27, saturation: 70, lightness: 75, alpha: 0.35)
        case .glow:
            radius = 16; xOffset = 0; yOffset = 0
            schemeColor = isLightMode
                ? Color.fromHSL(hue: 210, saturation: 45, lightness: 68, alpha: 0.12)
                : Color.fromHSL(hue: 210, saturation: 55, lightness: 72, alpha: 0.25)
        case .inner:
            radius = 4; xOffset = 0; yOffset = 2
            schemeColor = isLightMode
                ? Color.fromHSL(hue: 210, saturation: 45, lightness: 50, alpha: 0.04)
                : Color.fromHSL(hue: 0, saturation: 0, lightness: 0, alpha: 0.20)
        }

        return ShadowSpec(radius: radius, x: xOffset, y: yOffset, color: schemeColor, opacity: 1)
    }
}
