import SwiftUI
#if os(iOS)
import UIKit
#endif

struct DesignSystemDemoView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var isShimmerEnabled = true
    @State private var isGridActive = false
    @State private var showsGridDots = true

    private let colorTokens: [ColorTokenDescriptor] = [
        .init(name: "Primary", color: DesignColor.primary, detail: "Brand blue background"),
        .init(name: "Accent", color: DesignColor.accent, detail: "Call-to-action orange"),
        .init(name: "Success", color: DesignColor.Status.success, detail: "Status - success"),
        .init(name: "Failure", color: DesignColor.Status.failure, detail: "Status - failure"),
        .init(name: "Surface", color: DesignColor.Surface.card, detail: "Card surface"),
        .init(name: "Border", color: DesignColor.border, detail: "Outline & dividers")
    ]

    private let shadowTokens: [ShadowTokenDescriptor] = [
        .init(name: "Technical", token: .technical, detail: "Precision chrome shadow"),
        .init(name: "Elevated", token: .elevated, detail: "Floating cards"),
        .init(name: "Glow", token: .glow, detail: "Ambient light wash"),
        .init(name: "CTA", token: .cta, detail: "Call-to-action emphasis")
    ]

    private let maxContentWidth: CGFloat = 520

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.large.value) {
                Text("Design foundation reference")
                    .textStyle(.titlePrimary)

                Text("Color tokens, shadows, borders, shimmer, and our CAD-inspired grid animation captured in one glance.")
                    .textStyle(.body)

                SectionCard(title: "Color tokens") {
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 150), spacing: DesignSystem.Spacing.small.value)],
                        spacing: DesignSystem.Spacing.small.value
                    ) {
                        ForEach(colorTokens) { descriptor in
                            ColorSwatch(descriptor: descriptor)
                        }
                    }
                }

                SectionCard(title: "Shadow scale") {
                    Text("Each card applies a different \"DesignSystem.Shadow\" token to highlight depth tiers.")
                        .textStyle(.body)

                    LazyVGrid(
                        columns: [GridItem(.flexible()), GridItem(.flexible())],
                        spacing: DesignSystem.Spacing.small.value
                    ) {
                        ForEach(shadowTokens) { descriptor in
                            ShadowCard(descriptor: descriptor)
                        }
                    }
                }

                SectionCard(title: "Border animation") {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.small.value) {
                        Text("animatedBorder(color:lineWidth:cornerRadius:)")
                            .textStyle(.titleSecondary)

                        Text("Pulsing motion calls attention to live workflows while honoring Reduce Motion.")
                            .textStyle(.body)

                        BorderAnimationCard()
                    }
                }

                SectionCard(title: "Shimmer skeleton") {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.small.value) {
                        Text("shimmering(active:color:duration:)")
                            .textStyle(.titleSecondary)

                        Text("Use the shimmer modifier on badges or placeholders to indicate background work.")
                            .textStyle(.body)

                        ShimmerSkeletonList(isActive: isShimmerEnabled)

                        Toggle("Active shimmer", isOn: $isShimmerEnabled)
                            .toggleStyle(.switch)
                            .frame(maxWidth: 220, alignment: .leading)
                    }
                }

                SectionCard(title: "Grid animation overlay") {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.small.value) {
                        Text("TaskCardGridOverlay")
                            .textStyle(.titleSecondary)

                        Text("A CAD-like scan animates whenever the overlay becomes active, ideal for fabrication tasks.")
                            .textStyle(.body)

                        GridAnimationCard(isActive: isGridActive, showsIntersections: showsGridDots)

                        Toggle("Show intersection dots", isOn: $showsGridDots)
                            .toggleStyle(.switch)
                            .frame(maxWidth: 220, alignment: .leading)
                    }
                }
            }
            .frame(maxWidth: maxContentWidth, alignment: .leading)
            .padding(.horizontal, DesignSystem.Spacing.small.value)
            .padding(.vertical, DesignSystem.Spacing.large.value)
            .frame(maxWidth: .infinity)
        }
        .background(DesignColor.background.ignoresSafeArea())
        .navigationTitle("Design System")
        .task {
            await animateGridOverlayLoop()
        }
    }

    @MainActor
    private func animateGridOverlayLoop() async {
        while !Task.isCancelled {
            isGridActive = true
            try? await Task.sleep(nanoseconds: 2_200_000_000)

            if Task.isCancelled { break }

            isGridActive = false
            try? await Task.sleep(nanoseconds: 1_000_000_000)
        }
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
                        .strokeBorder(DesignColor.border.opacity(0.35), lineWidth: DesignSystem.BorderWidth.thin.value)
                )

            Text(descriptor.name)
                .textStyle(.titleSecondary)
        }
    }
}

private struct ShadowCard: View {
    let descriptor: ShadowTokenDescriptor

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.tight.value) {
            Text(descriptor.name)
                .textStyle(.titleSecondary)

            Text(descriptor.detail)
                .textStyle(.subtitleMuted)

            Spacer()

            Text(".designShadow(\(descriptor.displayName))")
                .textStyle(.body)
                .foregroundStyle(DesignColor.Text.secondary)
        }
        .padding(DesignSystem.Spacing.medium.insets)
        .frame(maxWidth: .infinity, minHeight: 160, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg.value)
                .fill(DesignColor.Surface.card)
        )
        .designShadow(descriptor.token)
    }
}

private struct BorderAnimationCard: View {
    var body: some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl.value)
            .fill(DesignColor.Surface.card)
            .frame(height: 140)
            .overlay(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.small.value) {
                    Text("Live machining pass")
                        .textStyle(.titleSecondary)

                    Text("Toolpath updating in real time")
                        .textStyle(.body)
                }
                .padding(DesignSystem.Spacing.medium.insets)
            }
            .animatedBorder(
                color: DesignColor.Status.inProgress,
                lineWidth: DesignSystem.BorderWidth.medium.value,
                cornerRadius: DesignSystem.CornerRadius.xl.value
            )
    }
}

private struct ShimmerSkeletonList: View {
    let isActive: Bool

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.small.value) {
            ForEach(0..<3) { index in
                ShimmerSkeletonRow(delayIndex: index)
                    .shimmering(active: isActive, color: DesignColor.Status.inProgress)
            }
        }
    }
}

private struct ShimmerSkeletonRow: View {
    let delayIndex: Int

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.small.value) {
            Circle()
                .fill(DesignColor.Surface.muted)
                .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xTight.value) {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md.value)
                    .fill(DesignColor.Surface.muted)
                    .frame(height: 14)
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md.value)
                    .fill(DesignColor.Surface.muted.opacity(0.8))
                    .frame(height: 12)
                    .padding(.trailing, CGFloat(delayIndex) * 12)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(DesignSystem.Spacing.small.insets)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg.value)
                .fill(DesignColor.Surface.popover)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg.value)
                .strokeBorder(DesignColor.border.opacity(0.4), lineWidth: DesignSystem.BorderWidth.thin.value)
        )
    }
}

private struct GridAnimationCard: View {
    let isActive: Bool
    let showsIntersections: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl.value)
            .fill(DesignColor.Surface.card)
            .frame(height: 200)
            .overlay(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.small.value) {
                    Text("Adaptive fabrication task")
                        .textStyle(.titlePrimary)

                    Text("Grid animates whenever the status bumps.")
                        .textStyle(.body)

                    Text(isActive ? "Animating" : "Idle")
                        .textStyle(.statusLabel)
                        .padding(.horizontal, DesignSystem.Spacing.tight.value)
                        .padding(.vertical, DesignSystem.Spacing.xTight.value)
                        .background(
                            Capsule()
                                .fill(DesignColor.Status.inProgress.opacity(0.15))
                        )
                }
                .padding(DesignSystem.Spacing.medium.insets)
            }
            .overlay {
                TaskCardGridOverlay(
                    statusColor: DesignColor.Status.success,
                    isActive: isActive,
                    cornerRadius: DesignSystem.CornerRadius.xl.value,
                    lineSpacing: 26,
                    showsIntersections: showsIntersections
                )
            }
            .designShadow(.lg)
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

private struct ShadowTokenDescriptor: Identifiable {
    let id = UUID()
    let name: String
    let token: DesignSystem.Shadow
    let detail: String

    var displayName: String { String(describing: token).capitalized }
}

#Preview {
    NavigationStack {
        DesignSystemDemoView()
    }
}
