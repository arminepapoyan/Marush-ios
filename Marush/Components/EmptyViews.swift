//
//  EmptyViews.swift
//  Marush
//
//  Created by S2S Company on 30.01.2025.
//

import SwiftUI

struct EmptyListView: View {
    @EnvironmentObject var settings: UserSettings
    var title: String = ""

    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            Text("\(title)")
                .font(.PoppinsBold(size: 16))
            Button(action: {
                // Trigger the dialog closing and set the flag to navigate to ShopView
                settings.showCartDialog = false
                settings.selection = 2
            }) {
                Text("back_to_shopping")
                    .font(.Poppins(size: 18))
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 10)
                    .background(Color(UIColor(named: "0A7E56")!)) // Background color for the button
                    .cornerRadius(30)
            }
            .padding(.top, 20)
            Spacer()
        }
        .frame(maxHeight: .infinity)
        .padding()
    }
}

