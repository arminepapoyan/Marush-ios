//
//  Styles.swift
//  Marush
//
//  Created by S2S Company on 30.01.2025.
//

import SwiftUI

struct OnboardingButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .frame(height: 49)
                .foregroundColor(configuration.isPressed ? Color(.systemBlue).opacity(0.7) : Color(.systemBlue))
            
            configuration.label
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .opacity(configuration.isPressed ? 0.8 : 1)
        }
        .scaleEffect(configuration.isPressed ? 0.95 : 1.0) // Add a slight scale effect when pressed
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
