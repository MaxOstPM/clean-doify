import SwiftUI

private struct AnimatedBorderModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let color: Color
    let lineWidth: CGFloat
    let cornerRadius: CGFloat
    let animationDuration: TimeInterval

    @State private var dashPhase: CGFloat = 0
    @State private var hasStarted = false

    func body(content: Content) -> some View {
        content.overlay(borderOverlay)
            .onAppear(perform: startAnimationIfNeeded)
            .onChange(of: reduceMotion) { _ in
                if reduceMotion {
                    dashPhase = 0
                } else {
                    resetAnimation()
                }
            }
    }

    private var borderOverlay: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .strokeBorder(
                style: StrokeStyle(
                    lineWidth: lineWidth,
                    lineCap: .round,
                    lineJoin: .round,
                    dash: reduceMotion ? [] : [lineWidth * 3, lineWidth * 3],
                    dashPhase: dashPhase
                )
            )
            .foregroundStyle(color.opacity(reduceMotion ? 1 : 0.9))
            .animation(.linear(duration: animationDuration).repeatForever(autoreverses: false), value: dashPhase)
    }

    private func startAnimationIfNeeded() {
        guard !reduceMotion, !hasStarted else { return }
        resetAnimation()
        hasStarted = true
    }

    private func resetAnimation() {
        dashPhase = lineWidth * 6
        withAnimation(.linear(duration: animationDuration).repeatForever(autoreverses: false)) {
            dashPhase = -lineWidth * 6
        }
    }
}

public extension View {
    /// Overlays the view with an animated border that honors accessibility settings.
    /// - Parameters:
    ///   - color: The border color, typically sourced from ``DesignColor`` tokens.
    ///   - lineWidth: Stroke width. Defaults to ``DesignSystem.BorderWidth.medium``.
    ///   - cornerRadius: Corner radius applied to the border path.
    ///   - animationDuration: Duration of one full dash cycle.
    func animatedBorder(
        color: Color,
        lineWidth: CGFloat = DesignSystem.BorderWidth.medium.value,
        cornerRadius: CGFloat = DesignSystem.CornerRadius.md.value,
        animationDuration: TimeInterval = 1.6
    ) -> some View {
        modifier(
            AnimatedBorderModifier(
                color: color,
                lineWidth: lineWidth,
                cornerRadius: cornerRadius,
                animationDuration: animationDuration
            )
        )
    }
}
