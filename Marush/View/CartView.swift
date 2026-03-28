//
//  CartView.swift
//  Marush
//
//  Created by s2s s2s on 29.03.2026.
//


import SwiftUI
import SDWebImageSwiftUI
import PhotosUI


struct CartView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var userData: UserViewModel
    @EnvironmentObject var settings: UserSettings
    @EnvironmentObject var appData: AppDataViewModel
    
    @StateObject var cartData = CartViewModel()
    
    @State var showLogoutAlert: Bool = false
    
    var body: some View {
        NavigationView{
            ZStack(alignment: .top) {
                Color(UIColor(named: "F3E6B1")!)
                    .frame(height: UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0)
                    .ignoresSafeArea(edges: .top)
                VStack(spacing: 0){
                    ScrollView(.vertical,showsIndicators: false){
                        GreetingView(isLoading: .constant(false), searchText: .constant(""), name: userData.name, phone: appData.phone ?? "", horizontalPadding: GlobalSettings.shared.horizontalPadding, settings: settings, backgroundColor: Color(UIColor(named: "F3E6B1")!), showsSearchBar: false)
                        VStack(spacing: 30){
                            
                        }
                        .padding(.horizontal, GlobalSettings.shared.horizontalPadding)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 25)
                        .background(
                            Color(UIColor(named: "F9F9F9")!)
                                .clipShape(
                                    RoundedRectangle(
                                        cornerRadius: 30,
                                        style: .continuous
                                    )
                                )
                        )
                        .offset(y: -25)
                        bottomShadowIgnore(count: UIDevice.current.localizedModel == "iPad" ? 7 : settings.cart_count == 0 ? 2 : 5)
                    }
                    .coordinateSpace(name: "scroll")
                }
                .onTapGesture {
                    hideKeyboard()
                }
            }
        }
        .navigationBarHidden(true)
    }
}
