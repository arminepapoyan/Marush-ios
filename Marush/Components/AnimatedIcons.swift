//
//  AnimatedIcons.swift
//  Marush
//
//  Created by s2s s2s on 19.02.2026.
//
import SwiftUI

enum BenefitAnimationType {
    case rotateWithPause
    case continuous
    case swing180
}


struct AnimatedBenefitIcon: View {
    
    let imageName: String
    let type: BenefitAnimationType
    
    @State private var rotation: Double = 0
    @State private var timer: Timer?
    
    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
            .rotationEffect(.degrees(rotation))
            .onAppear {
                startAnimation()
            }
            .onDisappear {
                timer?.invalidate()
            }
    }
}
private extension AnimatedBenefitIcon {
    func startAnimation() {
        switch type {
            
            // 🔵 Continuous — never stops
        case .continuous:
            withAnimation(
                .linear(duration: 4)
                .repeatForever(autoreverses: false)
            ) {
                rotation = 360
            }
            
            // 🟢 Rotate → Stop → Wait → Repeat
        case .rotateWithPause:
            rotateWithPauseLoop()
            
            
        case .swing180:
            startSwing()
        }
    }
    
    func rotateWithPauseLoop() {
        // Rotate once
        withAnimation(.linear(duration: 2)) {
            rotation += 360
        }
        
        // Wait 60 seconds, then rotate again
        timer = Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { _ in
            withAnimation(.linear(duration: 2)) {
                rotation += 360
            }
        }
    }
    func startSwing() {
        rotation = -90
        
        withAnimation(
            .easeInOut(duration: 2)
            .repeatForever(autoreverses: true)
        ) {
            rotation = 90
        }
    }

}

