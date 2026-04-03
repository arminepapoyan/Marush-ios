//
//  AccountView.swift
//  Marush
//
//  Created by s2s s2s on 20.03.2026.
//


import SwiftUI
import SDWebImageSwiftUI
import PhotosUI

// MARK: - Environment key so any overlay destination's HeaderView can self-dismiss

private struct OverlayDismissKey: EnvironmentKey {
    static let defaultValue: (() -> Void)? = nil
}

extension EnvironmentValues {
    var overlayDismiss: (() -> Void)? {
        get { self[OverlayDismissKey.self] }
        set { self[OverlayDismissKey.self] = newValue }
    }
}

// MARK: - AccountView

struct AccountView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var userData: UserViewModel
    @EnvironmentObject var settings: UserSettings
    @EnvironmentObject var appData: AppDataViewModel
    @State var showLogoutAlert: Bool = false
    /// The destination view currently sliding in from the right (nil = hidden).
    @State private var activeDestination: AnyView? = nil

    var body: some View {
        ZStack(alignment: .top) {
            // Yellow safe-area background behind GreetingView
            Color(UIColor(named: "F3E6B1")!)
                .frame(height: UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0)
                .ignoresSafeArea(edges: .top)

            VStack(spacing: 0) {
                // ── GreetingView — always visible, never animates ────────────────
                GreetingView(
                    isLoading: .constant(false),
                    searchText: .constant(""),
                    name: userData.name,
                    phone: appData.phone ?? "",
                    horizontalPadding: GlobalSettings.shared.horizontalPadding,
                    settings: settings,
                    backgroundColor: Color(UIColor(named: "F3E6B1")!),
                    showsSearchBar: false
                )
                .background(Color(UIColor(named: "F3E6B1")!))

                // ── Content card — destination slides in here (mirrors HomeView) ─
                ZStack(alignment: .top) {

                    // Main menu content
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 30) {
                            PageHeaderView(
                                title: getLocalString(string: "my_profile"),
                                showBack: false,
                                showRightButton: false,
                                rightIcon: "trash",
                                onBack: { presentationMode.wrappedValue.dismiss() },
                                onRightTap: { print("Delete tapped") }
                            )
                            menuList(
                                showLogout: $showLogoutAlert,
                                activeDestination: $activeDestination,
                                settings: settings,
                                userData: userData,
                                appData: appData
                            )
                        }
                        .padding(.horizontal, GlobalSettings.shared.horizontalPadding)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 25)
                        bottomShadowIgnore(count: UIDevice.current.localizedModel == "iPad" ? 7 : settings.cart_count == 0 ? 2 : 5)
                    }
                    .coordinateSpace(name: "scroll")

                    // Destination slides in from trailing over menu content only
                    if let destination = activeDestination {
                        destination
                            .environment(\.overlayDismiss, {
                                withAnimation(.easeInOut(duration: 0.28)) {
                                    activeDestination = nil
                                }
                            })
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing),
                                removal: .move(edge: .trailing)
                            ))
                            .zIndex(1)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(UIColor(named: "F9F9F9")!))
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .padding(.top, -30)
            }
            .onTapGesture { hideKeyboard() }
        }
        .background(Color(UIColor(named: "F3E6B1")!).ignoresSafeArea())
        .overlay(
            Group {
                if showLogoutAlert {
                    CustomConfirmationDialog(
                        isPresented: $showLogoutAlert,
                        title: getLocalString(string: "confirm_logout"),
                        text: getLocalString(string: "are_you_sure_you_want_to_log_out"),
                        confirmButton: getLocalString(string: "logout"),
                        cancelButton: getLocalString(string: "cancel"),
                        onConfirm: { handleLogout(settings: settings) }
                    )
                    .transition(.scale)
                    .animation(.easeInOut, value: showLogoutAlert)
                }
            }
        )
        .animation(.easeInOut(duration: 0.28), value: activeDestination != nil)
    }
}

// MARK: - menuList

struct menuList: View {
    @Binding var showLogout: Bool
    @Binding var activeDestination: AnyView?
    var settings: UserSettings
    var userData: UserViewModel
    var appData: AppDataViewModel

    var body: some View {
        VStack(spacing: 12) {
            menuItem(
                title: getLocalString(string: "personal_data"),
                destination: AnyView(
                    PersonalDataView()
                        .environmentObject(userData)
                        .environmentObject(appData)
                        .environmentObject(settings)
                ),
                showDialog: .constant(false),
                activeDestination: $activeDestination
            )
            menuItem(
                title: getLocalString(string: "delivery_addresses"),
                destination: AnyView(
                    AddressesView()
                        .environmentObject(userData)
                        .environmentObject(appData)
                        .environmentObject(settings)
                ),
                showDialog: .constant(false),
                activeDestination: $activeDestination
            )
            menuItem(title: getLocalString(string: "shop"),               destination: AnyView(EmptyView()), showDialog: .constant(false), activeDestination: $activeDestination)
            menuItem(title: getLocalString(string: "configs"),            destination: AnyView(EmptyView()), showDialog: .constant(false), activeDestination: $activeDestination, showsBottomBorder: false)
//            menuItem(title: getLocalString(string: "favorites"),        destination: AnyView(WishlistView()),                                                         showDialog: .constant(false), activeDestination: $activeDestination)
//            menuItem(title: getLocalString(string: "rewards"),          destination: AnyView(RewardsView(dismissArrow: true).environmentObject(settings)),           showDialog: .constant(false), activeDestination: $activeDestination)
//            menuItem(title: getLocalString(string: "order_history"),    destination: AnyView(OrdersHistoryView(dismissArrow: true)),                                 showDialog: .constant(false), activeDestination: $activeDestination)
//            menuItem(title: getLocalString(string: "my_addresses"),     destination: AnyView(AddressesView()),                                                       showDialog: .constant(false), activeDestination: $activeDestination)
//            menuItem(title: getLocalString(string: "payment_methods"),  destination: AnyView(SavedCardsView()),                                                      showDialog: .constant(false), activeDestination: $activeDestination)
//            menuItem(title: getLocalString(string: "settings"),         destination: AnyView(SettingsView().environmentObject(settings).environmentObject(userData)),showDialog: .constant(false), activeDestination: $activeDestination)
//            menuItem(title: getLocalString(string: "locations"),        destination: AnyView(LocationsView(dismissArrow: true)),                                     showDialog: .constant(false), activeDestination: $activeDestination)
            LogoutMenuItem(title: getLocalString(string: "logout"), showDialog: $showLogout)
                .onTapGesture { showLogout.toggle() }
        }
    }
}

// MARK: - menuItem

struct menuItem: View {
    var title: String
    var destination: AnyView
    @Binding var showDialog: Bool
    @Binding var activeDestination: AnyView?
    var showsBottomBorder: Bool = true

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.28)) {
                activeDestination = destination
            }
        } label: {
            menuItemButtonView(title: title, showDialog: $showDialog, showsBottomBorder: showsBottomBorder)
        }
        .buttonStyle(.plain)
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
