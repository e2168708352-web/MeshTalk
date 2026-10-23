//
// MeshMark.swift
// MeshTalk
//
// This is free and unencumbered software released into the public domain.
// For more information, see <https://unlicense.org>
//

import SwiftUI

/// Three nodes joined by links: the MeshTalk mark used in the header and
/// onboarding surfaces. Drawn rather than shipped as an asset so it stays
/// crisp at every dynamic type size and tint.
struct MeshMark: View {
    var size: CGFloat = 18
    var color: Color = .accentColor
    var lineWidth: CGFloat? = nil

    var body: some View {
        Canvas { context, canvasSize in
            let w = canvasSize.width
            let h = canvasSize.height
            let points = [
                CGPoint(x: w * 0.50, y: h * 0.14),
                CGPoint(x: w * 0.14, y: h * 0.82),
                CGPoint(x: w * 0.86, y: h * 0.82)
            ]

            var links = Path()
            links.move(to: points[0])
            links.addLine(to: points[1])
            links.addLine(to: points[2])
            links.closeSubpath()

            context.stroke(
                links,
                with: .color(color.opacity(0.55)),
                style: StrokeStyle(
                    lineWidth: lineWidth ?? max(1, size * 0.09),
                    lineCap: .round,
                    lineJoin: .round
                )
            )

            for point in points {
                let radius = max(1.4, size * 0.14)
                let rect = CGRect(
                    x: point.x - radius,
                    y: point.y - radius,
                    width: radius * 2,
                    height: radius * 2
                )
                context.fill(Path(ellipseIn: rect), with: .color(color))
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}
