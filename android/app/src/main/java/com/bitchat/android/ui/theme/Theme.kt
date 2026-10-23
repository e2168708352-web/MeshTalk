package com.bitchat.android.ui.theme

import android.app.Activity
import android.os.Build
import android.view.View
import android.view.WindowInsetsController
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.SideEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalView

// Standard UI semantics live in Material so stock components and custom Bitchat composables
// share one source of truth. LocalBitchatPalette below only supplies app-specific extra colors.
internal val DarkBitchatColorScheme = darkColorScheme(
    // MeshTalk's deep-ink surface with mint mesh links and a periwinkle relay accent.
    primary = Color(0xFF5EEAD4),
    onPrimary = Color(0xFF042F2E),
    primaryContainer = Color(0xFF123D3A),
    onPrimaryContainer = Color(0xFFB8FFF3),
    secondary = Color(0xFFA5B4FC),
    onSecondary = Color(0xFF1E1B4B),
    secondaryContainer = Color(0xFF2A2A5E),
    onSecondaryContainer = Color(0xFFDDE1FF),
    tertiary = DarkBitchatPalette.accentOrange,
    onTertiary = Color(0xFF2B1700),
    background = Color(0xFF070B14),
    onBackground = Color(0xFFE6EDF5),
    surface = Color(0xFF0D1424),
    onSurface = Color(0xFFE7EEF7),
    surfaceVariant = Color(0xFF151F34),
    onSurfaceVariant = Color(0xFF93A4BA),
    outline = Color(0xFF26344D),
    outlineVariant = Color(0xFF1A2334),
    error = Color(0xFFFF6B7A),
    onError = Color(0xFF2B0A10)
)

internal val LightBitchatColorScheme = lightColorScheme(
    primary = Color(0xFF0F766E),
    onPrimary = Color.White,
    primaryContainer = Color(0xFFCCFBF1),
    onPrimaryContainer = Color(0xFF042F2E),
    secondary = Color(0xFF4F46E5),
    onSecondary = Color.White,
    secondaryContainer = Color(0xFFE0E7FF),
    onSecondaryContainer = Color(0xFF1E1B4B),
    tertiary = LightBitchatPalette.accentOrange,
    onTertiary = Color.White,
    background = Color(0xFFF7F9FC),
    onBackground = Color(0xFF0B1524),
    surface = Color(0xFFEEF3F9),
    onSurface = Color(0xFF0B1524),
    surfaceVariant = Color(0xFFE3EAF3),
    onSurfaceVariant = Color(0xFF4A5B72),
    outline = Color(0xFFC4D0E0),
    outlineVariant = Color(0xFFDCE4EE),
    error = Color(0xFFD92D20),
    onError = Color.White
)

@Composable
fun BitchatTheme(
    darkTheme: Boolean? = null,
    content: @Composable () -> Unit
) {
    // App-level override from ThemePreferenceManager
    val themePref by ThemePreferenceManager.themeFlow.collectAsState(initial = ThemePreference.System)
    val shouldUseDark = when (darkTheme) {
        true -> true
        false -> false
        null -> when (themePref) {
            ThemePreference.Dark -> true
            ThemePreference.Light -> false
            ThemePreference.System -> isSystemInDarkTheme()
        }
    }

    val colorScheme = if (shouldUseDark) DarkBitchatColorScheme else LightBitchatColorScheme
    val palette = if (shouldUseDark) DarkBitchatPalette else LightBitchatPalette

    val view = LocalView.current
    SideEffect {
        (view.context as? Activity)?.window?.let { window ->
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                window.insetsController?.setSystemBarsAppearance(
                    if (!shouldUseDark) WindowInsetsController.APPEARANCE_LIGHT_STATUS_BARS else 0,
                    WindowInsetsController.APPEARANCE_LIGHT_STATUS_BARS
                )
            } else {
                @Suppress("DEPRECATION")
                window.decorView.systemUiVisibility = if (!shouldUseDark) {
                    View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR
                } else 0
            }
            window.navigationBarColor = colorScheme.background.toArgb()
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                window.isNavigationBarContrastEnforced = false
            }
        }
    }

    CompositionLocalProvider(LocalBitchatPalette provides palette) {
        MaterialTheme(
            colorScheme = colorScheme,
            typography = Typography,
            content = content
        )
    }
}
