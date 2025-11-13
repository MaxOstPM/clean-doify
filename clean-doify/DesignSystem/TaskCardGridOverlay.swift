import SwiftUI

/// A CAD-inspired grid overlay that animates whenever a task status transitions.
///
/// The overlay renders a matrix of horizontal and vertical lines that scale in
/// with staggered delays before collapsing with chaotic fade-outs for
/// additional feedback. The animation respects Reduce Motion by falling back
/// to a subtle border flash.
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
    public var animationDuration: TimeInterval

    @State private var gridMetrics: GridMetrics?
    @State private var lineConfigs: [GridLineConfiguration] = []
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
        animationDuration: TimeInterval = 8.0
    ) {
        self.statusColor = statusColor
        self.isActive = isActive
        self.cornerRadius = cornerRadius
        self.lineSpacing = lineSpacing
        self.lineOpacity = lineOpacity
        self.lineThickness = lineThickness
        self.blurRadius = blurRadius
        self.glowRadius = glowRadius
        self.animationDuration = animationDuration
        self.timing = GridAnimationTiming(totalDuration: animationDuration)
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
                            animationTrigger: animationTrigger
                        )
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

        animationTrigger = UUID()
        scheduleCleanup()
    }

    private func clearGrid() {
        lineConfigs = []
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

        func appendConfig(orientation: GridLineConfiguration.Orientation, index: Int) {
            let delay = Double.random(in: 0...timing.maxLineDelay)
            let duration = Double.random(in: timing.minLineDuration...timing.maxLineDuration)
            let completion = delay + duration
            let baseCollapseStart = max(completion + 0.05, timing.minCollapseDelay)
            let latestPossibleStart = timing.totalDuration - timing.minCollapseDuration
            let collapseCeiling = latestPossibleStart > baseCollapseStart
                ? min(baseCollapseStart + timing.collapseDelayVariance, latestPossibleStart)
                : baseCollapseStart
            let collapseDelay: TimeInterval
            if collapseCeiling > baseCollapseStart {
                collapseDelay = Double.random(in: baseCollapseStart...collapseCeiling)
            } else {
                collapseDelay = baseCollapseStart
            }

            var collapseDuration = Double.random(in: timing.minCollapseDuration...timing.maxCollapseDuration)
            let availableDuration = max(0, timing.totalDuration - collapseDelay)
            if availableDuration > 0 {
                collapseDuration = min(collapseDuration, availableDuration)
            } else {
                collapseDuration = 0
            }

            configs.append(
                GridLineConfiguration(
                    orientation: orientation,
                    index: index,
                    delay: delay,
                    duration: duration,
                    fromLeadingOrTop: Bool.random(),
                    collapseDelay: collapseDelay,
                    collapseDuration: collapseDuration
                )
            )
        }

        for index in 0..<metrics.horizontalCount {
            appendConfig(orientation: .horizontal, index: index)
        }

        for index in 0..<metrics.verticalCount {
            appendConfig(orientation: .vertical, index: index)
        }

        return configs
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
    let minCollapseDelay: TimeInterval
    let collapseDelayVariance: TimeInterval
    let minCollapseDuration: TimeInterval
    let maxCollapseDuration: TimeInterval

    init(totalDuration: TimeInterval) {
        let safeTotal = max(totalDuration, 2.0)
        let maxLineDelay = safeTotal * 0.15
        let growthWindow = safeTotal * 0.35
        let minDuration = max(0.1, growthWindow * 0.4)
        let maxDuration = max(minDuration + 0.05, growthWindow)
        let collapseDelay = safeTotal * 0.25
        let collapseVariance = safeTotal * 0.3
        let minCollapseDuration = max(0.15, safeTotal * 0.12)
        let maxCollapseDuration = max(minCollapseDuration + 0.1, safeTotal * 0.35)

        self.totalDuration = safeTotal
        self.maxLineDelay = maxLineDelay
        self.minLineDuration = minDuration
        self.maxLineDuration = maxDuration
        self.minCollapseDelay = collapseDelay
        self.collapseDelayVariance = collapseVariance
        self.minCollapseDuration = minCollapseDuration
        self.maxCollapseDuration = maxCollapseDuration
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
    let collapseDelay: TimeInterval
    let collapseDuration: TimeInterval

}

private struct AnimatedGridLine: View {
    let config: GridLineConfiguration
    let length: CGFloat
    let thickness: CGFloat
    let axisPosition: CGFloat
    let color: Color
    let blurRadius: CGFloat
    let glowRadius: CGFloat
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

        DispatchQueue.main.asyncAfter(deadline: .now() + config.collapseDelay) {
            guard runID == animationTrigger else { return }
            withAnimation(.easeIn(duration: config.collapseDuration)) {
                collapseProgress = 1
                opacity = 0
            }
        }
    }
}

