import SwiftUI

// MARK: - Border Width Tokens

/// Standard border widths in points used for strokes and focus rings.
public enum BorderWidth {
    case thin, medium, thick

    /// Numeric border width in points.
    public var value: CGFloat {
        switch self {
        case .thin:
            return 1
        case .medium:
            return 2
        case .thick:
            return 3
        }
    }
}
