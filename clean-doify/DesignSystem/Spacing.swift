import SwiftUI

public extension DesignSystem {
    enum Spacing {
        /// Padding inside cards or containers (horizontal & vertical padding).
        public static let cardPadding: CGFloat = 20

        /// Vertical gap between stacked card elements (e.g. between sections).
        public static let verticalGap: CGFloat = 16

        /// Small gap between text elements (e.g. text and icon or lines in a label).
        public static let textGap: CGFloat = 6

        /// Standard horizontal safe area padding (e.g. screen edge inset).
        public static let safeAreaHorizontal: CGFloat = 16

        /// Extra bottom padding to account for the home indicator.
        public static let safeAreaBottom: CGFloat = 32

        /// Maximum content width for wide layouts (e.g. iPad or large screens).
        public static let contentMaxWidth: CGFloat = 448
    }
}
