import SwiftUI

// MARK: - Corner Radius Tokens

/// Standardized corner radius values expressed in points.
public enum CornerRadius {
    case sm, `default`, md, lg, xl, full

    /// Returns the underlying radius value in points.
    public var value: CGFloat {
        switch self {
        case .sm:
            return 6
        case .default:
            return 8
        case .md:
            return 12
        case .lg:
            return 16
        case .xl:
            return 24
        case .full:
            return 9_999
        }
    }
}
