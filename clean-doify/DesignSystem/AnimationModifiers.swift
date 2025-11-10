import SwiftUI

public enum ShimmerActivation {
    case cooldown(TimeInterval)
    case manual(isActive: Binding<Bool>)
}

public typealias GridShimmerActivation = ShimmerActivation

public extension View {
    /// Applies a sweeping shimmer overlay that respects motion accessibility settings and can
    /// be auto-looped or triggered manually.
    ///
    /// - Parameters:
    ///   - activation: Strategy controlling how the shimmer is triggered (cooldown or manual binding).
    ///   - tint: Optional base tint. Defaults to ``DesignColor.Surface`` tokens for the active color scheme.
    ///   - highlightTint: Optional highlight tint for the leading shine.
    ///   - cornerRadius: Optional corner radius applied to the shimmer shape.
    ///   - shimmerWidthRatio: Relative width of the sweeping highlight compared to the container width.
    ///   - animationDuration: Duration of a full sweep cycle.
    /// - Returns: A view with a horizontal shimmer sweep that travels from leading to trailing edge.
    ///   When Reduce Motion is enabled the shimmer renders as a static highlight to maintain context
    ///   without animation.
    func shimmer(
        activation: ShimmerActivation = .cooldown(1.4),
        tint: Color? = nil,
        highlightTint: Color? = nil,
        cornerRadius: CGFloat? = nil,
        shimmerWidthRatio: CGFloat = 0.55,
        animationDuration: TimeInterval = 1.35
    ) -> some View {
        modifier(
            ShimmerModifier(
                activation: activation,
                tint: tint,
                highlightTint: highlightTint,
                cornerRadius: cornerRadius,
                shimmerWidthRatio: max(0.2, min(shimmerWidthRatio, 1.2)),
                animationDuration: max(animationDuration, 0.1)
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
    /// - Returns: A view masked with a shimmering grid effect featuring randomized stroke directions
    ///   and pulsing intersection dots. When Reduce Motion is enabled the shimmer remains static while
    ///   still conveying affordance.
    func gridShimmer(
        activation: GridShimmerActivation = .cooldown(1.5),
        preferredColumnWidth: CGFloat = 120,
        spacing: CGFloat = DesignSystem.Spacing.tight.value,
        cornerRadius: CGFloat = DesignSystem.CornerRadius.md.value,
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

private struct ShimmerModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let activation: ShimmerActivation
    let tint: Color?
    let highlightTint: Color?
    let cornerRadius: CGFloat?
    let shimmerWidthRatio: CGFloat
    let animationDuration: TimeInterval

    func body(content: Content) -> some View {
        content.overlay {
            ShimmerOverlay(
                activation: activation,
                tint: tint ?? DesignColor.Surface.muted.opacity(0.55),
                highlightTint: highlightTint ?? DesignColor.Surface.card,
                cornerRadius: cornerRadius,
                shimmerWidthRatio: shimmerWidthRatio,
                animationDuration: animationDuration,
                reduceMotion: reduceMotion
            )
            .mask(content)
        }
    }
}

private struct ShimmerOverlay: View {
    let activation: ShimmerActivation
    let tint: Color
    let highlightTint: Color
    let cornerRadius: CGFloat?
    let shimmerWidthRatio: CGFloat
    let animationDuration: TimeInterval
    let reduceMotion: Bool

    @State private var cycleStartTime: TimeInterval?
    @State private var nextScheduledStart: TimeInterval?

    var body: some View {
        GeometryReader { proxy in
            Group {
                if reduceMotion {
                    ShimmerCanvas(
                        tint: tint,
                        highlightTint: highlightTint,
                        cornerRadius: cornerRadius,
                        shimmerWidthRatio: shimmerWidthRatio,
                        phase: 0.5,
                        isAnimating: false
                    )
                } else {
                    TimelineView(.animation) { timeline in
                        let progress = animationProgress(for: timeline.date)

                        ShimmerCanvas(
                            tint: tint,
                            highlightTint: highlightTint,
                            cornerRadius: cornerRadius,
                            shimmerWidthRatio: shimmerWidthRatio,
                            phase: progress ?? 0,
                            isAnimating: progress != nil
                        )
                    }
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
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

private struct ShimmerCanvas: View {
    let tint: Color
    let highlightTint: Color
    let cornerRadius: CGFloat?
    let shimmerWidthRatio: CGFloat
    let phase: Double
    let isAnimating: Bool

    var body: some View {
        Canvas { context, size in
            guard size.width > 0, size.height > 0 else { return }

            let rect = CGRect(origin: .zero, size: size)
            let basePath = path(for: rect)

            context.fill(basePath, with: .color(tint))
            context.clip(to: basePath, style: .init(eoFill: false, antialiased: true))

            let clampedPhase = min(max(phase, 0), 1)
            let normalizedPhase = isAnimating ? clampedPhase : 0.5

            let minimumWidth = size.width * 0.35
            let highlightWidth = max(size.width * shimmerWidthRatio, minimumWidth)
            let travelDistance = size.width + highlightWidth
            let xPosition = -highlightWidth + travelDistance * normalizedPhase

            let highlightRect = CGRect(
                x: xPosition,
                y: -size.height * 0.15,
                width: highlightWidth,
                height: size.height * 1.3
            )

            let gradient = Gradient(stops: [
                .init(color: tint.opacity(0), location: 0),
                .init(color: highlightTint.opacity(0.22), location: 0.3),
                .init(color: highlightTint.opacity(0.7), location: 0.5),
                .init(color: highlightTint.opacity(0.22), location: 0.72),
                .init(color: tint.opacity(0), location: 1)
            ])

            let start = CGPoint(x: highlightRect.minX, y: highlightRect.midY)
            let end = CGPoint(x: highlightRect.maxX, y: highlightRect.midY)
            let highlightPath = Path(highlightRect)

            context.drawLayer { layer in
                layer.fill(highlightPath, with: .linearGradient(gradient, startPoint: start, endPoint: end))
            }

            let overlayOpacity = isAnimating ? 0.08 : 0.12
            context.fill(basePath, with: .color(highlightTint.opacity(overlayOpacity)))
        }
    }

    private func path(for rect: CGRect) -> Path {
        if let cornerRadius {
            return Path(roundedRect: rect, cornerRadius: cornerRadius)
        }
        return Path(rect)
    }
}

private enum GridLineOrientation {
    case horizontal
    case vertical
    case leadingDiagonal
    case trailingDiagonal
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
                baseColor: DesignColor.Surface.muted,
                highlightColor: DesignColor.Surface.card,
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

            let normalizedPhase = max(0, min(phase, 1))

            let baseStrokeStyle = StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
            let highlightStrokeStyle = StrokeStyle(
                lineWidth: max(lineWidth * 0.85, 1),
                lineCap: .round,
                lineJoin: .round
            )

            for row in 0..<metrics.rows {
                for column in 0..<metrics.columns {
                    let rect = metrics.rectForCell(row: row, column: column)
                    guard rect.width > 0, rect.height > 0 else { continue }

                    let basePath = Path(roundedRect: rect, cornerRadius: cornerRadius)
                    context.fill(basePath, with: .color(baseColor.opacity(0.22)))
                    context.stroke(basePath, with: .color(baseColor.opacity(0.33)), style: baseStrokeStyle)

                    let progress = isAnimating
                        ? strokeProgress(for: row, column: column, normalizedPhase: normalizedPhase, metrics: metrics)
                        : 0.65

                    guard progress > 0 else { continue }

                    let orientation = highlightOrientation(for: row, column: column)
                    let reversed = highlightDirectionIsReversed(for: row, column: column)

                    if let highlightPath = highlightPath(
                        in: rect,
                        cornerRadius: cornerRadius,
                        orientation: orientation,
                        reversed: reversed,
                        progress: progress
                    ) {
                        let opacity = highlightOpacity(for: progress)
                        context.stroke(
                            highlightPath,
                            with: .color(highlightColor.opacity(opacity)),
                            style: highlightStrokeStyle
                        )
                    }
                }
            }

            drawIntersectionDots(
                context: &context,
                metrics: metrics,
                normalizedPhase: normalizedPhase,
                isAnimating: isAnimating,
                lineWidth: lineWidth
            )
        }
    }

    private func strokeProgress(for row: Int, column: Int, normalizedPhase: Double, metrics: GridMetrics) -> Double {
        let startDelay = cellStartDelay(for: row, column: column, metrics: metrics)
        guard normalizedPhase >= startDelay else { return 0 }

        let active = min((normalizedPhase - startDelay) / max(1 - startDelay, 0.0001), 1)

        let durationNoise = pseudoRandom(row: row, column: column, salt: 11)
        let drawInRaw = lerp(min: 0.32, max: 0.52, t: durationNoise)
        let holdRaw = 0.22
        let fadeRaw = 0.28
        let total = drawInRaw + holdRaw + fadeRaw
        let drawInDuration = drawInRaw / total
        let holdDuration = holdRaw / total
        let fadeOutDuration = fadeRaw / total

        if active < drawInDuration {
            let drawProgress = active / max(drawInDuration, 0.0001)
            return min(easeOutCubic(drawProgress), 1)
        }

        if active < drawInDuration + holdDuration {
            return 1
        }

        let drawOutProgress = (active - drawInDuration - holdDuration) / max(fadeOutDuration, 0.0001)
        return max(1 - easeInCubic(drawOutProgress), 0)
    }

    private func cellStartDelay(for row: Int, column: Int, metrics: GridMetrics) -> Double {
        let randomOffset = pseudoRandom(row: row, column: column, salt: 5) * 0.25
        let rowFraction = metrics.rows > 1 ? Double(row) / Double(metrics.rows - 1) : 0
        let columnFraction = metrics.columns > 1 ? Double(column) / Double(metrics.columns - 1) : 0
        let positionalBias = (rowFraction * 0.18) + (columnFraction * 0.12)
        return min(randomOffset + positionalBias, 0.85)
    }

    private func highlightOrientation(for row: Int, column: Int) -> GridLineOrientation {
        let value = pseudoRandom(row: row, column: column, salt: 17)
        switch value {
        case ..<0.25:
            return .horizontal
        case ..<0.5:
            return .vertical
        case ..<0.75:
            return .leadingDiagonal
        default:
            return .trailingDiagonal
        }
    }

    private func highlightDirectionIsReversed(for row: Int, column: Int) -> Bool {
        pseudoRandom(row: row, column: column, salt: 23) > 0.5
    }

    private func highlightPath(
        in rect: CGRect,
        cornerRadius: CGFloat,
        orientation: GridLineOrientation,
        reversed: Bool,
        progress: Double
    ) -> Path? {
        let clamped = min(max(progress, 0), 1)
        guard clamped > 0 else { return nil }

        let baseInsetX = min(rect.width * 0.18, rect.width / 3)
        let baseInsetY = min(rect.height * 0.2, rect.height / 3)
        let radiusInset = max(cornerRadius * 0.6, 0)
        let insetX = max(baseInsetX, radiusInset)
        let insetY = max(baseInsetY, radiusInset)

        var start: CGPoint
        var end: CGPoint

        switch orientation {
        case .horizontal:
            start = CGPoint(x: rect.minX + insetX, y: rect.midY)
            end = CGPoint(x: rect.maxX - insetX, y: rect.midY)
        case .vertical:
            start = CGPoint(x: rect.midX, y: rect.minY + insetY)
            end = CGPoint(x: rect.midX, y: rect.maxY - insetY)
        case .leadingDiagonal:
            let inset = max(insetX, insetY)
            start = CGPoint(x: rect.minX + inset, y: rect.minY + inset)
            end = CGPoint(x: rect.maxX - inset, y: rect.maxY - inset)
        case .trailingDiagonal:
            let inset = max(insetX, insetY)
            start = CGPoint(x: rect.minX + inset, y: rect.maxY - inset)
            end = CGPoint(x: rect.maxX - inset, y: rect.minY + inset)
        }

        if reversed {
            swap(&start, &end)
        }

        let dx = end.x - start.x
        let dy = end.y - start.y
        let currentEnd = CGPoint(
            x: start.x + dx * CGFloat(clamped),
            y: start.y + dy * CGFloat(clamped)
        )

        guard start != currentEnd else { return nil }

        var path = Path()
        path.move(to: start)
        path.addLine(to: currentEnd)
        return path
    }

    private func highlightOpacity(for progress: Double) -> Double {
        0.28 + (0.52 * min(max(progress, 0), 1))
    }

    private func drawIntersectionDots(
        context: inout GraphicsContext,
        metrics: GridMetrics,
        normalizedPhase: Double,
        isAnimating: Bool,
        lineWidth: CGFloat
    ) {
        let baseRadius = max(lineWidth * 0.9, 1.1)

        for row in 0...metrics.rows {
            for column in 0...metrics.columns {
                let pulse = isAnimating
                    ? dotPulse(for: row, column: column, normalizedPhase: normalizedPhase, metrics: metrics)
                    : 0.55

                guard pulse > 0 else { continue }

                let center = metrics.intersectionPoint(row: row, column: column)
                let radius = baseRadius * (0.6 + 0.8 * CGFloat(pulse))
                let rect = CGRect(
                    x: center.x - radius,
                    y: center.y - radius,
                    width: radius * 2,
                    height: radius * 2
                )

                let opacity = 0.18 + (0.55 * pulse)
                context.fill(Path(ellipseIn: rect), with: .color(highlightColor.opacity(opacity)))
            }
        }
    }

    private func dotPulse(
        for row: Int,
        column: Int,
        normalizedPhase: Double,
        metrics: GridMetrics
    ) -> Double {
        let neighboringCells = [
            (row - 1, column - 1),
            (row - 1, column),
            (row, column - 1),
            (row, column)
        ]

        var delays: [Double] = []
        delays.reserveCapacity(neighboringCells.count)

        for (neighborRow, neighborColumn) in neighboringCells where metrics.containsCell(row: neighborRow, column: neighborColumn) {
            delays.append(cellStartDelay(for: neighborRow, column: neighborColumn, metrics: metrics))
        }

        let baseDelay = delays.isEmpty ? 0 : delays.reduce(0, +) / Double(delays.count)
        let randomOffset = pseudoRandom(row: row, column: column, salt: 29) * 0.12
        let effectiveDelay = min(baseDelay + randomOffset, 0.92)

        guard normalizedPhase >= effectiveDelay else { return 0 }

        let active = min((normalizedPhase - effectiveDelay) / max(1 - effectiveDelay, 0.0001), 1)
        let riseDuration = 0.35
        let fadeDuration = 0.45

        if active < riseDuration {
            let rise = active / max(riseDuration, 0.0001)
            return easeOutCubic(rise)
        }

        if active < riseDuration + fadeDuration {
            let fade = (active - riseDuration) / max(fadeDuration, 0.0001)
            return max(1 - easeInCubic(fade), 0)
        }

        return 0
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

    private func pseudoRandom(row: Int, column: Int, salt: Int) -> Double {
        var hasher = Hasher()
        hasher.combine(row)
        hasher.combine(column)
        hasher.combine(salt)
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
    let canvasSize: CGSize

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
        canvasSize = size
    }

    func rectForCell(row: Int, column: Int) -> CGRect {
        let origin = CGPoint(
            x: CGFloat(column) * (cellSize.width + spacing),
            y: CGFloat(row) * (cellSize.height + spacing)
        )
        return CGRect(origin: origin, size: cellSize)
    }

    func containsCell(row: Int, column: Int) -> Bool {
        row >= 0 && row < rows && column >= 0 && column < columns
    }

    func intersectionPoint(row: Int, column: Int) -> CGPoint {
        let strideX = cellSize.width + spacing
        let strideY = cellSize.height + spacing

        let rawX = CGFloat(column) * strideX - (column == 0 ? 0 : spacing)
        let rawY = CGFloat(row) * strideY - (row == 0 ? 0 : spacing)

        let clampedX = min(max(rawX, 0), canvasSize.width)
        let clampedY = min(max(rawY, 0), canvasSize.height)

        return CGPoint(x: clampedX, y: clampedY)
    }
}
