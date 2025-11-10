import SwiftUI

// MARK: - Spacing Tokens

public extension DesignSystem {
    /// Consistent spacing scale used for padding and gaps across the UI.
    enum Spacing: CGFloat, CaseIterable, Sendable {
        case xTight = 4
        case tight = 8
        case small = 16
        case medium = 24
        case large = 32
        case xl = 48

        /// Numeric spacing value in points.
        public var value: CGFloat { rawValue }

        /// Convenience edge insets applying the same spacing to each edge.
        public var insets: EdgeInsets {
            EdgeInsets(top: value, leading: value, bottom: value, trailing: value)
        }
    }
}
