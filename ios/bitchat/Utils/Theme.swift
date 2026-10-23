//
// Theme.swift
// bitchat
//
// This is free and unencumbered software released into the public domain.
// For more information, see <https://unlicense.org>
//

import SwiftUI

/// A user-selectable app-wide visual theme. Persisted by raw value.
enum AppTheme: String, CaseIterable, Identifiable {
    case matrix
    case liquidGlass

    var id: String { rawValue }

    /// UserDefaults key backing the theme selection.
    static let storageKey = "appTheme"

    var displayNameKey: LocalizedStringKey {
        switch self {
        case .matrix: return "app_info.appearance.matrix"
        case .liquidGlass: return "app_info.appearance.liquid_glass"
        }
    }

    /// Font design used for themed text. Matrix keeps the terminal monospace;
    /// liquid glass uses the system default.
    var bodyFontDesign: Font.Design {
        switch self {
        case .matrix: return .monospaced
        case .liquidGlass: return .default
        }
    }

    /// Whether chrome surfaces (header/composer bars, input field) render as
    /// translucent glass/material instead of the flat matrix background.
    var usesGlassChrome: Bool {
        self == .liquidGlass
    }

    /// Discriminator mixed into per-message formatting caches so cached
    /// AttributedStrings from one theme are never served under another.
    /// Empty for matrix to keep its historical cache keys.
    var formatCacheVariant: String {
        switch self {
        case .matrix: return ""
        case .liquidGlass: return "lg:"
        }
    }

    /// Resolves the semantic color palette for this theme under the given color scheme.
    func palette(for colorScheme: ColorScheme) -> ThemePalette {
        switch self {
        case .matrix:
            return .matrix(colorScheme)
        case .liquidGlass:
            return .liquidGlass(colorScheme)
        }
    }
}

/// Semantic colors for the active theme, resolved against the current color scheme.
/// Views should consume these via `@ThemedPalette` rather than computing colors inline.
struct ThemePalette {
    /// Primary window/sheet background.
    let background: Color
    /// Primary text color.
    let primary: Color
    /// De-emphasized text (timestamps, hints, captions).
    let secondary: Color
    /// Interactive tint (buttons, toggles, selection).
    let accent: Color
    /// Location/geohash channel accent (badges, counts, subtitles).
    let locationAccent: Color
    /// Informational accent (links, read receipts, teleport markers).
    let accentBlue: Color
    /// Destructive/error accent.
    let alertRed: Color
    /// Hairline separators.
    let divider: Color

    static func matrix(_ colorScheme: ColorScheme) -> ThemePalette {
        let isDark = colorScheme == .dark
        return ThemePalette(
            background: isDark
                ? Color(red: 0.027, green: 0.043, blue: 0.078)
                : Color(red: 0.965, green: 0.973, blue: 0.988),
            primary: isDark
                ? Color(red: 0.93, green: 0.96, blue: 0.98)
                : Color(red: 0.05, green: 0.09, blue: 0.16),
            secondary: isDark
                ? Color(red: 0.62, green: 0.69, blue: 0.78)
                : Color(red: 0.32, green: 0.38, blue: 0.48),
            accent: isDark
                ? Color(red: 0.369, green: 0.918, blue: 0.831)
                : Color(red: 0.059, green: 0.463, blue: 0.431),
            locationAccent: isDark
                ? Color(red: 0.647, green: 0.706, blue: 0.988)
                : Color(red: 0.388, green: 0.400, blue: 0.945),
            accentBlue: isDark
                ? Color(red: 0.220, green: 0.741, blue: 0.973)
                : Color(red: 0.012, green: 0.518, blue: 0.780),
            alertRed: isDark
                ? Color(red: 0.984, green: 0.443, blue: 0.522)
                : Color(red: 0.863, green: 0.149, blue: 0.149),
            divider: isDark ? Color.white.opacity(0.10) : Color.black.opacity(0.07)
        )
    }

    static func liquidGlass(_ colorScheme: ColorScheme) -> ThemePalette {
        let isDark = colorScheme == .dark
        return ThemePalette(
            background: systemBackground,
            primary: .primary,
            secondary: .secondary,
            accent: isDark
                ? Color(red: 0.369, green: 0.918, blue: 0.831)
                : Color(red: 0.059, green: 0.463, blue: 0.431),
            locationAccent: isDark
                ? Color(red: 0.647, green: 0.706, blue: 0.988)
                : Color(red: 0.388, green: 0.400, blue: 0.945),
            accentBlue: .blue,
            alertRed: .red,
            divider: separator
        )
    }

    private static var systemBackground: Color {
        #if os(iOS)
        Color(UIColor.systemBackground)
        #else
        Color(NSColor.windowBackgroundColor)
        #endif
    }

    private static var separator: Color {
        #if os(iOS)
        Color(UIColor.separator)
        #else
        Color(NSColor.separatorColor)
        #endif
    }
}

private struct AppThemeKey: EnvironmentKey {
    static let defaultValue: AppTheme = .matrix
}

extension EnvironmentValues {
    var appTheme: AppTheme {
        get { self[AppThemeKey.self] }
        set { self[AppThemeKey.self] = newValue }
    }
}

/// Resolves the active theme's palette against the view's color scheme.
///
///     @ThemedPalette private var palette
///     var body: some View { Text("hi").foregroundColor(palette.primary) }
@propertyWrapper
struct ThemedPalette: DynamicProperty {
    @Environment(\.appTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    var wrappedValue: ThemePalette { theme.palette(for: colorScheme) }
}

// MARK: - Themed view helpers

/// Themed replacement for `.font(.bitchatSystem(size:weight:design: .monospaced))`:
/// monospaced under matrix, system default under liquid glass.
private struct ThemedFontModifier: ViewModifier {
    @Environment(\.appTheme) private var theme
    let size: CGFloat
    let weight: Font.Weight

    func body(content: Content) -> some View {
        content.font(.bitchatSystem(size: size, weight: weight, design: theme.bodyFontDesign))
    }
}

/// Root backdrop. Matrix gets its flat background; glass gets a subtle static
/// gradient with a soft tinted glow — glass panels need visual texture behind
/// them to refract, and collapse to flat gray over a solid color.
struct ThemedRootBackground: View {
    @Environment(\.appTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @ThemedPalette private var palette

    var body: some View {
        let isDark = colorScheme == .dark
        ZStack {
            palette.background

            // MeshTalk brand atmosphere: a mint node glow in one corner and a
            // periwinkle relay glow in the other. Kept static so the chat
            // surface stays calm while messages move.
            RadialGradient(
                colors: [palette.accent.opacity(isDark ? 0.16 : 0.10), .clear],
                center: .topLeading,
                startRadius: 0,
                endRadius: 560
            )
            RadialGradient(
                colors: [palette.locationAccent.opacity(isDark ? 0.13 : 0.08), .clear],
                center: .bottomTrailing,
                startRadius: 0,
                endRadius: 480
            )

            if theme.usesGlassChrome {
                LinearGradient(
                    colors: isDark
                        ? [Color.white.opacity(0.03), Color.clear]
                        : [Color.white.opacity(0.55), Color.clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
        .ignoresSafeArea()
    }
}

/// Wraps glass-shape content in real Liquid Glass on OS 26+, with a material
/// fallback below that keeps the frosted look.
private struct GlassPanel<S: Shape>: ViewModifier {
    let shape: S

    @ViewBuilder
    func body(content: Content) -> some View {
        #if compiler(>=6.2)
        if #available(iOS 26.0, macOS 26.0, *) {
            content.glassEffect(.regular, in: shape)
        } else {
            materialFallback(content)
        }
        #else
        materialFallback(content)
        #endif
    }

    private func materialFallback(_ content: Content) -> some View {
        content
            .background(shape.fill(.ultraThinMaterial))
            .overlay(shape.stroke(Color.white.opacity(0.15), lineWidth: 0.5))
    }
}

/// Chrome surface for the header and composer. Matrix keeps the original flat
/// edge-to-edge wash; glass floats the content as an inset Liquid Glass panel
/// (content is expected to scroll underneath via safe-area insets).
private struct ThemedChromePanelModifier: ViewModifier {
    @Environment(\.appTheme) private var theme
    @ThemedPalette private var palette
    let edge: VerticalEdge

    @ViewBuilder
    func body(content: Content) -> some View {
        if theme.usesGlassChrome {
            content
                .modifier(GlassPanel(shape: RoundedRectangle(cornerRadius: 18, style: .continuous)))
                .padding(.horizontal, 8)
                .padding(edge == .top ? .top : .bottom, 4)
        } else {
            content.background(palette.background.opacity(0.95))
        }
    }
}

/// Background for the composer input field. Matrix keeps its translucent fill;
/// glass leaves it clear — the field sits inside the composer's glass panel,
/// and glass cannot sample other glass.
private struct ThemedInputBackgroundModifier: ViewModifier {
    @Environment(\.appTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
    }

    @ViewBuilder
    func body(content: Content) -> some View {
        if theme.usesGlassChrome {
            content
        } else {
            content.background(
                shape.fill(colorScheme == .dark ? Color.black.opacity(0.35) : Color.white.opacity(0.7))
            )
        }
    }
}

extension View {
    func bitchatFont(size: CGFloat, weight: Font.Weight = .regular) -> some View {
        modifier(ThemedFontModifier(size: size, weight: weight))
    }

    func themedChromePanel(edge: VerticalEdge) -> some View {
        modifier(ThemedChromePanelModifier(edge: edge))
    }

    func themedInputBackground() -> some View {
        modifier(ThemedInputBackgroundModifier())
    }

    /// Floating surface for popover-style boxes (autocomplete, command
    /// suggestions): glass panel under liquid glass, the original flat
    /// background + hairline stroke under matrix.
    func themedOverlayPanel() -> some View {
        modifier(ThemedOverlayPanelModifier())
    }

    /// Root background for sheets — same backdrop as the main window so every
    /// surface speaks one visual language.
    func themedSheetBackground() -> some View {
        background(ThemedRootBackground())
    }

    /// Flat background wash for bars/headers inside sheets. Matrix keeps its
    /// opaque wash; glass goes transparent so the backdrop gradient shows.
    func themedSurface(opacity: Double = 1.0) -> some View {
        modifier(ThemedSurfaceModifier(opacity: opacity))
    }
}

private struct ThemedSurfaceModifier: ViewModifier {
    @Environment(\.appTheme) private var theme
    @ThemedPalette private var palette
    let opacity: Double

    @ViewBuilder
    func body(content: Content) -> some View {
        if theme.usesGlassChrome {
            content
        } else {
            content.background(palette.background.opacity(opacity))
        }
    }
}

private struct ThemedOverlayPanelModifier: ViewModifier {
    @Environment(\.appTheme) private var theme
    @ThemedPalette private var palette

    @ViewBuilder
    func body(content: Content) -> some View {
        if theme.usesGlassChrome {
            content.modifier(GlassPanel(shape: RoundedRectangle(cornerRadius: 12, style: .continuous)))
        } else {
            content
                .background(palette.background)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(palette.secondary.opacity(0.3), lineWidth: 1)
                )
        }
    }
}
