import SwiftUI

public extension DesignSystem {
    enum Typography {
        /// Font for main titles (e.g. task titles) – 16pt, semibold, tight line spacing.
        public static let title = Font.system(size: 16, weight: .semibold, design: .default)
            .leading(.tight)

        /// Font for descriptive text – 14pt, regular, relaxed line spacing.
        public static let description = Font.system(size: 14, weight: .regular, design: .default)
            .leading(.loose)

        /// Font for section headings – 20pt, bold (default leading).
        public static let sectionHeading = Font.system(size: 20, weight: .bold, design: .default)

        /// Font for status labels/badges – 12pt, medium weight.
        public static let statusLabel = Font.system(size: 12, weight: .medium, design: .default)
    }
}
