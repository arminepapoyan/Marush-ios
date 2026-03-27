//
//  AccountView.swift
//  Marush
//
//  Created by s2s s2s on 20.03.2026.
//


import SwiftUI
import SDWebImageSwiftUI
import PhotosUI


struct AccountView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var userData: UserViewModel
    @EnvironmentObject var settings: UserSettings
    @EnvironmentObject var appData: AppDataViewModel
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
                            PageHeaderView(
                                title: getLocalString(string: "my_profile"),
                                showBack: false,
                                showRightButton: false,
                                rightIcon: "trash",
                                onBack: {
                                    presentationMode.wrappedValue.dismiss()
                                },
                                onRightTap: {
                                    print("Delete tapped")
                                }
                            )
                            menuList(showLogout: $showLogoutAlert, settings: settings, userData: userData)
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
            .overlay(
                Group {
                    if showLogoutAlert {
                        CustomConfirmationDialog(
                            isPresented: $showLogoutAlert,
                            title: getLocalString(string: "confirm_logout"),
                            text: getLocalString(string: "are_you_sure_you_want_to_log_out"),
                            confirmButton: getLocalString(string: "logout"),
                            cancelButton: getLocalString(string: "cancel"),
                            onConfirm: {
                                handleLogout(settings: settings);
                            })
                            .transition(.scale)  // Smooth transition animation
                            .animation(.easeInOut, value: showLogoutAlert)
                    }
                }
             )
        }
        .navigationBarHidden(true)
    }
}

struct menuList: View{
    @Binding var showLogout: Bool
    var settings: UserSettings
    var userData: UserViewModel
    var body: some View{
        VStack(spacing: 12){
            menuItem(title: "\(getLocalString(string: "personal_data"))", destination: AnyView(PersonalDataView()), showDialog: .constant(false))
            menuItem(title: "\(getLocalString(string: getLocalString(string: "delivery_addresses")))", destination: AnyView(PersonalDataView()), showDialog: .constant(false))
            menuItem(title: "\(getLocalString(string: getLocalString(string: "shop")))", destination: AnyView(PersonalDataView()), showDialog: .constant(false))
            menuItem(title: "\(getLocalString(string: getLocalString(string: "configs")))", destination: AnyView(PersonalDataView()), showDialog: .constant(false), showsBottomBorder: false)
//            menuItem(image: "ic-heart", title: "\(getLocalString(string: "favorites"))", destination: AnyView(WishlistView()),  showDialog: .constant(false))
//            menuItem(image: "ic-rewards", title: "\(getLocalString(string: "rewards"))", destination: AnyView(RewardsView(dismissArrow: true).environmentObject(settings)), showDialog: .constant(false))
//            menuItem(image: "ic-basket", title: "\(getLocalString(string: "order_history"))", destination: AnyView(OrdersHistoryView(dismissArrow: true)),  showDialog: .constant(false))
//            menuItem(image: "ic-location-dark", title: "\(getLocalString(string: "my_addresses"))",destination: AnyView(AddressesView()),  showDialog: .constant(false))
//            menuItem(image: "ic-payment-card", title: "\(getLocalString(string: "payment_methods"))",destination: AnyView(SavedCardsView()),  showDialog: .constant(false))
//            menuItem(
//                image: "ic-settings",
//                title: "\(getLocalString(string: "settings"))",
//                destination: AnyView(
//                    SettingsView()
//                    .environmentObject(settings)
//                    .environmentObject(userData)
//                ),
//                showDialog: .constant(false)
//            )
//            menuItem(image: "ic-location-dark", title: "\(getLocalString(string: "locations"))",destination: AnyView(LocationsView(dismissArrow: true)),  showDialog: .constant(false))
            LogoutMenuItem(title: "\(getLocalString(string: "logout"))", showDialog: $showLogout)
                .onTapGesture {
                    showLogout.toggle()
                }
        }
    }
}

struct menuItem: View{
    var title: String
    var destination: AnyView
    @Binding var showDialog: Bool
    
    var showsBottomBorder: Bool = true
    
    var body: some View{
        NavigationLink(destination: destination) {
            menuItemButtonView(title: title, showDialog: $showDialog, showsBottomBorder: showsBottomBorder)
        }
    }
}
struct LogoutMenuItem: View{
    var title: String
    @Binding var showDialog: Bool
    
    var body: some View{
        menuItemButtonView(
            title: title,
            showDialog: $showDialog,
            textColor: Color(UIColor(named: "ColorPrimary")!),
            showsArrow: false,
            showsBottomBorder: false
        )
    }
}

struct menuItemButtonView: View {
    var title: String
    @Binding var showDialog: Bool
    var textColor: Color = Color(UIColor(named: "ColorDark")!)
    var showsArrow: Bool = true
    var showsBottomBorder: Bool = true
    
    var body: some View {
        VStack(spacing: 0) {
            
            HStack(spacing: 12) {
                Text(title)
                    .font(.Lato(size: 16))
                    .foregroundColor(textColor)
                
                if showsArrow {
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.black)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical)
            
            if showsBottomBorder {
                Rectangle()
                    .fill(Color(UIColor(named: "CEF0F7")!))
                    .frame(height: 1)
            }
        }
        .padding(.horizontal, 5)
    }
}
