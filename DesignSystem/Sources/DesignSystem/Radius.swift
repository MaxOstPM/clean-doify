import SwiftUI

public extension DesignSystem {
    enum Radius {
        case small, `default`, medium, large, extraLarge, full

        /// Numeric corner radius value in points for each size.
        public var value: CGFloat {
            switch self {
            case .small:
                return 6
            case .default:
                return 8
            case .medium:
                return 12
            case .large:
                return 16
            case .extraLarge:
                return 24
            case .full:
                return 9999
            }
        }
    }
}
