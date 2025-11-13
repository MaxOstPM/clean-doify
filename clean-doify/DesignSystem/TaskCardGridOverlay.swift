import SwiftUI

/// A CAD-inspired grid overlay that animates whenever a task status transitions.
///
/// The overlay renders a matrix of horizontal and vertical lines that scale in
/// with staggered delays, optionally pulsing intersection dots for additional
/// feedback. The animation respects Reduce Motion by falling back to a subtle
/// border flash.
public struct TaskCardGridOverlay: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public let statusColor: Color
    public let isActive: Bool
    public var cornerRadius: CGFloat
    public var lineSpacing: CGFloat
    public var lineOpacity: Double
    public var lineThickness: CGFloat
    public var blurRadius: CGFloat
    public var glowRadius: CGFloat
    public var showsIntersections: Bool
    public var intersectionOpacity: Double
    public var intersectionSize: CGFloat
    public var animationDuration: TimeInterval

    @State private var gridMetrics: GridMetrics?
    @State private var lineConfigs: [GridLineConfiguration] = []
    @State private var intersectionConfigs: [IntersectionConfiguration] = []
    @State private var animationTrigger = UUID()
    @State private var cachedSize: CGSize = .zero
    @State private var borderFlashOpacity: Double = 0

    private let timing: GridAnimationTiming

    public init(
        statusColor: Color,
        isActive: Bool,
        cornerRadius: CGFloat = DesignSystem.CornerRadius.xl.value,
        lineSpacing: CGFloat = 24,
        lineOpacity: Double = 0.28,
        lineThickness: CGFloat = 1,
        blurRadius: CGFloat = 0.8,
        glowRadius: CGFloat = 2.5,
        showsIntersections: Bool = true,
        intersectionOpacity: Double = 0.75,
        intersectionSize: CGFloat = 3,
        animationDuration: TimeInterval = 2.6
    ) {
        self.statusColor = statusColor
        self.isActive = isActive
        self.cornerRadius = cornerRadius
        self.lineSpacing = lineSpacing
        self.lineOpacity = lineOpacity
        self.lineThickness = lineThickness
        self.blurRadius = blurRadius
        self.glowRadius = glowRadius
        self.showsIntersections = showsIntersections
        self.intersectionOpacity = intersectionOpacity
        self.intersectionSize = intersectionSize
        let resolvedDuration = max(animationDuration, 1.6)
        self.animationDuration = resolvedDuration
        self.timing = GridAnimationTiming(totalDuration: resolvedDuration)
    }

    public var body: some View {
        GeometryReader { proxy in
            ZStack {
                if reduceMotion {
                    borderFlashOverlay
                } else {
                    gridOverlay
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .onChange(of: proxy.size, perform: handleSizeChange)
            .onAppear {
                cachedSize = proxy.size
                if isActive {
                    triggerAnimation(for: proxy.size)
                }
            }
            .onChange(of: isActive) { newValue in
                guard newValue else { return }
                triggerAnimation(for: proxy.size)
            }
            .onChange(of: reduceMotion) { newValue in
                if newValue {
                    clearGrid()
                } else if isActive {
                    triggerAnimation(for: proxy.size)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .allowsHitTesting(false)
    }

    private var gridOverlay: some View {
        Group {
            if let metrics = gridMetrics {
                ZStack(alignment: .topLeading) {
                    ForEach(horizontalLineConfigs) { config in
                        AnimatedGridLine(
                            config: config,
                            length: metrics.size.width,
                            thickness: lineThickness,
                            axisPosition: position(for: config.index, count: metrics.horizontalCount, maxLength: metrics.size.height),
                            color: statusColor.opacity(lineOpacity),
                            blurRadius: blurRadius,
                            glowRadius: glowRadius,
                            fadeOutDelay: timing.fadeOutDelay,
                            fadeOutDuration: timing.fadeOutDuration,
                            animationTrigger: animationTrigger
                        )
                    }

                    ForEach(verticalLineConfigs) { config in
                        AnimatedGridLine(
                            config: config,
                            length: metrics.size.height,
                            thickness: lineThickness,
                            axisPosition: position(for: config.index, count: metrics.verticalCount, maxLength: metrics.size.width),
                            color: statusColor.opacity(lineOpacity),
                            blurRadius: blurRadius,
                            glowRadius: glowRadius,
                            fadeOutDelay: timing.fadeOutDelay,
                            fadeOutDuration: timing.fadeOutDuration,
                            animationTrigger: animationTrigger
                        )
                    }

                    if showsIntersections {
                        ForEach(intersectionConfigs) { config in
                            IntersectionDot(
                                config: config,
                                metrics: metrics,
                                dotSize: intersectionSize,
                                color: statusColor,
                                opacity: intersectionOpacity,
                                animationTrigger: animationTrigger
                            )
                        }
                    }
                }
            }
        }
    }

    private var borderFlashOverlay: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .stroke(statusColor.opacity(0.4), lineWidth: max(lineThickness, 2))
            .opacity(borderFlashOpacity)
            .onAppear {
                if isActive {
                    playBorderFlash()
                }
            }
            .onChange(of: isActive) { newValue in
                guard newValue else { return }
                playBorderFlash()
            }
    }

    private func playBorderFlash() {
        borderFlashOpacity = 1
        withAnimation(.easeOut(duration: 0.35)) {
            borderFlashOpacity = 0
        }
    }

    private func handleSizeChange(_ newSize: CGSize) {
        guard newSize != cachedSize else { return }
        cachedSize = newSize
        if isActive {
            triggerAnimation(for: newSize)
        }
    }

    private func triggerAnimation(for size: CGSize) {
        guard !reduceMotion, size.width > 0, size.height > 0 else { return }

        let spacing = max(lineSpacing, 8)
        let horizontalCount = max(2, Int((size.height / spacing).rounded(.down)))
        let verticalCount = max(2, Int((size.width / spacing).rounded(.down)))

        let metrics = GridMetrics(size: size, horizontalCount: horizontalCount, verticalCount: verticalCount)
        let configs = generateLineConfigs(with: metrics)
        gridMetrics = metrics
        lineConfigs = configs

        if showsIntersections {
            intersectionConfigs = generateIntersectionConfigs(using: metrics, lineConfigs: configs)
        } else {
            intersectionConfigs = []
        }

        animationTrigger = UUID()
        scheduleCleanup()
    }

    private func clearGrid() {
        lineConfigs = []
        intersectionConfigs = []
    }

    private func scheduleCleanup() {
        let runID = animationTrigger
        DispatchQueue.main.asyncAfter(deadline: .now() + timing.totalDuration) {
            guard runID == animationTrigger else { return }
            clearGrid()
        }
    }

    private func generateLineConfigs(with metrics: GridMetrics) -> [GridLineConfiguration] {
        var configs: [GridLineConfiguration] = []

        for index in 0..<metrics.horizontalCount {
            let delay = Double.random(in: 0...timing.maxLineDelay)
            let duration = Double.random(in: timing.minLineDuration...timing.maxLineDuration)
            configs.append(
                GridLineConfiguration(
                    orientation: .horizontal,
                    index: index,
                    delay: delay,
                    duration: duration,
                    fromLeadingOrTop: Bool.random()
                )
            )
        }

        for index in 0..<metrics.verticalCount {
            let delay = Double.random(in: 0...timing.maxLineDelay)
            let duration = Double.random(in: timing.minLineDuration...timing.maxLineDuration)
            configs.append(
                GridLineConfiguration(
                    orientation: .vertical,
                    index: index,
                    delay: delay,
                    duration: duration,
                    fromLeadingOrTop: Bool.random()
                )
            )
        }

        return configs
    }

    private func generateIntersectionConfigs(using metrics: GridMetrics, lineConfigs: [GridLineConfiguration]) -> [IntersectionConfiguration] {
        let horizontal = lineConfigs.filter { $0.orientation == .horizontal }
        let vertical = lineConfigs.filter { $0.orientation == .vertical }
        let minDotDuration = max(0.25, timing.fadeOutDuration * 0.35)
        let maxDotDuration = max(minDotDuration + 0.1, timing.fadeOutDuration * 0.65)

        var intersections: [IntersectionConfiguration] = []
        for hLine in horizontal {
            for vLine in vertical {
                let lineArrival = max(hLine.endTime, vLine.endTime)
                let jitter = Double.random(in: 0...0.15)
                let duration = Double.random(in: minDotDuration...maxDotDuration)
                intersections.append(
                    IntersectionConfiguration(
                        rowIndex: hLine.index,
                        columnIndex: vLine.index,
                        delay: lineArrival + jitter,
                        duration: duration
                    )
                )
            }
        }

        return intersections
    }

    private var horizontalLineConfigs: [GridLineConfiguration] {
        lineConfigs.filter { $0.orientation == .horizontal }.sorted { $0.index < $1.index }
    }

    private var verticalLineConfigs: [GridLineConfiguration] {
        lineConfigs.filter { $0.orientation == .vertical }.sorted { $0.index < $1.index }
    }

    private func position(for index: Int, count: Int, maxLength: CGFloat) -> CGFloat {
        guard count > 0 else { return maxLength / 2 }
        let step = maxLength / CGFloat(count + 1)
        return step * CGFloat(index + 1)
    }
}

private struct GridMetrics: Equatable {
    let size: CGSize
    let horizontalCount: Int
    let verticalCount: Int
}

private struct GridAnimationTiming {
    let totalDuration: TimeInterval
    let maxLineDelay: TimeInterval
    let minLineDuration: TimeInterval
    let maxLineDuration: TimeInterval
    let fadeOutDelay: TimeInterval
    let fadeOutDuration: TimeInterval

    init(totalDuration: TimeInterval) {
        let safeTotal = max(totalDuration, 1.6)
        let maxDelay = safeTotal * 0.3

        var fadeDuration = max(0.5, safeTotal * 0.45)
        if fadeDuration >= safeTotal {
            fadeDuration = safeTotal * 0.7
        }

        var fadeDelay = safeTotal - fadeDuration
        if fadeDelay < safeTotal * 0.45 {
            fadeDelay = safeTotal * 0.55
            fadeDuration = safeTotal - fadeDelay
        }

        let growthWindow = max(fadeDelay - maxDelay, 0.3)
        let minDuration = max(0.18, growthWindow * 0.35)
        let maxDuration = max(minDuration + 0.08, growthWindow * 0.65)

        self.totalDuration = safeTotal
        self.maxLineDelay = maxDelay
        self.minLineDuration = minDuration
        self.maxLineDuration = maxDuration
        self.fadeOutDelay = fadeDelay
        self.fadeOutDuration = fadeDuration
    }
}

private struct GridLineConfiguration: Identifiable, Equatable {
    enum Orientation {
        case horizontal
        case vertical
    }

    let id = UUID()
    let orientation: Orientation
    let index: Int
    let delay: TimeInterval
    let duration: TimeInterval
    let fromLeadingOrTop: Bool

    var endTime: TimeInterval { delay + duration }
}

private struct IntersectionConfiguration: Identifiable, Equatable {
    let id = UUID()
    let rowIndex: Int
    let columnIndex: Int
    let delay: TimeInterval
    let duration: TimeInterval
}

private struct AnimatedGridLine: View {
    let config: GridLineConfiguration
    let length: CGFloat
    let thickness: CGFloat
    let axisPosition: CGFloat
    let color: Color
    let blurRadius: CGFloat
    let glowRadius: CGFloat
    let fadeOutDelay: TimeInterval
    let fadeOutDuration: TimeInterval
    let animationTrigger: UUID

    @State private var progress: CGFloat = 0
    @State private var opacity: Double = 0
    @State private var collapseProgress: CGFloat = 0

    var body: some View {
        Rectangle()
            .fill(color)
            .frame(
                width: config.orientation == .horizontal ? length : thickness,
                height: config.orientation == .horizontal ? thickness : length
            )
            .scaleEffect(
                x: config.orientation == .horizontal ? progress : 1,
                y: config.orientation == .horizontal ? 1 : progress,
                anchor: scaleAnchor
            )
            .scaleEffect(1 - 0.12 * collapseProgress)
            .opacity(opacity)
            .blur(radius: blurRadius)
            .shadow(color: color.opacity(0.8), radius: glowRadius)
            .offset(x: config.orientation == .horizontal ? 0 : axisPosition - thickness / 2,
                    y: config.orientation == .horizontal ? axisPosition - thickness / 2 : 0)
            .onAppear(perform: startIfNeeded)
            .onChange(of: animationTrigger) { _ in startIfNeeded() }
    }

    private var scaleAnchor: UnitPoint {
        switch config.orientation {
        case .horizontal:
            return config.fromLeadingOrTop ? .leading : .trailing
        case .vertical:
            return config.fromLeadingOrTop ? .top : .bottom
        }
    }

    private func startIfNeeded() {
        guard length > 0 else { return }
        progress = 0
        opacity = 0
        collapseProgress = 0
        let runID = animationTrigger

        DispatchQueue.main.asyncAfter(deadline: .now() + config.delay) {
            guard runID == animationTrigger else { return }
            withAnimation(.easeOut(duration: config.duration)) {
                progress = 1
                opacity = 1
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + fadeOutDelay) {
            guard runID == animationTrigger else { return }
            withAnimation(.easeIn(duration: fadeOutDuration)) {
                collapseProgress = 1
                opacity = 0
            }
        }
    }
}

private struct IntersectionDot: View {
    let config: IntersectionConfiguration
    let metrics: GridMetrics
    let dotSize: CGFloat
    let color: Color
    let opacity: Double
    let animationTrigger: UUID

    @State private var dotOpacity: Double = 0

    var body: some View {
        Circle()
            .fill(color.opacity(opacity))
            .frame(width: dotSize, height: dotSize)
            .shadow(color: color.opacity(opacity), radius: dotSize)
            .offset(x: xPosition - dotSize / 2, y: yPosition - dotSize / 2)
            .opacity(dotOpacity)
            .onAppear(perform: startIfNeeded)
            .onChange(of: animationTrigger) { _ in startIfNeeded() }
    }

    private var xPosition: CGFloat {
        position(for: config.columnIndex, count: metrics.verticalCount, maxLength: metrics.size.width)
    }

    private var yPosition: CGFloat {
        position(for: config.rowIndex, count: metrics.horizontalCount, maxLength: metrics.size.height)
    }

    private func startIfNeeded() {
        dotOpacity = 0
        let runID = animationTrigger

        DispatchQueue.main.asyncAfter(deadline: .now() + config.delay) {
            guard runID == animationTrigger else { return }
            withAnimation(.easeOut(duration: config.duration * 0.45)) {
                dotOpacity = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + config.duration * 0.55) {
                guard runID == animationTrigger else { return }
                withAnimation(.easeIn(duration: config.duration * 0.55)) {
                    dotOpacity = 0
                }
            }
        }
    }

    private func position(for index: Int, count: Int, maxLength: CGFloat) -> CGFloat {
        guard count > 0 else { return maxLength / 2 }
        let step = maxLength / CGFloat(count + 1)
        return step * CGFloat(index + 1)
    }
}
