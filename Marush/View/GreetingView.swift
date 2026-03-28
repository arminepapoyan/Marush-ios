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

    var body: some View {
        VStack(alignment: .leading) {
            VStack(spacing: 24) {
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("\(getLocalString(string: "hi")) \(name)")
                            .font(.Poppins(size: 14))
                        
                        Text("Saryan street, 21 >")
                            .font(.Poppins(size: 14))
                    }
                    
                    Spacer()
                    
                    CallButton(phone: phone)
                    CircleIcon(imageName: "ic-notifications", badgeCount: 3)
                }
                
                if showsSearchBar {
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
