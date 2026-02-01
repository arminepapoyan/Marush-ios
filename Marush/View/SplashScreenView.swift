//
//  SplashScreenView.swift
//  Marush
//
//  Created by s2s s2s on 30.01.2026.
//
import SwiftUI

struct SplashScreenView: View {

    let namespace: Namespace.ID
    let onFinish: () -> Void

    @State private var circleOffsetY: CGFloat = -UIScreen.main.bounds.height / 2
    @State private var circleScale: CGFloat = 0.2
    @State private var logoOpacity: Double = 0
    @State private var logoScale: CGFloat = 0.65

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            Circle()
                .fill(Color(UIColor(named: "CEF0F7")!))
                .frame(width: 100, height: 100)
                .scaleEffect(circleScale)
                .offset(y: circleOffsetY)
                .ignoresSafeArea()

            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 280)
                .opacity(logoOpacity)
                .scaleEffect(logoScale)
                .matchedGeometryEffect(id: "logo", in: namespace)
        }
        .onAppear {
            startAnimation()
        }
    }

    private func startAnimation() {

        withAnimation(.easeOut(duration: 1)) {
            circleOffsetY = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeInOut(duration: 1)) {
                circleScale = 15
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeIn(duration: 1)) {
                logoOpacity = 1
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            withAnimation(.easeOut(duration: 1)) {
                logoScale = 1
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
            onFinish()
        }
    }
}
