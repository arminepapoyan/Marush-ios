//
//  SettingsView.swift
//  Marush
//
//  Created by s2s s2s on 07.04.2026.
//


import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var userData: UserViewModel
    @EnvironmentObject var settings: UserSettings
    
    @State private var title: String = getLocalString(string: "configs")
    @State private var emailNotifications: Int = 0
    @State private var pushNotifications: Int = 0
    @State private var showDeleteAlert = false
    
    @State private var showAlert: Bool = false
    @State private var errorMess: String = ""
    
    @State private var isInitialSetupDone: Bool = false
    
//    private let languages: Lang = Lang(rawValue: "hy")
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView(title: title, showArrow: true)
                .padding(.horizontal)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    notificationSettingsSection
                    languageSettingsSection
                    deleteAccountButton
                }
                .padding(.horizontal, 2)
                bottomShadowIgnore(count: 5)
            }
            .padding(.horizontal)
            .padding(.top, 40)
          
        }
        .environment(\.locale, .init(identifier: settings.appLang))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor(named: "F9F9F9")!))
        .navigationBarHidden(true)
        .onAppear(){
            if(userData != nil){
                pushNotifications = (userData.push_notifications == "0") ? 0 : 1
                emailNotifications = (userData.email_notifications == "0") ? 0 : 1
                DispatchQueue.main.async {
                    isInitialSetupDone = true
                }
            }
        }
        .overlay(showAlert ? errorDialog : nil)
        .navigationBarHidden(true)
        .overlay(
            Group {
                if showDeleteAlert {
                    CustomConfirmationDialog(
                        isPresented: $showDeleteAlert,
                        title: getLocalString(string: "delete_account"),
                        text: getLocalString(string: "do_you_want_to_permanently_remove_your_account"),
                        confirmButton: getLocalString(string: "yes_remove"),
                        cancelButton: getLocalString(string: "cancel"),
                        onConfirm: {
                            handleRemoveAccount();
                        })
                    .transition(.scale)  // Smooth transition animation
                    .animation(.easeInOut, value: showDeleteAlert)
                }
            }
        )
        .onChange(of: emailNotifications) { newValue in
            if isInitialSetupDone{
                handleChangeNotifications()
            }
        }
        .onChange(of: pushNotifications) { newValue in
            if isInitialSetupDone {
                handleChangeNotifications()
            }
        }
    }
    
    private var errorDialog: some View {
        CustomDialog(isActive: $showAlert, icone_type: 0, title: getLocalString(string: "wrond_command"), message: errorMess, buttonTitle: "", padd: 50) {
        }
    }
    
    private func handleRemoveAccount() {
        RemoveAccount() { response in
            if let status = response?.status {
                switch status {
                case 200:
                    withAnimation{
                        settings.isLogined = false
                        settings.isFirebaseTokenSent = false
                        settings.account_uid = ""
                    }
                default:
                    errorMess = getLocalString(string: "wrond_command")
                    showAlert = true
                }
            } else {
                errorMess = getLocalString(string: "wrond_command")
                showAlert = true
            }
        }
        
   }
    
    private func handleChangeNotifications() {
        let requestData = Settings(emailNotification: emailNotifications, pushNotification: pushNotifications, lang: settings.appLang)
        ChangeNotifications(data: requestData) { response in
            if let status = response?.status {
                switch status {
                case 200:
                    userData.email_notifications = (emailNotifications == 1) ? "1" : "0"
                    userData.push_notifications = (pushNotifications == 1) ? "1" : "0"
                default:
                    errorMess = getLocalString(string: "wrond_command")
                    showAlert = true
                }
            } else {
                errorMess = getLocalString(string: "wrond_command")
                showAlert = true
            }
        }
        
   }
}

// MARK: - Subviews
private extension SettingsView {
    /// Notification Settings Section
    var notificationSettingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("notification_settings")
                .font(.LatoBold(size: 16))
            
            notificationToggle(
                isOn: Binding(
                    get: { emailNotifications == 1 },
                    set: { emailNotifications = $0 ? 1 : 0 }
                ),
                text: getLocalString(string: "email_notifications")
            )
            
            notificationToggle(
                isOn: Binding(
                    get: { pushNotifications == 1 },
                    set: { pushNotifications = $0 ? 1 : 0 }
                ),
                text: getLocalString(string: "push_notifications")
            )
        }
    }
    
    /// Language Settings Section
    var languageSettingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Language Header
            HStack {
                Image(systemName: "globe")
                Text("language")
                    .font(.LatoBold(size: 16))
            }
            
            // Language Selection
            ForEach (Lang.allCases, id: \.self) {
                languageBtn(language: $0)
            }
        }
    }
    
    /// Delete Account Button
    var deleteAccountButton: some View {
        Button(action: {
            showDeleteAlert = true
        }) {
            HStack{
                Image(systemName: "trash")
                    .foregroundColor(Color(UIColor(named: "ColorPrimary")!))
                Text("delete_account")
                    .font(.Lato(size: 16))
                    .foregroundColor(Color(UIColor(named: "ColorPrimary")!))
                Spacer()
            }
            .frame(maxWidth: .infinity,maxHeight: .infinity, alignment: .center)
        }
        .padding(10)
        .frame(height: 50)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(UIColor(named: "ColorDark")!).opacity(0.04), lineWidth: 1)
        )
    }
}

// MARK: - Helper Views
private extension SettingsView {
    /// Notification Toggle
    func notificationToggle(isOn: Binding<Bool>, text: String) -> some View {
        HStack {
            Toggle(isOn: isOn) {
                Text(text)
                    .font(.Lato(size: 14))
                    .foregroundColor(.black)
            }
            .toggleStyle(SwitchToggleStyle(tint: Color.green))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(UIColor(named: "ColorDark")!).opacity(0.04), lineWidth: 1)
        )
    }
    
    /// Language Row
    func languageBtn(language: Lang) -> some View {
        Button (action :{
            settings.appLang = language.identifier
        }, label: {
            HStack {
                Text(language.lang_name)
                    .font(.Lato(size: 14))
                    .foregroundColor(.primary)
                Spacer()
                if(settings.appLang == language.identifier){
                    Image(systemName: "checkmark")
                        .foregroundColor(Color(UIColor(named: "ColorDark")!))
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(
                        Color(UIColor(named: "ColorDark")!).opacity((settings.appLang == language.identifier) ? 0.7 : 0.04),
                        lineWidth: 1
                    )
            )
        })
    }
}
