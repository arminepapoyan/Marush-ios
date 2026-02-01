//
//  MarushApp.swift
//  Marush
//
//  Created by s2s s2s on 30.01.2026.
//

import SwiftUI

var notification_count = 0
var notification_uuid = UUID()
@main
struct MarushApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var notificationManager = NotificationManager.shared
    
    @StateObject private var userSettings = UserSettings()
    @StateObject private var vm = ViewModel()
    
    @State private var showUpdateAlert: Bool = false // State for showing the update alert
    @State private var releaseNotes: String = "" // State to store release notes
    @State private var appStoreURL: String = "" // State to store App Store URL
    @State private var update_message_disable: Bool = true
  
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userSettings)
                .environmentObject(vm)
                .onAppear {
                    // Force the app to use light mode
                    UIApplication.shared.windows.forEach { window in
                        window.overrideUserInterfaceStyle = .light
                    }
                    
//                    checkForUpdate() // Call the update check when the view appears
                }
                .sheet(isPresented: $showUpdateAlert) {
                    UpdateView(appStoreURL: $appStoreURL, releaseNotes: $releaseNotes, interactiveDismissDisabled: $update_message_disable)
                        .environment(\.locale, Locale(identifier: getLang())) // Pass locale here
                }
        }
    }
    
    
    private func checkForUpdate() {
        guard let url = URL(string: "https://itunes.apple.com/lookup?bundleId=com.kaloyan.gotcha") else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let results = json["results"] as? [[String: Any]],
                   let appStoreVersion = results.first?["version"] as? String {
                    
                    if var currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
                        print("Installed version: \(currentVersion)")
                        print("App Store version: \(appStoreVersion)")
                        
                        let currentParts = currentVersion.split(separator: ".").compactMap { Int($0) }
                        let appStoreParts = appStoreVersion.split(separator: ".").compactMap { Int($0) }
                        
                        guard currentParts.count == 3, appStoreParts.count == 3 else { return }
                        
                        let (currentMajor, currentMinor, currentPatch) = (currentParts[0], currentParts[1], currentParts[2])
                        let (storeMajor, storeMinor, storePatch) = (appStoreParts[0], appStoreParts[1], appStoreParts[2])
                        
                        DispatchQueue.main.async {
                            // Compare versions
                            if currentVersion < appStoreVersion {
                                DispatchQueue.main.async {
                                    self.releaseNotes = getLocalString(string: "release_notes")
                                    self.showUpdateAlert = true
                                    self.appStoreURL = results.first?["trackViewUrl"] as? String ?? ""
                                }
                            }
                            if currentMajor < storeMajor || currentMinor < storeMinor {
                                // Force update
                                update_message_disable = true
                            } else if currentPatch < storePatch {
                                update_message_disable = false
                            }
                        }
                        
                     
                    }
                }
            } catch {
                print("Error parsing JSON: \(error)")
            }
        }
        task.resume()
    }
}

struct UpdateView: View {
    @Binding var appStoreURL: String
    @Binding var releaseNotes: String
    @Binding var interactiveDismissDisabled: Bool // Bind the interactive dismiss state

    var body: some View {
        VStack(spacing: 20) {
            Text("update_available")
                .font(.system(size: 20))
            
            Text(releaseNotes)
            ButtonView(showLoading: .constant(false), isDisabled: .constant(false), title: getLocalString(string: "update")) {
                if let url = URL(string: appStoreURL) {
                    UIApplication.shared.open(url)
                }
            }
        }
        .padding()
        .presentationDetents([.height(300)]) // Optional, can control sheet size
        .interactiveDismissDisabled(interactiveDismissDisabled) // Use the binding here
    }
}
