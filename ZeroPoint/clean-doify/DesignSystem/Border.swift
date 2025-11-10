import SwiftUI

// MARK: - Border Width Tokens

public extension DesignSystem {
    /// Standard border widths in points used for strokes and focus rings.
    enum BorderWidth: CGFloat, CaseIterable, Sendable {
        case thin = 1
        case medium = 2
        case thick = 3

        /// Numeric border width in points.
        public var value: CGFloat { rawValue }
    }
}
