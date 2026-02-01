//
//  HelpersView.swift
//  Marush
//
//  Created by S2S Company on 30.01.2025.
//

// Helper shape for specific corner rounding
import SwiftUI

struct RoundedCornersShape: Shape {
    var corners: UIRectCorner
    var radius: CGFloat

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}


struct ScrollOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct DashedDivider: View {
    var color: Color = Color(UIColor(named: "ABABAB")!)
    var body: some View {
        Rectangle()
            .stroke(style: StrokeStyle(lineWidth: 0.5, dash: [5, 3])) // Dash and space pattern
            .frame(height: 0.5)
            .foregroundColor(color)
    }
}
