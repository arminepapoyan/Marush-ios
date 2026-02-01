
//
//  MainView.swift
//  Marush
//
//  Created by s2s s2s on 01.02.2026.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var settings: UserSettings
    @EnvironmentObject var vm: ViewModel
    @StateObject var userData = UserViewModel()
    @StateObject var appData = AppDataViewModel()
//    @StateObject private var globalSettings = GlobalSettings()
    
    
    @StateObject private var internetManager = InternetManager()
    @State private var showInternetAlert = false
    
    @Namespace private var logoNamespace
    
    var body: some View {
        HStack {
            ZStack(alignment: .top) {
                GeometryReader { reader in
                    Color.white
                        .frame(height: reader.safeAreaInsets.top, alignment: .top)
                        .ignoresSafeArea(.all, edges: .top)
                }
//                && appData.status != 501
                if settings.isLogined  {
                    TabContent()
                        .environmentObject(settings)
                        .environmentObject(userData)
                        .environmentObject(appData)
                } else{
                    AuthorizationView(namespace: logoNamespace)
                        .environmentObject(settings)
                        .environmentObject(vm)
//                        .onAppear{
//                            if appData.status == 501 {
//                                handleLogout(settings: settings)
//                            }
//                        }
                }
            }
            
            .onChange(of: internetManager.isConnected) { isConnected in
                if isConnected {
                    // Internet restored — hide alert and refresh app data
                    showInternetAlert = false
                    
//                    appData.getData { data in
//                        guard let data = data else {
//                            print("Failed to fetch app data.")
//                            return
//                        }
//                        if data.status == 501 {
//                            handleLogout(settings: settings)
//                        } else {
//                            appData.updateData(data)
//                            DispatchQueue.main.async {
//                                settings.cart_count = data.cart?.count ?? 0
//                                UserSettings.shared.cart_count = data.cart?.count ?? 0
//                            }
//                        }
//                    }
                    
                    userData.getUser { data in
                        if let data = data {
                            userData.updateUserData(data)
                        } else {
                            print("Failed to fetch user data.")
                        }
                    }
                } else {
                    // Internet lost — show no connection alert
                    showInternetAlert = true
                }
            }
            .sheet(isPresented: $showInternetAlert) {
                NoConnectionView(interactiveDismissDisabled: .constant(true))
            }
            .ignoresSafeArea(.all, edges: .bottom)
        }
    }
}

