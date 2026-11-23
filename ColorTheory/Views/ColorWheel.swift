//
//  ColorWheel.swift
//  ColorTheory
//

import SwiftUI

/// A twelve-color wheel that highlights a temperature or a color scheme.
struct ColorWheel: View {
    enum Highlight {
        case warm, cool, complementary, analogous, triadic

        /// Wheel indices to emphasize, clockwise from red.
        var indices: [Int] {
            switch self {
            case .warm: return [11, 0, 1, 2, 3, 4]
            case .cool: return [5, 6, 7, 8, 9, 10]
            case .complementary: return [2, 8]
            case .analogous: return [7, 8, 9]
            case .triadic: return [0, 4, 8]
            }
        }

        var caption: String? {
            switch self {
            case .warm, .cool: return nil
            case .complementary: return "2 colors: opposite"
            case .analogous: return "3 colors: side by side"
            case .triadic: return "3 colors: equally spaced around the wheel"
            }
        }

        /// Warm and cool dim the other half; schemes point at their colors.
        var dimsOthers: Bool { self == .warm || self == .cool }

        /// Opposite and evenly spaced colors are joined by lines; neighbors only get markers.
        var connects: Bool { self == .complementary || self == .triadic }
    }

    let highlight: Highlight

    private let thickness: CGFloat = 0.28

    var body: some View {
        VStack(spacing: 10) {
            GeometryReader { geo in
                let side = min(geo.size.width, geo.size.height)
                ZStack {
                    ForEach(Palette.wheel.indices, id: \.self) { index in
                        RingSegment(index: index, thickness: thickness)
                            .fill(Color(hex: Palette.wheel[index].hex))
                            .opacity(highlight.dimsOthers && !highlight.indices.contains(index) ? 0.2 : 1)
                    }
                    if highlight.connects {
                        Connector(indices: highlight.indices, radius: 1 - thickness - 0.06)
                            .stroke(Color.white.opacity(0.7), lineWidth: 1.5)
                    }
                    if !highlight.dimsOthers {
                        ForEach(highlight.indices, id: \.self) { index in
                            Marker(index: index)
                                .fill(Color.white)
                        }
                    }
                }
                .frame(width: side, height: side)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .aspectRatio(1, contentMode: .fit)
            if let caption = highlight.caption {
                Text(caption).font(.footnote).foregroundColor(.secondary).multilineTextAlignment(.center)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Color wheel highlighting " + ListFormatter.localizedString(byJoining: highlight.indices.map { Palette.wheel[$0].name }))
    }
}

private func angle(for index: Int) -> Angle { .degrees(Double(index) * 30 - 90) }

private struct RingSegment: Shape {
    let index: Int
    let thickness: CGFloat

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outer = min(rect.width, rect.height) / 2 * 0.86
        let inner = outer * (1 - thickness)
        let start = angle(for: index) - .degrees(15)
        let end = angle(for: index) + .degrees(15)
        var path = Path()
        path.addArc(center: center, radius: outer, startAngle: start, endAngle: end, clockwise: false)
        path.addArc(center: center, radius: inner, startAngle: end, endAngle: start, clockwise: true)
        path.closeSubpath()
        return path
    }
}

/// Lines between the highlighted colors, inside the ring.
private struct Connector: Shape {
    let indices: [Int]
    let radius: CGFloat

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let r = min(rect.width, rect.height) / 2 * 0.86 * radius
        let points = indices.map { index -> CGPoint in
            let a = angle(for: index).radians
            return CGPoint(x: center.x + r * CGFloat(cos(a)), y: center.y + r * CGFloat(sin(a)))
        }
        var path = Path()
        path.addLines(points)
        if points.count > 2 { path.closeSubpath() }
        return path
    }
}

/// A small triangle just outside the ring, pointing at a color.
private struct Marker: Shape {
    let index: Int

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outer = min(rect.width, rect.height) / 2
        let a = angle(for: index).radians
        let tip = outer * 0.88, base = outer * 0.99, half = outer * 0.05
        func point(_ radius: CGFloat, _ offset: CGFloat) -> CGPoint {
            CGPoint(x: center.x + radius * CGFloat(cos(a)) - offset * CGFloat(sin(a)),
                    y: center.y + radius * CGFloat(sin(a)) + offset * CGFloat(cos(a)))
        }
        var path = Path()
        path.move(to: point(tip, 0))
        path.addLine(to: point(base, half))
        path.addLine(to: point(base, -half))
        path.closeSubpath()
        return path
    }
}

struct ColorWheel_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            ColorWheel(highlight: .warm)
            ColorWheel(highlight: .complementary)
            ColorWheel(highlight: .triadic)
        }
        .padding()
        .background(Color.black)
        .preferredColorScheme(.dark)
    }
}
