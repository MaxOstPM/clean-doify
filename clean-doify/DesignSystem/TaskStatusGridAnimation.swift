import SwiftUI
import UIKit

/// Technical grid animation that fires when a task's status changes.
/// The overlay draws a CAD-inspired grid, glows the intersections, and
/// converges inward before fading out. It respects Reduce Motion by
/// rendering a static grid while still auto-clearing the binding after the
/// prescribed lifecycle (~2 seconds).
public struct TaskStatusGridAnimation: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @Binding private var isActive: Bool

    private let statusColor: Color
    private let cornerRadius: CGFloat

    @State private var animationStartTime: TimeInterval?
    @State private var configuration = GridAnimationConfiguration.randomized()
    @State private var completionTask: Task<Void, Never>?

    private var pixelLineWidth: CGFloat { max(1 / UIScreen.main.scale, 0.5) }

    public init(
        isActive: Binding<Bool>,
        statusColor: Color,
        cornerRadius: CGFloat = DesignSystem.CornerRadius.md.value
    ) {
        _isActive = isActive
        self.statusColor = statusColor
        self.cornerRadius = cornerRadius
    }

    public var body: some View {
        ZStack {
            if reduceMotion {
                if isActive {
                    Canvas { context, size in
                        renderFrame(
                            elapsed: TaskStatusGridAnimationConstants.staticPreviewTime,
                            in: &context,
                            size: size,
                            isStaticPreview: true
                        )
                    }
                    .transition(.opacity)
                }
            } else if animationStartTime != nil {
                TimelineView(.animation) { timeline in
                    let date = timeline.date
                    Canvas { context, size in
                        renderAnimatedFrame(at: date, in: &context, size: size)
                    }
                }
                .transition(.opacity)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .allowsHitTesting(false)
        .onAppear {
            if isActive {
                startAnimation()
            }
        }
        .onDisappear { stopAnimation(resetBinding: false) }
        .onChange(of: isActive) { newValue in
            if newValue {
                startAnimation()
            } else {
                stopAnimation(resetBinding: false)
            }
        }
        .onChange(of: reduceMotion) { _ in
            if isActive {
                startAnimation()
            }
        }
    }

    private func renderAnimatedFrame(
        at date: Date,
        in context: inout GraphicsContext,
        size: CGSize
    ) {
        guard let start = animationStartTime else { return }
        let elapsed = date.timeIntervalSinceReferenceDate - start
        guard elapsed <= TaskStatusGridAnimationConstants.totalDuration else { return }
        renderFrame(elapsed: elapsed, in: &context, size: size, isStaticPreview: false)
    }

    private func renderFrame(
        elapsed: Double,
        in context: inout GraphicsContext,
        size: CGSize,
        isStaticPreview: Bool
    ) {
        guard size.width > 0, size.height > 0 else { return }

        var drawingContext = context
        drawingContext.addFilter(.shadow(color: statusColor.opacity(0.28), radius: 1, x: 0, y: 0))

        let clampedElapsed = min(max(elapsed, 0), TaskStatusGridAnimationConstants.totalDuration)
        let convergence = isStaticPreview ? 0 : convergenceProgress(for: clampedElapsed)

        for descriptor in configuration.horizontalLines + configuration.verticalLines {
            let progress = lineProgress(for: descriptor, elapsed: clampedElapsed, isStaticPreview: isStaticPreview)
            guard progress > 0, let segment = lineSegment(
                for: descriptor,
                progress: progress,
                convergence: convergence,
                size: size
            ) else { continue }

            var path = Path()
            path.move(to: segment.start)
            path.addLine(to: segment.end)

            let opacity = lineOpacity(progress: progress, convergence: convergence)
            drawingContext.stroke(path, with: .color(statusColor.opacity(opacity)), lineWidth: pixelLineWidth)
        }

        drawIntersections(
            in: &context,
            size: size,
            elapsed: clampedElapsed,
            convergence: convergence,
            isStaticPreview: isStaticPreview
        )
    }

    private func drawIntersections(
        in context: inout GraphicsContext,
        size: CGSize,
        elapsed: Double,
        convergence: Double,
        isStaticPreview: Bool
    ) {
        let baseRadius = max(pixelLineWidth * 1.4, 1.2)

        for rowIndex in 0..<TaskStatusGridAnimationConstants.horizontalLineCount {
            for columnIndex in 0..<TaskStatusGridAnimationConstants.verticalLineCount {
                let center = intersectionPoint(row: rowIndex, column: columnIndex, size: size)
                let intensity: Double

                if isStaticPreview {
                    intensity = 0.55
                } else {
                    intensity = intersectionGlow(
                        row: rowIndex,
                        column: columnIndex,
                        elapsed: elapsed
                    )
                }

                guard intensity > 0 else { continue }

                let radius = baseRadius * (0.8 + 0.7 * intensity)
                let rect = CGRect(
                    x: center.x - radius,
                    y: center.y - radius,
                    width: radius * 2,
                    height: radius * 2
                )

                var dotContext = context
                dotContext.addFilter(
                    .shadow(
                        color: statusColor.opacity(0.45 * intensity * (1 - convergence)),
                        radius: 2.2,
                        x: 0,
                        y: 0
                    )
                )

                let opacity = min(0.3 + 0.45 * intensity, 0.75) * (isStaticPreview ? 1 : (1 - min(convergence * 1.2, 1)))
                dotContext.fill(Path(ellipseIn: rect), with: .color(statusColor.opacity(opacity)))
            }
        }
    }

    private func lineProgress(
        for descriptor: LineDescriptor,
        elapsed: Double,
        isStaticPreview: Bool
    ) -> Double {
        guard !isStaticPreview else { return 1 }

        if elapsed < descriptor.delay {
            return 0
        }

        if elapsed <= descriptor.delay + descriptor.duration {
            let normalized = (elapsed - descriptor.delay) / descriptor.duration
            return easeOutCubic(normalized)
        }

        return 1
    }

    private func lineSegment(
        for descriptor: LineDescriptor,
        progress: Double,
        convergence: Double,
        size: CGSize
    ) -> LineSegment? {
        guard progress > 0 else { return nil }

        let endpoints = lineEndpoints(for: descriptor, size: size)
        let totalLength: CGFloat
        let axis: Axis.Set

        switch descriptor.orientation {
        case .horizontal:
            totalLength = endpoints.end.x - endpoints.start.x
            axis = .horizontal
        case .vertical:
            totalLength = endpoints.end.y - endpoints.start.y
            axis = .vertical
        }

        guard totalLength > 0 else { return nil }

        let effectiveProgress = min(progress, 1)
        var currentLength = totalLength * CGFloat(effectiveProgress)
        let reachedFullLength = progress >= 1

        if descriptor.direction == .reverse {
            switch axis {
            case .horizontal:
                var start = endpoints.end
                let newStartX = start.x - currentLength
                let endPoint = CGPoint(x: start.x, y: start.y)
                start.x = newStartX
                return adjustedSegment(
                    LineSegment(start: start, end: endPoint),
                    descriptor: descriptor,
                    convergence: convergence,
                    size: size,
                    totalLength: totalLength,
                    reachedFullLength: reachedFullLength
                )
            default:
                var start = endpoints.end
                let newStartY = start.y - currentLength
                let endPoint = CGPoint(x: start.x, y: start.y)
                start.y = newStartY
                return adjustedSegment(
                    LineSegment(start: start, end: endPoint),
                    descriptor: descriptor,
                    convergence: convergence,
                    size: size,
                    totalLength: totalLength,
                    reachedFullLength: reachedFullLength
                )
            }
        } else {
            switch axis {
            case .horizontal:
                var end = endpoints.start
                end.x += currentLength
                return adjustedSegment(
                    LineSegment(start: endpoints.start, end: end),
                    descriptor: descriptor,
                    convergence: convergence,
                    size: size,
                    totalLength: totalLength,
                    reachedFullLength: reachedFullLength
                )
            default:
                var end = endpoints.start
                end.y += currentLength
                return adjustedSegment(
                    LineSegment(start: endpoints.start, end: end),
                    descriptor: descriptor,
                    convergence: convergence,
                    size: size,
                    totalLength: totalLength,
                    reachedFullLength: reachedFullLength
                )
            }
        }
    }

    private func adjustedSegment(
        _ segment: LineSegment,
        descriptor: LineDescriptor,
        convergence: Double,
        size: CGSize,
        totalLength: CGFloat,
        reachedFullLength: Bool
    ) -> LineSegment {
        guard convergence > 0, reachedFullLength else { return segment }

        let shrinkScale = 1 - 0.5 * convergence
        let clampedScale = max(shrinkScale, 0)

        switch descriptor.orientation {
        case .horizontal:
            let centerX = size.width / 2
            let halfLength = totalLength * clampedScale / 2
            let startX = centerX - halfLength
            let endX = centerX + halfLength
            let y = segment.start.y
            return LineSegment(start: CGPoint(x: startX, y: y), end: CGPoint(x: endX, y: y))
        case .vertical:
            let centerY = size.height / 2
            let halfLength = totalLength * clampedScale / 2
            let startY = centerY - halfLength
            let endY = centerY + halfLength
            let x = segment.start.x
            return LineSegment(start: CGPoint(x: x, y: startY), end: CGPoint(x: x, y: endY))
        }
    }

    private func lineOpacity(progress: Double, convergence: Double) -> Double {
        let activeOpacity = TaskStatusGridAnimationConstants.lineOpacityBase + (TaskStatusGridAnimationConstants.lineOpacityPeak * progress)
        let fade = 1 - min(convergence * 0.9, 0.9)
        return min(activeOpacity * fade, 0.9)
    }

    private func intersectionGlow(row: Int, column: Int, elapsed: Double) -> Double {
        let startTime = intersectionTriggerTime(row: row, column: column)
        guard elapsed >= startTime else { return 0 }

        let activeTime = elapsed - startTime
        let riseDuration = TaskStatusGridAnimationConstants.intersectionGlowDuration * 0.4
        let fallDuration = TaskStatusGridAnimationConstants.intersectionGlowDuration - riseDuration

        if activeTime < riseDuration {
            return easeOutCubic(activeTime / max(riseDuration, 0.001))
        }

        if activeTime < TaskStatusGridAnimationConstants.intersectionGlowDuration {
            let normalized = (activeTime - riseDuration) / max(fallDuration, 0.001)
            return max(1 - easeInCubic(normalized), 0)
        }

        let tailFade = min((activeTime - TaskStatusGridAnimationConstants.intersectionGlowDuration) / 0.25, 1)
        return max(1 - tailFade, 0)
    }

    private func convergenceProgress(for elapsed: Double) -> Double {
        guard elapsed > TaskStatusGridAnimationConstants.convergenceStart else { return 0 }
        let duration = max(TaskStatusGridAnimationConstants.totalDuration - TaskStatusGridAnimationConstants.convergenceStart, 0.001)
        return min((elapsed - TaskStatusGridAnimationConstants.convergenceStart) / duration, 1)
    }

    private func lineEndpoints(for descriptor: LineDescriptor, size: CGSize) -> (start: CGPoint, end: CGPoint) {
        switch descriptor.orientation {
        case .horizontal:
            let inset = horizontalInset(for: size)
            let y = size.height * descriptor.positionFraction
            return (
                CGPoint(x: inset, y: y),
                CGPoint(x: size.width - inset, y: y)
            )
        case .vertical:
            let inset = verticalInset(for: size)
            let x = size.width * descriptor.positionFraction
            return (
                CGPoint(x: x, y: inset),
                CGPoint(x: x, y: size.height - inset)
            )
        }
    }

    private func horizontalInset(for size: CGSize) -> CGFloat {
        min(max(cornerRadius * 0.6, size.width * 0.04), size.width / 5)
    }

    private func verticalInset(for size: CGSize) -> CGFloat {
        min(max(cornerRadius * 0.6, size.height * 0.05), size.height / 5)
    }

    private func intersectionPoint(row: Int, column: Int, size: CGSize) -> CGPoint {
        let horizontal = configuration.horizontalLines[row]
        let vertical = configuration.verticalLines[column]
        return CGPoint(
            x: size.width * vertical.positionFraction,
            y: size.height * horizontal.positionFraction
        )
    }

    private func intersectionTriggerTime(row: Int, column: Int) -> Double {
        let horizontal = configuration.horizontalLines[row]
        let vertical = configuration.verticalLines[column]

        let columnFraction = Double(vertical.positionFraction)
        let rowFraction = Double(horizontal.positionFraction)

        let horizontalDistance = horizontal.direction == .forward ? columnFraction : (1 - columnFraction)
        let verticalDistance = vertical.direction == .forward ? rowFraction : (1 - rowFraction)

        let horizontalTime = horizontal.delay + horizontal.duration * Double(horizontalDistance)
        let verticalTime = vertical.delay + vertical.duration * Double(verticalDistance)
        let jitter = configuration.randomJitter(row: row, column: column)

        return min(max(max(horizontalTime, verticalTime) + jitter, 0), TaskStatusGridAnimationConstants.totalDuration)
    }

    private func startAnimation() {
        configuration = GridAnimationConfiguration.randomized()
        animationStartTime = Date().timeIntervalSinceReferenceDate
        scheduleCompletionTask()
    }

    private func stopAnimation(resetBinding: Bool) {
        completionTask?.cancel()
        completionTask = nil
        animationStartTime = nil
        if resetBinding {
            isActive = false
        }
    }

    private func scheduleCompletionTask() {
        completionTask?.cancel()
        completionTask = Task { [totalDuration = TaskStatusGridAnimationConstants.totalDuration] in
            try? await Task.sleep(nanoseconds: UInt64(totalDuration * 1_000_000_000))
            guard !Task.isCancelled else { return }
            await MainActor.run {
                animationStartTime = nil
                isActive = false
                completionTask = nil
            }
        }
    }

    private func easeOutCubic(_ value: Double) -> Double {
        let clamped = min(max(value, 0), 1)
        return 1 - pow(1 - clamped, 3)
    }

    private func easeInCubic(_ value: Double) -> Double {
        let clamped = min(max(value, 0), 1)
        return clamped * clamped * clamped
    }
}

private struct LineSegment {
    let start: CGPoint
    let end: CGPoint
}

private struct GridAnimationConfiguration {
    let horizontalLines: [LineDescriptor]
    let verticalLines: [LineDescriptor]
    let seed: Int

    static func randomized() -> GridAnimationConfiguration {
        var generator = SystemRandomNumberGenerator()
        let seed = Int.random(in: Int.min...Int.max)

        let horizontalLines = Self.makeDescriptors(
            count: TaskStatusGridAnimationConstants.horizontalLineCount,
            orientation: .horizontal,
            generator: &generator
        )

        let verticalLines = Self.makeDescriptors(
            count: TaskStatusGridAnimationConstants.verticalLineCount,
            orientation: .vertical,
            generator: &generator
        )

        return GridAnimationConfiguration(horizontalLines: horizontalLines, verticalLines: verticalLines, seed: seed)
    }

    private static func makeDescriptors(
        count: Int,
        orientation: LineDescriptor.Orientation,
        generator: inout SystemRandomNumberGenerator
    ) -> [LineDescriptor] {
        let fractions: [CGFloat] = (1...count).map { CGFloat($0) / CGFloat(count + 1) }
        return fractions.map { fraction in
            let delay = Double.random(in: 0...0.8, using: &generator)
            let maxDuration = min(1.4, max(1.0, 1.5 - delay))
            let duration = Double.random(in: 1.0...maxDuration, using: &generator)
            let direction: LineDescriptor.Direction = Bool.random(using: &generator) ? .forward : .reverse
            return LineDescriptor(
                orientation: orientation,
                positionFraction: fraction,
                direction: direction,
                delay: delay,
                duration: duration
            )
        }
    }

    func randomJitter(row: Int, column: Int) -> Double {
        var hasher = Hasher()
        hasher.combine(seed)
        hasher.combine(row)
        hasher.combine(column)
        hasher.combine(91)
        let hash = hasher.finalize()
        let normalized = Double(UInt(bitPattern: hash) % 10_000) / 10_000
        return normalized * 0.12
    }
}

private struct LineDescriptor: Identifiable {
    enum Orientation {
        case horizontal
        case vertical
    }

    enum Direction {
        case forward
        case reverse
    }

    let id = UUID()
    let orientation: Orientation
    let positionFraction: CGFloat
    let direction: Direction
    let delay: Double
    let duration: Double
}

private enum TaskStatusGridAnimationConstants {
    static let horizontalLineCount = 5
    static let verticalLineCount = 6
    static let totalDuration: Double = 2
    static let convergenceStart: Double = 1.5
    static let intersectionGlowDuration: Double = 0.45
    static let staticPreviewTime: Double = 1.2
    static let lineOpacityBase: Double = 0.25
    static let lineOpacityPeak: Double = 0.55
}
