package com.bitchat.android.core.ui.icon

import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.StrokeJoin
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.graphics.vector.path
import androidx.compose.ui.unit.dp

/**
 * MeshTalk's three-node mark.
 *
 * Kept behind the historical [BitChatIcon] property name so the rest of the
 * Compose tree does not need a package-wide rename. The drawing itself is new:
 * three peers joined by the mesh links, matching the iOS `MeshMark` view.
 */
val BitChatIcon: ImageVector
    get() {
        _BitChatIcon?.let { return it }

        return ImageVector.Builder(
            name = "MeshTalkMark",
            defaultWidth = 24.dp,
            defaultHeight = 24.dp,
            viewportWidth = 8f,
            viewportHeight = 8f,
        ).apply {
            path(
                stroke = SolidColor(Color.Black.copy(alpha = 0.55f)),
                strokeLineWidth = 0.55f,
                strokeLineCap = StrokeCap.Round,
                strokeLineJoin = StrokeJoin.Round,
            ) {
                moveTo(4f, 1.3f)
                lineTo(1.3f, 6.5f)
                lineTo(6.7f, 6.5f)
                close()
            }
            path(fill = SolidColor(Color.Black)) {
                moveTo(4f, 0.3f)
                curveTo(4.55f, 0.3f, 5f, 0.75f, 5f, 1.3f)
                curveTo(5f, 1.85f, 4.55f, 2.3f, 4f, 2.3f)
                curveTo(3.45f, 2.3f, 3f, 1.85f, 3f, 1.3f)
                curveTo(3f, 0.75f, 3.45f, 0.3f, 4f, 0.3f)
                close()
                moveTo(1.3f, 5.5f)
                curveTo(1.85f, 5.5f, 2.3f, 5.95f, 2.3f, 6.5f)
                curveTo(2.3f, 7.05f, 1.85f, 7.5f, 1.3f, 7.5f)
                curveTo(0.75f, 7.5f, 0.3f, 7.05f, 0.3f, 6.5f)
                curveTo(0.3f, 5.95f, 0.75f, 5.5f, 1.3f, 5.5f)
                close()
                moveTo(6.7f, 5.5f)
                curveTo(7.25f, 5.5f, 7.7f, 5.95f, 7.7f, 6.5f)
                curveTo(7.7f, 7.05f, 7.25f, 7.5f, 6.7f, 7.5f)
                curveTo(6.15f, 7.5f, 5.7f, 7.05f, 5.7f, 6.5f)
                curveTo(5.7f, 5.95f, 6.15f, 5.5f, 6.7f, 5.5f)
                close()
            }
        }.build().also { _BitChatIcon = it }
    }

private var _BitChatIcon: ImageVector? = null
