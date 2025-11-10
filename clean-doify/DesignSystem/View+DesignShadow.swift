import SwiftUI

private struct DesignShadowModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    let token: DesignSystem.Shadow

    func body(content: Content) -> some View {
        let spec = token.specification(for: colorScheme)
        return content.shadow(
            color: spec.resolvedColor,
            radius: spec.radius,
            x: spec.x,
            y: spec.y
        )
    }
}

public extension View {
    /// Applies a shadow defined by ``DesignSystem.Shadow`` that adapts to the active color scheme.
    /// - Parameter token: The design system shadow token to render.
    /// - Returns: A view decorated with the appropriate drop shadow.
    func designShadow(_ token: DesignSystem.Shadow) -> some View {
        modifier(DesignShadowModifier(token: token))
    }
}
