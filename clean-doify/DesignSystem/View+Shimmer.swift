import SwiftUI

/// Applies a soft shimmering highlight, intended for status badges.
public struct ShimmerModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let active: Bool
    private let color: Color
    private let duration: TimeInterval

    @State private var phase: CGFloat = -1.0

    public init(active: Bool, color: Color, duration: TimeInterval = 3.0) {
        self.active = active
        self.color = color
        self.duration = duration
    }

    public func body(content: Content) -> some View {
        Group {
            if reduceMotion {
                content
            } else {
                content
                    .overlay(
                        ShimmerOverlay(
                            color: color,
                            phase: phase,
                            isVisible: active && !reduceMotion
                        )
                    )
                    .onAppear(perform: updateAnimation)
                    .onChange(of: active) { _ in updateAnimation() }
                    .onChange(of: reduceMotion) { _ in updateAnimation() }
            }
        }
    }

    private func updateAnimation() {
        guard !reduceMotion else {
            phase = -1.0
            return
        }

        guard active else {
            withAnimation(.easeOut(duration: 0.2)) {
                phase = -1.0
            }
            return
        }

        let animation = Animation.linear(duration: duration)
            .repeatForever(autoreverses: false)

        withAnimation(animation) {
            phase = 1.0
        }
    }
}

private struct ShimmerOverlay: View {
    let color: Color
    let phase: CGFloat
    let isVisible: Bool

    private var gradientStops: [Gradient.Stop] {
        [
            .init(color: color.opacity(0.0), location: 0.0),
            .init(color: color.opacity(0.0), location: 0.35),
            .init(color: color.opacity(0.12), location: 0.45),
            .init(color: color.opacity(0.20), location: 0.5),
            .init(color: color.opacity(0.12), location: 0.55),
            .init(color: color.opacity(0.0), location: 0.65),
            .init(color: color.opacity(0.0), location: 1.0)
        ]
    }

    var body: some View {
        GeometryReader { proxy in
            shimmerGradient(width: proxy.size.width, height: proxy.size.height)
        }
        .opacity(isVisible ? 1 : 0)
        .animation(.easeOut(duration: 0.2), value: isVisible)
        .allowsHitTesting(false)
        .clipped()
    }

    private func shimmerGradient(width: CGFloat, height: CGFloat) -> some View {
        let gradientWidth = max(width * 2, 1)

        return LinearGradient(
            gradient: Gradient(stops: gradientStops),
            startPoint: .leading,
            endPoint: .trailing
        )
        .frame(width: gradientWidth, height: height)
        .offset(x: width * phase)
    }
}

public extension View {
    /// Adds a reusable shimmer effect meant for active status badges.
    /// - Parameters:
    ///   - active: Controls whether the shimmer is running.
    ///   - color: Highlight color, typically the badge's accent color.
    func shimmering(active: Bool, color: Color) -> some View {
        shimmering(active: active, color: color, duration: 3.0)
    }

    /// Adds a reusable shimmer effect meant for active status badges.
    /// - Parameters:
    ///   - active: Controls whether the shimmer is running.
    ///   - color: Highlight color, typically the badge's accent color.
    ///   - duration: Time for the shimmer to travel across the badge.
    func shimmering(active: Bool, color: Color, duration: TimeInterval) -> some View {
        modifier(ShimmerModifier(active: active, color: color, duration: duration))
    }
}
