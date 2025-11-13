import SwiftUI
#if os(iOS)
import UIKit
#endif

struct DesignSystemDemoView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var isManualGridShimmerActive = false
    @State private var isStatusGridAnimating = false
    @State private var activeStatusIndex = 0

    private let colorTokens: [ColorTokenDescriptor] = [
        .init(name: "Primary", color: DesignColor.primary, detail: "Primary brand background"),
        .init(name: "Secondary", color: DesignColor.secondary, detail: "Secondary accents"),
        .init(name: "Accent", color: DesignColor.accent, detail: "Call-to-action highlight"),
        .init(name: "Background", color: DesignColor.background, detail: "Base app background"),
        .init(name: "Foreground", color: DesignColor.foreground, detail: "Primary foreground text"),
        .init(name: "Surface / Card", color: DesignColor.Surface.card, detail: "Elevated container"),
        .init(name: "Surface / Popover", color: DesignColor.Surface.popover, detail: "Popover surface"),
        .init(name: "Surface / Muted", color: DesignColor.Surface.muted, detail: "Muted surface"),
        .init(name: "Border", color: DesignColor.border, detail: "Dividers & borders"),
        .init(name: "Input", color: DesignColor.input, detail: "Form backgrounds"),
        .init(name: "Text / Primary", color: DesignColor.Text.primary, detail: "Primary text"),
        .init(name: "Text / Secondary", color: DesignColor.Text.secondary, detail: "Secondary text"),
        .init(name: "Text / Tertiary", color: DesignColor.Text.tertiary, detail: "Caption text"),
        .init(name: "Text / On Primary", color: DesignColor.Text.onPrimary, detail: "Text on primary"),
        .init(name: "Text / On Accent", color: DesignColor.Text.onAccent, detail: "Text on accent"),
        .init(name: "Status / Success", color: DesignColor.Status.success, detail: "Success state"),
        .init(name: "Status / Failure", color: DesignColor.Status.failure, detail: "Failure state"),
        .init(name: "Status / Canceled", color: DesignColor.Status.canceled, detail: "Canceled state"),
        .init(name: "Status / In Progress", color: DesignColor.Status.inProgress, detail: "In-progress state"),
        .init(name: "Status / Idle", color: DesignColor.Status.idle, detail: "Idle state")
    ]

    private let spacingTokens: [SpacingToken] = [
        .init(name: "xTight", token: .xTight, axis: .horizontal),
        .init(name: "tight", token: .tight, axis: .vertical),
        .init(name: "small", token: .small, axis: .horizontal),
        .init(name: "medium", token: .medium, axis: .vertical),
        .init(name: "large", token: .large, axis: .vertical),
        .init(name: "xl", token: .xl, axis: .horizontal)
    ]

    private let maxContentWidth: CGFloat = 448

    private let statusDemoStates: [TaskStatusDemoState] = [
        .init(
            title: "Review synthesis",
            detail: "Compile the top takeaways from the workshop notes for the leadership deck.",
            statusLabel: "In Progress",
            statusColor: DesignColor.Status.inProgress,
            actionLabel: "Mark Done"
        ),
        .init(
            title: "System design",
            detail: "Map the orchestration layer for the new automations grid.",
            statusLabel: "Today",
            statusColor: DesignColor.Status.idle,
            actionLabel: "Start Work"
        ),
        .init(
            title: "Handoff QA",
            detail: "Verify empty states and grid overlays before sharing the build with QA.",
            statusLabel: "Done",
            statusColor: DesignColor.Status.success,
            actionLabel: "Reopen"
        )
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.large.value) {
                SectionCard(title: "Color Tokens") {
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 140), spacing: DesignSystem.Spacing.tight.value)],
                        spacing: DesignSystem.Spacing.tight.value
                    ) {
                        ForEach(colorTokens) { descriptor in
                            ColorSwatch(descriptor: descriptor)
                        }
                    }
                }

                SectionCard(title: "Typography") {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.tight.value) {
                        Text("Section Heading")
                            .textStyle(.titlePrimary)

                        Text("Primary Title Style")
                            .textStyle(.titleSecondary)

                        Text("Supporting body copy lives here. It uses the description font with relaxed line height so multi-line text remains legible across content widths.")
                            .textStyle(.body)

                        Text("Status Label")
                            .textStyle(.statusLabel)
                            .padding(.horizontal, DesignSystem.Spacing.tight.value)
                            .padding(.vertical, DesignSystem.Spacing.xTight.value)
                            .background(
                                Capsule()
                                    .fill(DesignColor.Surface.muted)
                                    .gridShimmer(
                                        activation: .cooldown(1.2),
                                        preferredColumnWidth: 72,
                                        spacing: DesignSystem.Spacing.tight.value,
                                        cornerRadius: DesignSystem.CornerRadius.sm.value,
                                        lineWidth: DesignSystem.BorderWidth.thin.value,
                                        animationDuration: 2.2
                                    )
                            )
                    }
                }

                SectionCard(title: "Spacing Tokens") {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium.value) {
                        ForEach(spacingTokens) { token in
                            SpacingTokenView(token: token)
                        }
                    }
                }

                SectionCard(title: "Animation Modifiers") {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium.value) {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.tight.value) {
                            Text("shimmer()")
                                .textStyle(.titleSecondary)

                            Text("A sweeping surface shimmer that honors Reduce Motion and can be retriggered on demand.")
                                .textStyle(.body)

                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl.value)
                                .fill(DesignColor.background)
                                .frame(height: 140)
                                .shimmer(
                                    activation: .cooldown(1.8),
                                    tint: DesignColor.Surface.muted.opacity(0.28),
                                    highlightTint: DesignColor.accent,
                                    cornerRadius: DesignSystem.CornerRadius.xl.value,
                                    shimmerWidthRatio: 0.6,
                                    animationDuration: 1.5
                                )
                                .overlay(alignment: .leading) {
                                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.tight.value) {
                                        Text("Task")
                                            .textStyle(.titleSecondary)

                                        Text("Shimmering surfaces highlight active workstreams without overwhelming the rest of the UI.")
                                            .textStyle(.body)
                                    }
                                    .padding(DesignSystem.Spacing.medium.value)
                                }
                        }

                        Divider()
                            .background(DesignColor.border)

                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.tight.value) {
                            Text("gridShimmer()")
                                .textStyle(.titleSecondary)

                            Text("A reusable skeleton grid with randomized line direction and pulsing anchor dots.")
                                .textStyle(.body)

                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl.value)
                                .fill(DesignColor.Surface.muted)
                                .frame(height: 160)
                                .gridShimmer(
                                    activation: .cooldown(1.8),
                                    preferredColumnWidth: 120,
                                    spacing: DesignSystem.Spacing.tight.value,
                                    cornerRadius: DesignSystem.CornerRadius.md.value,
                                    lineWidth: DesignSystem.BorderWidth.thin.value,
                                    animationDuration: 2.6
                                )
                        }

                        Divider()
                            .background(DesignColor.border)

                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.tight.value) {
                            Text("Manual trigger")
                                .textStyle(.titleSecondary)

                            Text("Use a binding-driven activation to fire the shimmer on demand, such as after a pull-to-refresh or button tap.")
                                .textStyle(.body)

                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl.value)
                                .fill(DesignColor.Surface.card)
                                .frame(height: 120)
                                .gridShimmer(
                                    activation: .manual(isActive: $isManualGridShimmerActive),
                                    preferredColumnWidth: 110,
                                    spacing: DesignSystem.Spacing.tight.value,
                                    cornerRadius: DesignSystem.CornerRadius.md.value,
                                    lineWidth: DesignSystem.BorderWidth.thin.value,
                                    animationDuration: 2.6
                                )

                            Button {
                                isManualGridShimmerActive = true
                            } label: {
                                Label("Replay grid shimmer", systemImage: "sparkles")
                                    .textStyle(.statusLabel)
                                    .padding(.horizontal, DesignSystem.Spacing.tight.value)
                                    .padding(.vertical, DesignSystem.Spacing.tight.value)
                                    .background(
                                        Capsule()
                                            .fill(DesignColor.accent.opacity(0.12))
                                    )
                            }
                            .buttonStyle(.plain)
                        }

                        Divider()
                            .background(DesignColor.border)

                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.tight.value) {
                            Text("TaskStatusGridAnimation")
                                .textStyle(.titleSecondary)

                            Text("Grid overlay that fires when a task status changes. Lines draw in with random timing, intersections glow, then the pattern converges and fades out.")
                                .textStyle(.body)

                            TaskStatusCardDemo(
                                state: statusDemoStates[activeStatusIndex],
                                isAnimating: $isStatusGridAnimating
                            )

                            Button {
                                activeStatusIndex = (activeStatusIndex + 1) % statusDemoStates.count
                                isStatusGridAnimating = true
                            } label: {
                                Label("Change status", systemImage: "arrow.triangle.2.circlepath")
                                    .textStyle(.statusLabel)
                                    .padding(.horizontal, DesignSystem.Spacing.tight.value)
                                    .padding(.vertical, DesignSystem.Spacing.tight.value)
                                    .background(
                                        Capsule()
                                            .fill(statusDemoStates[activeStatusIndex].statusColor.opacity(0.15))
                                    )
                            }
                            .buttonStyle(.plain)
                        }

                        Divider()
                            .background(DesignColor.border)

                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.tight.value) {
                            Text("animatedBorder()")
                                .textStyle(.titleSecondary)

                            Text("Emphasize active states with a pulsing border that adapts to Reduce Motion preferences.")
                                .textStyle(.body)

                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl.value)
                                .fill(DesignColor.Surface.card)
                                .frame(height: 120)
                                .overlay(alignment: .topLeading) {
                                    Text("Active Workflow")
                                        .textStyle(.titleSecondary)
                                        .padding(DesignSystem.Spacing.small.insets)
                                }
                                .animatedBorder(
                                    color: DesignColor.Status.inProgress,
                                    lineWidth: DesignSystem.BorderWidth.medium.value,
                                    cornerRadius: DesignSystem.CornerRadius.xl.value
                                )
                        }
                    }
                }
            }
            .frame(maxWidth: maxContentWidth, alignment: .leading)
            .padding(.horizontal, DesignSystem.Spacing.small.value)
            .padding(.bottom, DesignSystem.Spacing.large.value)
            .padding(.top, DesignSystem.Spacing.medium.value)
            .frame(maxWidth: .infinity)
        }
        .background(DesignColor.background.ignoresSafeArea())
        .navigationTitle("Design System")
    }
}

private struct SectionCard<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium.value) {
            Text(title)
                .textStyle(.titlePrimary)
            content
        }
        .padding(DesignSystem.Spacing.medium.insets)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl.value)
                .fill(DesignColor.Surface.card)
        )
        .designShadow(.md)
    }
}

private struct TaskStatusCardDemo: View {
    let state: TaskStatusDemoState
    @Binding var isAnimating: Bool

    private let cornerRadius = DesignSystem.CornerRadius.xl.value

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small.value) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xTight.value) {
                    Text(state.title)
                        .textStyle(.titleSecondary)

                    Text(state.detail)
                        .textStyle(.body)
                }

                Spacer()

                Text(state.statusLabel)
                    .textStyle(.statusLabel)
                    .padding(.horizontal, DesignSystem.Spacing.tight.value)
                    .padding(.vertical, DesignSystem.Spacing.xTight.value)
                    .background(
                        Capsule()
                            .fill(state.statusColor.opacity(0.12))
                    )
            }

            Divider()
                .background(state.statusColor.opacity(0.5))

            HStack {
                Label(state.actionLabel, systemImage: "sparkles")
                    .textStyle(.body)
                    .foregroundColor(state.statusColor)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(DesignColor.Text.secondary)
            }
        }
        .padding(DesignSystem.Spacing.medium.insets)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(DesignColor.Surface.card)
                .overlay {
                    TaskStatusGridAnimation(
                        isActive: $isAnimating,
                        statusColor: state.statusColor,
                        cornerRadius: cornerRadius
                    )
                }
        )
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(state.statusColor.opacity(0.6), lineWidth: DesignSystem.BorderWidth.thin.value)
        )
    }
}

private struct TaskStatusDemoState {
    let title: String
    let detail: String
    let statusLabel: String
    let statusColor: Color
    let actionLabel: String
}

@MainActor
private struct ColorSwatch: View {
    @Environment(\.colorScheme) private var colorScheme

    let descriptor: ColorTokenDescriptor

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small.value) {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md.value)
                .fill(descriptor.color)
                .frame(height: 72)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md.value)
                        .strokeBorder(DesignColor.border.opacity(0.3), lineWidth: DesignSystem.BorderWidth.thin.value)
                )

            Text(descriptor.name)
                .textStyle(.titleSecondary)

            Text(accessibilityDescription)
                .textStyle(.subtitleMuted)
        }
    }

    private var accessibilityDescription: String {
        #if os(iOS)
        let trait = UITraitCollection(userInterfaceStyle: colorScheme == .dark ? .dark : .light)
        if let description = descriptor.color.hsbDescription(in: trait) {
            return "Hue \(description.hue)°, Sat \(description.saturation)%, Brightness \(description.brightness)%"
        }
        #endif
        return descriptor.detail
    }
}

private struct ColorTokenDescriptor: Identifiable {
    let id: String
    let name: String
    let color: Color
    let detail: String

    init(name: String, color: Color, detail: String) {
        self.id = name
        self.name = name
        self.color = color
        self.detail = detail
    }
}

private struct SpacingToken: Identifiable {
    enum Axis {
        case horizontal
        case vertical
    }

    let id: String
    let name: String
    let token: DesignSystem.Spacing
    let axis: Axis

    var value: CGFloat { token.value }

    init(name: String, token: DesignSystem.Spacing, axis: Axis) {
        self.id = name
        self.name = name
        self.token = token
        self.axis = axis
    }
}

private struct SpacingTokenView: View {
    let token: SpacingToken

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.tight.value) {
            Text("\(token.name) – \(Int(token.value))pt")
                .textStyle(.titleSecondary)

            Group {
                switch token.axis {
                case .horizontal:
                    HorizontalSpacingExample(value: token.value)
                case .vertical:
                    VerticalSpacingExample(value: token.value)
                }
            }
        }
    }
}

private struct HorizontalSpacingExample: View {
    let value: CGFloat

    var body: some View {
        let visualWidth = min(value, 180)

        HStack(spacing: 0) {
            Capsule()
                .fill(DesignColor.accent)
                .frame(width: 28, height: 10)

            Rectangle()
                .fill(Color.clear)
                .frame(width: visualWidth, height: 10)
                .overlay(
                    Rectangle()
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                        .foregroundStyle(DesignColor.border)
                )

            Capsule()
                .fill(DesignColor.accent)
                .frame(width: 28, height: 10)
        }
    }
}

private struct VerticalSpacingExample: View {
    let value: CGFloat

    var body: some View {
        let visualHeight = min(value, 180)

        VStack(spacing: 0) {
            Capsule()
                .fill(DesignColor.accent)
                .frame(width: 10, height: 28)

            Rectangle()
                .fill(Color.clear)
                .frame(width: 10, height: visualHeight)
                .overlay(
                    Rectangle()
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                        .foregroundStyle(DesignColor.border)
                )

            Capsule()
                .fill(DesignColor.accent)
                .frame(width: 10, height: 28)
        }
    }
}

#Preview {
    NavigationStack {
        DesignSystemDemoView()
    }
}
