import SwiftUI

// MARK: - Unified Text Styles

public extension DesignSystem {
    struct TextStyle: Sendable {
        public let font: Font
        public let color: Color

        public init(font: Font, color: Color) {
            self.font = font
            self.color = color
        }
    }
}

public extension DesignSystem.TextStyle {
    static let titlePrimary = Self(
        font: DesignSystem.Typography.titlePrimary,
        color: DesignColor.Text.primary
    )

    static let titleSecondary = Self(
        font: DesignSystem.Typography.titleSecondary,
        color: DesignColor.Text.primary
    )

    static let body = Self(
        font: DesignSystem.Typography.body,
        color: DesignColor.Text.secondary
    )

    static let statusLabel = Self(
        font: DesignSystem.Typography.statusLabel,
        color: DesignColor.Text.primary
    )

    static let subtitleMuted = Self(
        font: DesignSystem.Typography.subtitleMuted,
        color: DesignColor.Text.tertiary
    )
}

public extension View {
    @inlinable
    func textStyle(_ style: DesignSystem.TextStyle) -> some View {
        font(style.font)
            .foregroundStyle(style.color)
    }
}
