//
//  AuthorizationView.swift
//  Marush
//
//  Created by s2s s2s on 30.01.2026.
//

import SwiftUI

struct AuthorizationView: View {
    
    let namespace: Namespace.ID
    @EnvironmentObject var globalSettings: GlobalSettings
    @EnvironmentObject var appData: AppDataViewModel
    @EnvironmentObject var settings: UserSettings
    
    let horizontalPadding = GlobalSettings.shared.horizontalPadding
    
    @State private var goToLogin = false
    @State private var goToRegister = false
    
    var body: some View {
        
        //            && appData.status != 501
        if settings.isLogined{
            VStack{
                Text("Here will be main View")
            }
        } else{
            ZStack {
                Color(UIColor(named: "CEF0F7")!)
                    .ignoresSafeArea()
                
                VStack(spacing: 150) {
                    // Logo top
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 280)
                        .matchedGeometryEffect(id: "logo", in: namespace)
                        .padding(.top, 60)
                    
                    VStack(spacing: 16) {
                        // Login button
                        ButtonView(title: getLocalString(string: "login"), style: .outline) {
                            goToLogin = true
                        }
                        // Register button
                        ButtonView(title: getLocalString(string: "register")) {
                            goToRegister = true
                        }
                    }
                }
                .padding(.horizontal, horizontalPadding)
            }
            .navigationDestination(isPresented: $goToLogin) {
                LoginView()
            }
            .navigationDestination(isPresented: $goToRegister) {
                RegisterView()
            }
        }
    }
}
