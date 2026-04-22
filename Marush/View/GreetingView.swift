//
//  GreetingView.swift
//  Marush
//
//  Created by s2s s2s on 20.03.2026.
//

import SwiftUI

enum GreetingContext {
    case home
    case search
}

struct GreetingView: View {
    @EnvironmentObject var userData: UserViewModel
    @EnvironmentObject var appData: AppDataViewModel

    @Binding var isLoading: Bool
    @Binding var searchText: String

    var name: String = ""
    var phone: String = ""
    var horizontalPadding: CGFloat = 0
    var settings: UserSettings

    var context: GreetingContext = .home
    var onSearchTap: (() -> Void)? = nil
    @FocusState private var isSearchFocused: Bool

    var backgroundColor: Color = Color(UIColor(named: "CEF0F7")!)
    var showsSearchBar: Bool = true
    var onBack: (() -> Void)? = nil

    @State private var showAddressPicker   = false
    @State private var showNotifications   = false

    var body: some View {
        VStack(alignment: .leading) {
            VStack(spacing: 24) {
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("\(getLocalString(string: "hi")) \(name)")
                            .font(.Poppins(size: 14))
                        
                        Button {
                            showAddressPicker = true
                        } label: {
                            HStack(spacing: 4) {
                                Text(selectedAddress)
                                    .font(.Poppins(size: 14))
                                    .foregroundColor(Color(UIColor(named: "ColorDark")!))
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 9, weight: .semibold))
                                    .foregroundColor(Color(UIColor(named: "ColorDark")!))
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    
                    Spacer()
                    
                    CallButton(phone: phone)
                    Button {
                        showNotifications = true
                    } label: {
                        CircleIcon(
                            imageName: "ic-notifications",
                            badgeCount: settings.noti_count > 0 ? settings.noti_count : nil
                        )
                    }
                    .buttonStyle(.plain)
                }
                
                if showsSearchBar {
                    HStack(spacing: 10) {
                        if context == .search, let onBack = onBack {
                            Button(action: onBack) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(Color(UIColor(named: "ColorDark")!))
                                    .frame(width: 36, height: 36)
                                    .background(
                                        Circle().fill(Color.black.opacity(0.06))
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                        SearchBar(
                            text: $searchText,
                            isFocused: $isSearchFocused,
                            isEditable: context == .search
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            handleSearchTap()
                        }
                    }
                }
            }
            .padding(.bottom, 10)
            .transition(.opacity.animation(.linear(duration: 0.2)))
        }
        .onAppear {
            if context == .search {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isSearchFocused = true
                }
            }
        }
        .padding(.top, 0)
        .padding(.bottom, 40)
        .padding(.horizontal, horizontalPadding)
        .background(backgroundColor)
        .sheet(isPresented: $showAddressPicker) {
            AddressPickerSheet(isPresented: $showAddressPicker)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showNotifications) {
            NotificationsView(isPresented: $showNotifications)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }
    
    private var selectedAddress: String {
        let defaultAddress = appData.addresses.first(where: { $0.isDefault == 1 })
            ?? appData.addresses.first
        if let address = defaultAddress, !address.address.isEmpty {
            return address.address
        }
        return getLocalString(string: "select_delivery_address")
    }

    private func handleSearchTap() {
        switch context {
        case .home:
            onSearchTap?()
        case .search:
            isSearchFocused = true
        }
    }
}
