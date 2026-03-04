//
//  ContentView.swift
//  Marush
//
//  Created by s2s s2s on 30.01.2026.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appData: AppDataViewModel
    @EnvironmentObject var settings: UserSettings
    @EnvironmentObject var vm: ViewModel
    
    @Namespace private var logoNamespace
    @State private var showSplash: Bool = true

    var body: some View {
        NavigationStack {
            ZStack {
//                if showSplash {
//                    SplashScreenView(
//                        namespace: logoNamespace,
//                        onFinish: {
//                            withAnimation(.easeInOut(duration: 0.8)) {
//                                showSplash = false
//                            }
//                        }
//                    )
//                } else {
                    //                if settings.isLogined && appData.status != 501 {
                    if settings.isLogined {
                        MainView()
                            .environmentObject(settings)
                            .environmentObject(vm)
                    } else {
                        AuthorizationView(namespace: logoNamespace)
                    }
//                }
            }
            .onAppear {
                //            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                //                withAnimation {
                //                    self.showSplash = false
                //                }
                //            }
            }
        }
    }
}

