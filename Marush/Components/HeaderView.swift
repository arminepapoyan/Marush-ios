//
//  HeaderView.swift
//  Marush
//
//  Created by S2S Company on 30.01.2025.
//

import SwiftUI

struct HeaderView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var title: String = "Your Rewards"
    var showArrow: Bool = true
    var title_img: Bool = false
    
    var body: some View {
        HStack{
            // Back Button
            if showArrow {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .font(.title)
                        .foregroundColor(.black)
                }
            }
            
            Spacer()
            
            // Title in the center
            if title_img{
                Image("gIcon")
                    .resizable()
                    .frame(width: 50, height: 50)
            } else{
                Text("\(title)")
                    .font(.PoppinsBold(size: 16))
                    .fontWeight(.bold)
            }
        
            
            Spacer()
        }
        .padding(.vertical, 15)
        .background(Color.white)
    }
}

struct HeaderSearchView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Binding var searchText: String
    var showArrow: Bool = true
    
    var body: some View {
        HStack{
            // Back Button
            if showArrow {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .font(.title)
                        .foregroundColor(.black)
                }
            }
            
            Spacer()
            HStack {
                ZStack(alignment: .leading) {
                    if searchText.isEmpty {
                        Text("Search")
                            .foregroundColor(Color(UIColor(named: "CustomGray")!))
                            .font(.Poppins(size: 16))
                            .padding(.horizontal, 10)
                    }
                                            
                    TextField("", text: $searchText)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .font(.Poppins(size: 16))
                        .foregroundColor(.black)
                        .offset(y: 0)
                        .padding(.horizontal, 10)
                }
                .padding(.vertical, 9)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color(UIColor(named: "CustomGray")!), lineWidth: 1)
                )
                .overlay(alignment: .trailing){
                    VStack(alignment: .trailing) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 20))
                            .foregroundColor(Color(UIColor(named: "CustomGray")!))
                            .padding(.trailing, 20)
                    }
                }
                .cornerRadius(15)
            }
            .frame(width: showArrow ? 270 : nil)
            .frame(maxWidth: !showArrow ? .infinity : nil)
            .padding(.vertical, 9)
            .background(Color.white)
            .padding(.horizontal)
        }
        .padding(.vertical, 15)
        .background(Color.white)
    }
}

#Preview {
    HeaderView(title: "Your Rewards", showArrow: true, title_img: true)
}
