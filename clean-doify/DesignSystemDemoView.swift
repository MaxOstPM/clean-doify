import SwiftUI
#if os(iOS)
import UIKit
#endif

struct DesignSystemDemoView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var isManualGridShimmerActive = false

    private let colorTokens: [ColorTokenDescriptor] = DesignSystem.ColorTokenName.allCases.enumerated().map { index, token in
        ColorTokenDescriptor(id: index, token: token)
    }

    private let spacingTokens: [SpacingToken] = [
        .init(name: "cardPadding", value: DesignSystem.Spacing.cardPadding, axis: .horizontal),
        .init(name: "verticalGap", value: DesignSystem.Spacing.verticalGap, axis: .vertical),
        .init(name: "textGap", value: DesignSystem.Spacing.textGap, axis: .vertical),
        .init(name: "safeAreaHorizontal", value: DesignSystem.Spacing.safeAreaHorizontal, axis: .horizontal),
        .init(name: "safeAreaBottom", value: DesignSystem.Spacing.safeAreaBottom, axis: .vertical),
        .init(name: "contentMaxWidth", value: DesignSystem.Spacing.contentMaxWidth, axis: .horizontal)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.verticalGap) {
                SectionCard(title: "Color Tokens") {
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 140), spacing: DesignSystem.Spacing.textGap)],
                        spacing: DesignSystem.Spacing.textGap
                    ) {
                        ForEach(colorTokens) { descriptor in
                            ColorSwatch(token: descriptor.token)
                        }
                    }
                }

                SectionCard(title: "Typography") {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.textGap) {
                        Text("Section Heading")
                            .font(DesignSystem.Typography.sectionHeading)
                            .foregroundStyle(DesignSystem.token(.titlePrimary, for: colorScheme))

                        Text("Primary Title Style")
                            .font(DesignSystem.Typography.title)
                            .foregroundStyle(DesignSystem.token(.titleSecondary, for: colorScheme))

                        Text("Supporting body copy lives here. It uses the description font with relaxed line height so multi-line text remains legible across content widths.")
                            .font(DesignSystem.Typography.description)
                            .foregroundStyle(DesignSystem.token(.subtitle, for: colorScheme))

                        Text("Status Label")
                            .font(DesignSystem.Typography.statusLabel)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(DesignSystem.token(.muted, for: colorScheme))
                                    .gridShimmer(
                                        activation: .cooldown(1.2),
                                        preferredColumnWidth: 72,
                                        spacing: 8,
                                        cornerRadius: DesignSystem.Radius.small.value,
                                        lineWidth: DesignSystem.BorderWidth.thin.value,
                                        animationDuration: 2.2
                                    )
                            )
                            .foregroundStyle(DesignSystem.token(.titlePrimary, for: colorScheme))
                    }
                }

                SectionCard(title: "Spacing Tokens") {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.verticalGap) {
                        ForEach(spacingTokens) { token in
                            SpacingTokenView(token: token)
                        }
                    }
                }

                SectionCard(title: "Animation Modifiers") {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.verticalGap) {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.textGap) {
                            Text("animatedBorder()").font(DesignSystem.Typography.title)
                                .foregroundStyle(DesignSystem.token(.titleSecondary, for: colorScheme))

                            Text("An animated gradient border that responds to Reduce Motion preferences.")
                                .font(DesignSystem.Typography.description)
                                .foregroundStyle(DesignSystem.token(.subtitle, for: colorScheme))

                            RoundedRectangle(cornerRadius: DesignSystem.Radius.extraLarge.value)
                                .fill(DesignSystem.token(.background, for: colorScheme))
                                .frame(height: 140)
                                .overlay(alignment: .leading) {
                                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.textGap) {
                                        Text("Task")
                                            .font(DesignSystem.Typography.title)
                                            .foregroundStyle(DesignSystem.token(.titlePrimary, for: colorScheme))
                                        Text("Animated borders highlight active workstreams without overwhelming the rest of the UI.")
                                            .font(DesignSystem.Typography.description)
                                            .foregroundStyle(DesignSystem.token(.subtitle, for: colorScheme))
                                    }
                                    .padding(DesignSystem.Spacing.cardPadding)
                                }
                                .animatedBorder(
                                    colors: [
                                        DesignSystem.token(.accent, for: colorScheme),
                                        DesignSystem.token(.primary, for: colorScheme),
                                        DesignSystem.token(.secondary, for: colorScheme)
                                    ],
                                    lineWidth: DesignSystem.BorderWidth.thin.value,
                                    cornerRadius: DesignSystem.Radius.extraLarge.value,
                                    animationDuration: 6
                                )
                        }

                        Divider()
                            .background(DesignSystem.token(.separator, for: colorScheme))

                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.textGap) {
                            Text("gridShimmer()").font(DesignSystem.Typography.title)
                                .foregroundStyle(DesignSystem.token(.titleSecondary, for: colorScheme))

                            Text("A reusable skeleton grid for loading states with Reduced Motion support.")
                                .font(DesignSystem.Typography.description)
                                .foregroundStyle(DesignSystem.token(.subtitle, for: colorScheme))

                            RoundedRectangle(cornerRadius: DesignSystem.Radius.extraLarge.value)
                                .fill(DesignSystem.token(.muted, for: colorScheme))
                                .frame(height: 160)
                                .gridShimmer(
                                    activation: .cooldown(1.8),
                                    preferredColumnWidth: 120,
                                    spacing: DesignSystem.Spacing.textGap,
                                    cornerRadius: DesignSystem.Radius.medium.value,
                                    lineWidth: DesignSystem.BorderWidth.thin.value,
                                    animationDuration: 2.6
                                )
                        }

                        Divider()
                            .background(DesignSystem.token(.separator, for: colorScheme))

                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.textGap) {
                            Text("Manual trigger")
                                .font(DesignSystem.Typography.title)
                                .foregroundStyle(DesignSystem.token(.titleSecondary, for: colorScheme))

                            Text("Use a binding-driven activation to fire the shimmer on demand, such as after a pull-to-refresh or button tap.")
                                .font(DesignSystem.Typography.description)
                                .foregroundStyle(DesignSystem.token(.subtitle, for: colorScheme))

                            RoundedRectangle(cornerRadius: DesignSystem.Radius.extraLarge.value)
                                .fill(DesignSystem.token(.card, for: colorScheme))
                                .frame(height: 120)
                                .gridShimmer(
                                    activation: .manual(isActive: $isManualGridShimmerActive),
                                    preferredColumnWidth: 110,
                                    spacing: DesignSystem.Spacing.textGap,
                                    cornerRadius: DesignSystem.Radius.medium.value,
                                    lineWidth: DesignSystem.BorderWidth.thin.value,
                                    animationDuration: 2.6
                                )

                            Button {
                                isManualGridShimmerActive = true
                            } label: {
                                Label("Replay grid shimmer", systemImage: "sparkles")
                                    .font(DesignSystem.Typography.statusLabel)
                                    .padding(.horizontal, DesignSystem.Spacing.textGap)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(DesignSystem.token(.accent, for: colorScheme).opacity(0.12))
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .frame(maxWidth: DesignSystem.Spacing.contentMaxWidth, alignment: .leading)
            .padding(.horizontal, DesignSystem.Spacing.safeAreaHorizontal)
            .padding(.bottom, DesignSystem.Spacing.safeAreaBottom)
            .padding(.top, DesignSystem.Spacing.verticalGap)
            .frame(maxWidth: .infinity)
        }
        .background(DesignSystem.token(.background, for: colorScheme).ignoresSafeArea())
        .navigationTitle("Design System")
    }
}

private struct SectionCard<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme

    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        let shadow = DesignSystem.shadow(.md, for: colorScheme)

        VStack(alignment: .leading, spacing: DesignSystem.Spacing.verticalGap) {
            Text(title)
                .font(DesignSystem.Typography.sectionHeading)
                .foregroundStyle(DesignSystem.token(.titlePrimary, for: colorScheme))
            content
        }
        .padding(DesignSystem.Spacing.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.extraLarge.value)
                .fill(DesignSystem.token(.card, for: colorScheme))
        )
        .shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
}

private struct ColorSwatch: View {
    @Environment(\.colorScheme) private var colorScheme

    let token: DesignSystem.ColorTokenName

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            RoundedRectangle(cornerRadius: DesignSystem.Radius.medium.value)
                .fill(DesignSystem.token(token, for: colorScheme))
                .frame(height: 72)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.Radius.medium.value)
                        .strokeBorder(DesignSystem.token(.border, for: colorScheme).opacity(0.3), lineWidth: DesignSystem.BorderWidth.thin.value)
                )
                .animatedBorder(
                    colors: [
                        DesignSystem.token(.accent, for: colorScheme),
                        DesignSystem.token(.secondary, for: colorScheme)
                    ],
                    lineWidth: DesignSystem.BorderWidth.thin.value,
                    cornerRadius: DesignSystem.Radius.medium.value,
                    animationDuration: 7
                )

            Text(token.displayName)
                .font(DesignSystem.Typography.title)
                .foregroundStyle(DesignSystem.token(.titleSecondary, for: colorScheme))

            Text(token.accessibilityDescription(for: colorScheme))
                .font(DesignSystem.Typography.statusLabel)
                .foregroundStyle(DesignSystem.token(.subtitleMuted, for: colorScheme))
        }
    }
}

private struct ColorTokenDescriptor: Identifiable {
    let id: Int
    let token: DesignSystem.ColorTokenName
}

private struct SpacingToken: Identifiable {
    enum Axis {
        case horizontal, vertical
    }

    let id: String
    let name: String
    let value: CGFloat
    let axis: Axis

    init(name: String, value: CGFloat, axis: Axis) {
        self.id = name
        self.name = name
        self.value = value
        self.axis = axis
    }
}

private struct SpacingTokenView: View {
    @Environment(\.colorScheme) private var colorScheme

    let token: SpacingToken

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.textGap) {
            Text("\(token.name) – \(Int(token.value))pt")
                .font(DesignSystem.Typography.title)
                .foregroundStyle(DesignSystem.token(.titleSecondary, for: colorScheme))

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
    @Environment(\.colorScheme) private var colorScheme

    let value: CGFloat

    var body: some View {
        let visualWidth = min(value, 180)

        HStack(spacing: 0) {
            Capsule()
                .fill(DesignSystem.token(.accent, for: colorScheme))
                .frame(width: 28, height: 10)

            Rectangle()
                .fill(Color.clear)
                .frame(width: visualWidth, height: 10)
                .overlay(
                    Rectangle()
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                        .foregroundStyle(DesignSystem.token(.border, for: colorScheme))
                )

            Capsule()
                .fill(DesignSystem.token(.accent, for: colorScheme))
                .frame(width: 28, height: 10)
        }
    }
}

private struct VerticalSpacingExample: View {
    @Environment(\.colorScheme) private var colorScheme

    let value: CGFloat

    var body: some View {
        let visualHeight = min(value, 180)

        VStack(spacing: 0) {
            Capsule()
                .fill(DesignSystem.token(.accent, for: colorScheme))
                .frame(width: 10, height: 28)

            Rectangle()
                .fill(Color.clear)
                .frame(width: 10, height: visualHeight)
                .overlay(
                    Rectangle()
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                        .foregroundStyle(DesignSystem.token(.border, for: colorScheme))
                )

            Capsule()
                .fill(DesignSystem.token(.accent, for: colorScheme))
                .frame(width: 10, height: 28)
        }
    }
}

private extension DesignSystem.ColorTokenName {
    var displayName: String {
        String(describing: self)
            .replacingOccurrences(of: "([a-z])([A-Z])", with: "$1 $2", options: .regularExpression)
            .capitalized
    }

    func accessibilityDescription(for scheme: ColorScheme) -> String {
        let color = DesignSystem.token(self, for: scheme)
        #if os(iOS)
        if let uiColor = UIColor(color) { // swiftlint:disable:this explicit_type_interface
            var hue: CGFloat = 0
            var saturation: CGFloat = 0
            var brightness: CGFloat = 0
            var alpha: CGFloat = 0
            uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            let hueDegrees = Int(hue * 360)
            let saturationPercent = Int(saturation * 100)
            let brightnessPercent = Int(brightness * 100)
            return "Hue \\(hueDegrees)°, Sat \\(saturationPercent)%, Brightness \\(brightnessPercent)%"
        }
        #endif
        return "Semantic token"
    }
}

#Preview {
    NavigationStack {
        DesignSystemDemoView()
    }
}
