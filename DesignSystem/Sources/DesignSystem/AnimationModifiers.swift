import SwiftUI

public enum GridShimmerActivation {
    case cooldown(TimeInterval)
    case manual(isActive: Binding<Bool>)
}

public extension View {
    /// Adds an animated, token-aware gradient border around the view.
    ///
    /// - Parameters:
    ///   - colors: Custom colors for the gradient. When `nil` the modifier will derive
    ///     colors from the ``DesignSystem`` tokens for the current color scheme.
    ///   - lineWidth: Thickness of the border. Defaults to ``DesignSystem.BorderWidth.medium``.
    ///   - cornerRadius: Corner radius applied to the border. Defaults to ``DesignSystem.Radius.large``.
    ///   - animationDuration: Duration of a full rotation, in seconds.
    /// - Returns: A view with an animated gradient border. When Reduce Motion is enabled the
    ///   border remains static to respect the user's preference.
    func animatedBorder(
        colors: [Color]? = nil,
        lineWidth: CGFloat = DesignSystem.BorderWidth.medium.value,
        cornerRadius: CGFloat = DesignSystem.Radius.large.value,
        animationDuration: TimeInterval = 4.0
    ) -> some View {
        modifier(
            AnimatedBorderModifier(
                colors: colors,
                lineWidth: lineWidth,
                cornerRadius: cornerRadius,
                animationDuration: animationDuration
            )
        )
    }

    /// Overlays the view with a shimmering grid skeleton effect that can be reused for loading states.
    ///
    /// - Parameters:
    ///   - activation: Strategy controlling how the shimmer is triggered (cooldown or manual binding).
    ///   - preferredColumnWidth: Desired minimum width for each column. The modifier resolves the column
    ///     count automatically based on the container's width and the provided spacing.
    ///   - spacing: Constant spacing applied between grid tiles.
    ///   - cornerRadius: Corner radius applied to each grid tile.
    ///   - lineWidth: Width of the animated grid strokes.
    ///   - animationDuration: Total duration of a full draw-in/hold/draw-out cycle.
    /// - Returns: A view masked with a shimmering grid effect. When Reduce Motion is enabled the
    ///   shimmer remains static while still conveying affordance.
    func gridShimmer(
        activation: GridShimmerActivation = .cooldown(1.5),
        preferredColumnWidth: CGFloat = 120,
        spacing: CGFloat = DesignSystem.Spacing.textGap,
        cornerRadius: CGFloat = DesignSystem.Radius.medium.value,
        lineWidth: CGFloat = DesignSystem.BorderWidth.thin.value,
        animationDuration: TimeInterval = 1.6
    ) -> some View {
        modifier(
            GridShimmerModifier(
                activation: activation,
                preferredColumnWidth: preferredColumnWidth,
                spacing: spacing,
                cornerRadius: cornerRadius,
                lineWidth: lineWidth,
                animationDuration: animationDuration
            )
        )
    }
}

private struct AnimatedBorderModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let colors: [Color]?
    let lineWidth: CGFloat
    let cornerRadius: CGFloat
    let animationDuration: TimeInterval

    @State private var isAnimating = false

    func body(content: Content) -> some View {
        content.overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(
                    AngularGradient(
                        gradient: Gradient(colors: gradientColors),
                        center: .center
                    ),
                    lineWidth: lineWidth
                )
                .rotationEffect(rotationAngle)
                .animation(animation, value: isAnimating)
                .onAppear { startAnimatingIfNeeded() }
                .onChange(of: reduceMotion) { _ in
                    startAnimatingIfNeeded()
                }
        )
    }

    private var gradientColors: [Color] {
        if let colors, !colors.isEmpty {
            return colors
        }

        return [
            DesignSystem.token(.accent, for: colorScheme),
            DesignSystem.token(.primary, for: colorScheme),
            DesignSystem.token(.secondary, for: colorScheme)
        ]
    }

    private var rotationAngle: Angle {
        guard !reduceMotion else { return .degrees(0) }
        return isAnimating ? .degrees(360) : .degrees(0)
    }

    private var animation: Animation? {
        guard !reduceMotion else { return nil }
        return .linear(duration: animationDuration).repeatForever(autoreverses: false)
    }

    private func startAnimatingIfNeeded() {
        guard !reduceMotion else {
            isAnimating = false
            return
        }

        if !isAnimating {
            isAnimating = true
        }
    }
}

private struct GridShimmerModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let activation: GridShimmerActivation
    let preferredColumnWidth: CGFloat
    let spacing: CGFloat
    let cornerRadius: CGFloat
    let lineWidth: CGFloat
    let animationDuration: TimeInterval

    func body(content: Content) -> some View {
        content.overlay {
            GridShimmerOverlay(
                activation: activation,
                preferredColumnWidth: max(preferredColumnWidth, 24),
                spacing: max(spacing, 0),
                cornerRadius: cornerRadius,
                lineWidth: max(lineWidth, 0.5),
                animationDuration: max(animationDuration, 0.1),
                baseColor: DesignSystem.token(.muted, for: colorScheme),
                highlightColor: DesignSystem.token(.card, for: colorScheme),
                reduceMotion: reduceMotion
            )
            .mask(content)
        }
    }
}

private struct GridShimmerOverlay: View {
    let activation: GridShimmerActivation
    let preferredColumnWidth: CGFloat
    let spacing: CGFloat
    let cornerRadius: CGFloat
    let lineWidth: CGFloat
    let animationDuration: TimeInterval
    let baseColor: Color
    let highlightColor: Color
    let reduceMotion: Bool

    @State private var cycleStartTime: TimeInterval?
    @State private var nextScheduledStart: TimeInterval?

    var body: some View {
        GeometryReader { proxy in
            Group {
                if reduceMotion {
                    GridShimmerCanvas(
                        preferredColumnWidth: preferredColumnWidth,
                        spacing: spacing,
                        cornerRadius: cornerRadius,
                        lineWidth: lineWidth,
                        phase: 1,
                        isAnimating: false,
                        baseColor: baseColor,
                        highlightColor: highlightColor
                    )
                } else {
                    TimelineView(.animation) { timeline in
                        let progress = animationProgress(for: timeline.date)

                        GridShimmerCanvas(
                            preferredColumnWidth: preferredColumnWidth,
                            spacing: spacing,
                            cornerRadius: cornerRadius,
                            lineWidth: lineWidth,
                            phase: progress ?? 0,
                            isAnimating: progress != nil,
                            baseColor: baseColor,
                            highlightColor: highlightColor
                        )
                    }
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .topLeading)
        }
        .allowsHitTesting(false)
        .onAppear { configureInitialSchedule() }
        .onChange(of: reduceMotion) { _ in configureInitialSchedule() }
        .onChange(of: manualBinding?.wrappedValue ?? false) { newValue in
            guard manualBinding != nil else { return }
            if newValue {
                scheduleNextCycle(at: Date().timeIntervalSinceReferenceDate)
            }
        }
    }

    private var manualBinding: Binding<Bool>? {
        if case let .manual(binding) = activation { return binding }
        return nil
    }

    private func configureInitialSchedule() {
        guard !reduceMotion else {
            cycleStartTime = nil
            nextScheduledStart = nil
            return
        }

        switch activation {
        case .cooldown:
            if cycleStartTime == nil, nextScheduledStart == nil {
                scheduleNextCycle(at: Date().timeIntervalSinceReferenceDate)
            }
        case let .manual(binding):
            if binding.wrappedValue {
                scheduleNextCycle(at: Date().timeIntervalSinceReferenceDate)
            } else {
                cycleStartTime = nil
                nextScheduledStart = nil
            }
        }
    }

    private func animationProgress(for date: Date) -> Double? {
        guard !reduceMotion else { return nil }

        let reference = date.timeIntervalSinceReferenceDate

        if let start = cycleStartTime {
            let elapsed = reference - start
            if elapsed >= animationDuration {
                completeCycle(at: reference)
                return 1
            }

            return max(0, min(elapsed / animationDuration, 1))
        }

        if let nextStart = nextScheduledStart, reference >= nextStart {
            startCycle(at: reference)
            return 0
        }

        return nil
    }

    private func startCycle(at reference: TimeInterval) {
        guard cycleStartTime == nil else { return }
        DispatchQueue.main.async {
            cycleStartTime = reference
            nextScheduledStart = nil
        }
    }

    private func completeCycle(at reference: TimeInterval) {
        DispatchQueue.main.async {
            cycleStartTime = nil

            switch activation {
            case let .cooldown(interval):
                scheduleNextCycle(at: reference + max(interval, 0))
            case let .manual(binding):
                if binding.wrappedValue {
                    binding.wrappedValue = false
                }
                nextScheduledStart = nil
            }
        }
    }

    private func scheduleNextCycle(at time: TimeInterval) {
        DispatchQueue.main.async {
            nextScheduledStart = time
        }
    }
}

private struct GridShimmerCanvas: View {
    let preferredColumnWidth: CGFloat
    let spacing: CGFloat
    let cornerRadius: CGFloat
    let lineWidth: CGFloat
    let phase: Double
    let isAnimating: Bool
    let baseColor: Color
    let highlightColor: Color

    var body: some View {
        Canvas { context, size in
            let metrics = GridMetrics(
                size: size,
                preferredColumnWidth: preferredColumnWidth,
                spacing: spacing
            )

            guard metrics.cellSize.width > 0, metrics.cellSize.height > 0 else { return }

            let strokeStyle = StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)

            for row in 0..<metrics.rows {
                for column in 0..<metrics.columns {
                    let rect = metrics.rectForCell(row: row, column: column)
                    guard rect.width > 0, rect.height > 0 else { continue }

                    let basePath = Path(roundedRect: rect, cornerRadius: cornerRadius)
                    context.stroke(basePath, with: .color(baseColor.opacity(0.35)), style: strokeStyle)

                    guard isAnimating else { continue }

                    let progress = strokeProgress(for: row, column: column)
                    guard progress > 0 else { continue }

                    let trimmed = basePath.trimmedPath(from: 0, to: CGFloat(progress))
                    let opacity = 0.45 + (0.55 * progress)
                    context.stroke(trimmed, with: .color(highlightColor.opacity(opacity)), style: strokeStyle)
                }
            }
        }
    }

    private func strokeProgress(for row: Int, column: Int) -> Double {
        let normalized = max(0, min(phase, 1))

        let drawInEnd: Double = 0.6
        let holdEnd: Double = 0.78
        let minDuration = drawInEnd * 0.45
        let maxDuration = drawInEnd * 0.95

        let noise = pseudoRandom(row: row, column: column)
        let cellDuration = lerp(min: minDuration, max: maxDuration, t: noise)

        if normalized < drawInEnd {
            let drawProgress = normalized / max(cellDuration, 0.0001)
            return min(easeOutCubic(drawProgress), 1)
        }

        if normalized < holdEnd {
            return 1
        }

        let drawOutProgress = (normalized - holdEnd) / max(1 - holdEnd, 0.0001)
        return max(1 - easeInCubic(drawOutProgress), 0)
    }

    private func lerp(min: Double, max: Double, t: Double) -> Double {
        min + (max - min) * t
    }

    private func easeOutCubic(_ t: Double) -> Double {
        1 - pow(1 - min(max(t, 0), 1), 3)
    }

    private func easeInCubic(_ t: Double) -> Double {
        let clamped = min(max(t, 0), 1)
        return clamped * clamped * clamped
    }

    private func pseudoRandom(row: Int, column: Int) -> Double {
        var hasher = Hasher()
        hasher.combine(row)
        hasher.combine(column)
        let hash = hasher.finalize()
        let positive = UInt64(bitPattern: Int64(hash))
        let normalized = Double(positive % 10_000) / 10_000
        return min(max(normalized, 0), 1)
    }
}

private struct GridMetrics {
    let columns: Int
    let rows: Int
    let spacing: CGFloat
    let cellSize: CGSize

    init(size: CGSize, preferredColumnWidth: CGFloat, spacing: CGFloat) {
        let sanitizedSpacing = max(spacing, 0)
        let minWidth = max(preferredColumnWidth, 1)
        let potentialColumns = Int((size.width + sanitizedSpacing) / (minWidth + sanitizedSpacing))
        let resolvedColumns = max(potentialColumns, 1)

        let totalSpacing = sanitizedSpacing * CGFloat(resolvedColumns - 1)
        let width = (size.width - totalSpacing) / CGFloat(resolvedColumns)
        let height = width * 0.72

        let strideY = height + sanitizedSpacing
        let resolvedRows = max(Int(ceil((size.height + sanitizedSpacing) / strideY)), 1)

        columns = resolvedColumns
        rows = resolvedRows
        self.spacing = sanitizedSpacing
        cellSize = CGSize(width: width, height: height)
    }

    func rectForCell(row: Int, column: Int) -> CGRect {
        let origin = CGPoint(
            x: CGFloat(column) * (cellSize.width + spacing),
            y: CGFloat(row) * (cellSize.height + spacing)
        )
        return CGRect(origin: origin, size: cellSize)
    }
}
