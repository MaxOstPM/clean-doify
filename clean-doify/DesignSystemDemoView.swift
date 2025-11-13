import SwiftUI
#if os(iOS)
import UIKit
#endif

struct DesignSystemDemoView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var isStatusShimmerActive = true
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

                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.tight.value) {
                            Text("shimmering(active:color:duration:)")
                                .textStyle(.titleSecondary)

                            Text("Applies a subtle status-badge shimmer that honors Reduce Motion and fades when inactive.")
                                .textStyle(.body)

                            HStack(spacing: DesignSystem.Spacing.small.value) {
                                StatusBadge(
                                    title: "Syncing",
                                    tint: DesignColor.Status.inProgress
                                )
                                .shimmering(active: isStatusShimmerActive, color: DesignColor.Status.inProgress)

                                StatusBadge(
                                    title: "Queued",
                                    tint: DesignColor.Status.idle
                                )
                                .shimmering(active: false, color: DesignColor.Status.idle)
                            }

                            Toggle("Active status", isOn: $isStatusShimmerActive)
                                .toggleStyle(.switch)
                                .frame(maxWidth: 200, alignment: .leading)
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

private struct StatusBadge: View {
    let title: String
    let tint: Color

    var body: some View {
        Text(title)
            .textStyle(.statusLabel)
            .padding(.horizontal, DesignSystem.Spacing.tight.value)
            .padding(.vertical, DesignSystem.Spacing.xTight.value)
            .background(
                Capsule()
                    .fill(tint.opacity(0.18))
            )
            .overlay(
                Capsule()
                    .strokeBorder(tint.opacity(0.3), lineWidth: DesignSystem.BorderWidth.thin.value)
            )
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
