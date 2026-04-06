//
//  LocationsView.swift
//  Marush
//
//  Created by s2s s2s on 07.04.2026.
//

import SwiftUI
import Shimmer
import SDWebImageSwiftUI

struct LocationsView: View {
    
    var dismissArrow: Bool = false
    @StateObject private var locationsVM =  LocationsViewModel()
    @State private var location: [Location] = []
    @State var isLoading = true
    
    @State var title: String = getLocalString(string: "locations")

    var body: some View {
        VStack(spacing: 0) {
            HeaderView(title: title, showArrow: true)
                .padding(.horizontal)

            ScrollView(.vertical, showsIndicators: false) {
                if isLoading{
                    VStack(spacing: 12){
                        ForEach(0..<5, id: \.self) { _ in
                            LocationCardShimmer()
                        }
                    }
                } else{
                    VStack(spacing: 40) {
                        RotatingImageAroundCenter()
                        VStack(spacing: 40) {
                            ForEach(locationsVM.data) { location in
                                LocationCard(location: location)
                            }
                        }
                    }
                    .padding(.top, 30)
                }
                bottomShadowIgnore(count: 4)
            }
            .refreshable {
                loadData()
            }
            .padding(.bottom)
          
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor(named: "F9F9F9")!))
        .onTapGesture { hideKeyboard() }
        .onAppear {
            loadData()
        }
        .navigationBarHidden(true)
        .onReceive(locationsVM.$data) { data in
            // When the data changes, set isLoading to false
            if !data.isEmpty {
                isLoading = false
            }
        }
       
    }
    
    func loadData(){
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            locationsVM.getData { data in
                if let data = data {
                    locationsVM.updateData(data)
                } else {
                    print("Failed to fetch app data.")
                }
                isLoading = false
            }
        }
    }

}

struct RotatingImageAroundCenter: View {
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            // Center image
            Image("MarushIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
            
            // Rotating image (text image)
            Image("hugsText")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(rotation))
                .animation(
                    .linear(duration: 8) // speed
                        .repeatForever(autoreverses: false),
                    value: rotation
                )
        }
        .onAppear {
            rotation = 360
        }
    }
}


struct LocationCard: View {
    let location: Location
    @State var show: Bool = false
    @State var webViewFinishedLoading = false
    var body: some View {
        VStack{
            VStack(alignment: .leading, spacing: 15){
                VStack(alignment: .leading, spacing: 12) {
                    // Image Section
                    VStack{
                        if let image = location.image{
                            WebImage(url: URL(string: image))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 125)
                                .cornerRadius(15)
                                .clipped()
                                .contentShape(Rectangle())
                        }
                    }
                    
                    HStack {
                        Text(location.name)
                            .font(.LatoBold(size: 16))
                            .foregroundColor(Color(UIColor(named: "ColorDark")!).opacity(0.8))
                        Spacer()
                        if let status = location.status{
//                            Text(location.isOpen ? "now open" : "closed")
                            Text(status)
                                .font(.Lato(size: 14))
                                .foregroundColor(.black)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
//                                .background(Color(UIColor(named: location.isOpen ? "" : "ColorDark")!))
                                .cornerRadius(15)
                        }
                    }
                    
                    if let hours = location.hours{
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20)
                                .foregroundColor(Color(UIColor(named: "ColorDark")!).opacity(0.8))
                            Text("\(getLocalString(string: "open_hours")):")
                                .font(.Lato(size: 16))
                                .foregroundColor(Color(UIColor(named: "ColorDark")!).opacity(0.8))
                            Text(hours)
                                .font(.Lato(size: 16))
                                .foregroundColor(Color(UIColor(named: "ColorDark")!).opacity(0.8))
                        }
                    }
                }
                Button(action: {
                    withAnimation{
                        show = true
                    }
                }) {
                    HStack(spacing: 12) {
                        Text("get_directions")
                            .font(.LatoBold(size: 16))
                            .foregroundColor(Color(UIColor(named: "ColorDark")!))
                        Image(systemName: "arrow.right")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 13)
                            .foregroundColor(Color(UIColor(named: "ColorDark")!))
                    }
                }
                .zIndex(9)
                
                Divider()
                    .frame(height: 1)
//                    .padding(.horizontal, 30)
                    .background(Color(UIColor(named: "F9F9F9")!))
            }
            .padding(.horizontal)
            
            if show{
                ZStack{
                    VStack{
                        ZStack(alignment: .bottomLeading){
                            WebView(url: Constants.API_URL+"/map/getMapShop/\(location.id)")
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 90, height: 30)
                                .foregroundColor(Color.black.opacity(0.01))
                                .padding(.leading, 10)
                                .padding(.bottom, 10)
                                .onTapGesture {
                                    if let coordinates = location.coordinates, coordinates.count >= 2 {
                                        let coord1 = coordinates[0].replacingOccurrences(of: " ", with: "")
                                        let coord2 = coordinates[1].replacingOccurrences(of: " ", with: "")
                                        
                                        // Construct the URL correctly
                                        if let url = URL(string: "https://yandex.ru/maps/?rtext=~\(coord1)%2C\(coord2)") {
                                            UIApplication.shared.open(url)
                                        }
                                    }
                                }
                           
                        }
                        
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 160)
                }
                .padding(.top, 40)
                .padding(.bottom, 10)
                .overlay(
                    // Add close icon in top-right corner
                    Button(action: {
                        withAnimation{
                            show = false
                        }
                    }) {
                        Image(systemName: "xmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 15)
                            .foregroundColor(Color(UIColor(named: "ColorDark")!).opacity(0.8))
                    }
                        .padding()
                        .background(Color.clear), // Ensure clear background for button
                    alignment: .topTrailing
                )
                .background(Color(UIColor(named: "F9F9F9")!))
            }
        }
        .onAppear{
            print("Location data is \(location)")
        }
    }
}

