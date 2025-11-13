import SwiftUI

// MARK: - Corner Radius Tokens

public extension DesignSystem {
    /// Standardized corner radius values expressed in points.
    enum CornerRadius: CaseIterable, Sendable {
        case sm
        case base
        case md
        case lg
        case xl

        /// Returns the underlying radius value in points.
        public var value: CGFloat {
            switch self {
            case .sm:
                return 6
            case .base:
                return 8
            case .md:
                return 12
            case .lg:
                return 16
            case .xl:
                return 24
            }
        }
    }
}
