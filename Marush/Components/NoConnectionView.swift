//
//  NoConnectionView.swift
//  Marush
//
//  Created by s2s s2s on 01.02.2026.
//
import SwiftUI

struct NoConnectionView: View {
    @Binding var interactiveDismissDisabled: Bool // Bind the interactive dismiss state

    var body: some View {
        VStack(spacing: 20) {
            Image("ic-no-connection")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
            
            Text("No Internet Connection")
                .font(.PoppinsBold(size: 16))
                .foregroundColor(.black)
                .padding(.top)
            
            Text("Please check your internet connection.")
                .font(.PoppinsMedium(size: 14))
                .foregroundColor(.black)
                .padding(.bottom)
        }
        .padding()
        .presentationDetents([.height(300)]) // Optional, can control sheet size
        .interactiveDismissDisabled(interactiveDismissDisabled) // Use the binding here
    }
}
