import SwiftUI

// MARK: - Spacing Tokens

/// Consistent spacing scale used for padding and gaps across the UI.
public enum Spacing {
    case tight, small, medium, large, xl

    /// Numeric spacing value in points.
    public var value: CGFloat {
        switch self {
        case .tight:
            return 8
        case .small:
            return 16
        case .medium:
            return 24
        case .large:
            return 32
        case .xl:
            return 48
        }
    }
}
