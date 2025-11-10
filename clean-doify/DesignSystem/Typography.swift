import SwiftUI

public extension DesignSystem {
    enum Typography {
        /// Primary headline style – 20pt, bold (default leading).
        public static let titlePrimary = Font.system(size: 20, weight: .bold, design: .default)

        /// Secondary title style – 16pt, semibold, tight line spacing.
        public static let titleSecondary = Font.system(size: 16, weight: .semibold, design: .default)
            .leading(.tight)

        /// Body text – 14pt, regular, relaxed line spacing for readability.
        public static let body = Font.system(size: 14, weight: .regular, design: .default)
            .leading(.loose)

        /// Font for status labels/badges – 12pt, medium weight.
        public static let statusLabel = Font.system(size: 12, weight: .medium, design: .default)

        /// Muted subtitle text – 12pt, regular weight.
        public static let subtitleMuted = Font.system(size: 12, weight: .regular, design: .default)
            .leading(.tight)
    }
}
