import SwiftUI
#if os(iOS)
import UIKit
#endif

struct DesignSystemDemoView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedSection: DemoSection = .colors
    @State private var isShimmerEnabled = true
    @State private var isGridActive = false
    @State private var gridAnimationTask: Task<Void, Never>?

    private let colorTokens: [ColorTokenDescriptor] = [
        .init(name: "Primary", color: DesignColor.primary, detail: "Brand blue background"),
        .init(name: "Accent", color: DesignColor.accent, detail: "Call-to-action orange"),
        .init(name: "Success", color: DesignColor.Status.success, detail: "Status - success"),
        .init(name: "Failure", color: DesignColor.Status.failure, detail: "Status - failure"),
        .init(name: "Surface", color: DesignColor.Surface.card, detail: "Card surface"),
        .init(name: "Border", color: DesignColor.border, detail: "Outline & dividers")
    ]

    private let textColorTokens: [ColorTokenDescriptor] = [
        .init(name: "Text / Primary", color: DesignColor.Text.primary, detail: "High emphasis copy"),
        .init(name: "Text / Secondary", color: DesignColor.Text.secondary, detail: "Muted or helper copy"),
        .init(name: "Text / Tertiary", color: DesignColor.Text.tertiary, detail: "Metadata & captions"),
        .init(name: "Text / On Primary", color: DesignColor.Text.onPrimary, detail: "Text on brand fills"),
        .init(name: "Text / On Accent", color: DesignColor.Text.onAccent, detail: "Text on CTA surfaces")
    ]

    private let fontTokens: [FontTokenDescriptor] = [
        .init(name: "Title / Primary", preview: "Headlines anchor pages", font: DesignSystem.Typography.titlePrimary, detail: "20pt bold"),
        .init(name: "Title / Secondary", preview: "Section headers + tabs", font: DesignSystem.Typography.titleSecondary, detail: "16pt semibold"),
        .init(name: "Body", preview: "Readable narrative text", font: DesignSystem.Typography.body, detail: "14pt regular"),
        .init(name: "Status Label", preview: "Badge + status chips", font: DesignSystem.Typography.statusLabel, detail: "12pt medium"),
        .init(name: "Subtitle / Muted", preview: "Supporting metadata", font: DesignSystem.Typography.subtitleMuted, detail: "12pt regular")
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

                Text(selectedSection.detail)
                    .textStyle(.body)

                Picker("Showcase", selection: $selectedSection) {
                    ForEach(DemoSection.allCases) { section in
                        Text(section.title).tag(section)
                    }
                }
                .pickerStyle(.segmented)

                Group {
                    switch selectedSection {
                    case .colors:
                        colorsShowcase
                    case .utilities:
                        utilitiesShowcase
                    case .motion:
                        motionShowcase
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
        .onDisappear {
            gridAnimationTask?.cancel()
            gridAnimationTask = nil
        }
    }

    private var colorsShowcase: some View {
        VStack(spacing: DesignSystem.Spacing.large.value) {
            SectionCard(title: "Core palette") {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 150), spacing: DesignSystem.Spacing.small.value)],
                    spacing: DesignSystem.Spacing.small.value
                ) {
                    ForEach(colorTokens) { descriptor in
                        ColorSwatch(descriptor: descriptor)
                    }
                }
            }

            SectionCard(title: "Text tokens") {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 150), spacing: DesignSystem.Spacing.small.value)],
                    spacing: DesignSystem.Spacing.small.value
                ) {
                    ForEach(textColorTokens) { descriptor in
                        ColorSwatch(descriptor: descriptor)
                    }
                }
            }
        }
    }

    private var utilitiesShowcase: some View {
        VStack(spacing: DesignSystem.Spacing.large.value) {
            SectionCard(title: "Typography scale") {
                VStack(spacing: DesignSystem.Spacing.small.value) {
                    ForEach(fontTokens) { descriptor in
                        FontTokenCard(descriptor: descriptor)
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
        }
    }

    private var motionShowcase: some View {
        VStack(spacing: DesignSystem.Spacing.large.value) {
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

                    CTAButton(isLoading: isGridActive, action: triggerGridAnimation) {
                        Label(isGridActive ? "Animating" : "Start grid animation", systemImage: isGridActive ? "waveform.path.ecg" : "play.fill")
                    }
                    .disabled(isGridActive)

                    GridAnimationCard(isActive: isGridActive)
                }
            }
        }
    }

    private func triggerGridAnimation() {
        guard gridAnimationTask == nil else { return }

        gridAnimationTask = Task { @MainActor in
            isGridActive = true
            try? await Task.sleep(nanoseconds: 2_200_000_000)
            isGridActive = false
            gridAnimationTask = nil
        }
    }
}

private enum DemoSection: String, CaseIterable, Identifiable {
    case colors
    case utilities
    case motion

    var id: String { rawValue }

    var title: String {
        switch self {
        case .colors: return "Colors"
        case .utilities: return "Utils"
        case .motion: return "Animations"
        }
    }

    var detail: String {
        switch self {
        case .colors:
            return "Color palette, status tokens, and text tones in light + dark."
        case .utilities:
            return "Typography scale paired with the design shadow catalog."
        case .motion:
            return "Border, shimmer, and the CAD-inspired grid overlay animations."
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

            Text(descriptor.detail)
                .textStyle(.subtitleMuted)
                .foregroundStyle(DesignColor.Text.secondary)
        }
    }
}

private struct FontTokenCard: View {
    let descriptor: FontTokenDescriptor

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.tight.value) {
            HStack {
                Text(descriptor.name)
                    .textStyle(.titleSecondary)
                Spacer()
                Text(descriptor.detail)
                    .textStyle(.subtitleMuted)
                    .foregroundStyle(DesignColor.Text.secondary)
            }

            Text(descriptor.preview)
                .font(descriptor.font)
                .foregroundStyle(DesignColor.Text.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(DesignSystem.Spacing.medium.insets)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg.value)
                .fill(DesignColor.Surface.popover)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg.value)
                .strokeBorder(DesignColor.border.opacity(0.35), lineWidth: DesignSystem.BorderWidth.thin.value)
        )
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

private struct CTAButton<Label: View>: View {
    let isLoading: Bool
    let action: () -> Void
    @ViewBuilder let label: () -> Label

    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.small.value) {
                label()
                    .textStyle(.titleSecondary)
                    .foregroundStyle(DesignColor.Text.onAccent)

                Spacer()

                if isLoading {
                    ProgressView()
                        .tint(DesignColor.Text.onAccent)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.medium.value)
            .padding(.vertical, DesignSystem.Spacing.small.value)
            .frame(maxWidth: .infinity)
            .background(
                Capsule()
                    .fill(DesignColor.accent)
            )
        }
        .buttonStyle(.plain)
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
                    statusColor: DesignColor.Status.inProgress,
                    isActive: isActive,
                    cornerRadius: DesignSystem.CornerRadius.xl.value,
                    lineSpacing: 26
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

private struct FontTokenDescriptor: Identifiable {
    let id = UUID()
    let name: String
    let preview: String
    let font: Font
    let detail: String
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
