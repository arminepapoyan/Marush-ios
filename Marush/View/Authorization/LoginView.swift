//
//  LoginView.swift
//  Marush
//
//  Created by s2s s2s on 31.01.2026.
//

import SwiftUI

struct LoginView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var appData: AppDataViewModel
    @EnvironmentObject var settings: UserSettings

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showText: Bool = false
    @State private var wrongEmail: Int = 0
    @State private var wrongPassword: Int = 0
    @State private var showAlert: Bool = false
    @State private var errorMess: String = ""
    @State private var showLoading: Bool = false

    @State private var errorEmail: Bool = false
    @State private var errorPassword: Bool = false
    @State private var errorEmailMessage: String = ""
    @State private var errorPasswordMessage: String = ""
    
    @State private var signin_loading: Bool = false
    @State private var showLoginView: Bool = false
    
    let horizontalPadding = GlobalSettings.shared.horizontalPadding
    
    var body: some View {
         NavigationStack {
             ZStack{
                 GeometryReader { geometry in
                     ZStack{
                         if settings.isLogined {
                             MainView()
                                 .environmentObject(settings)
                         } else{
                             loginView
                         }
//                         ScrollView(showIndicators: false) {
                             
//                         }
//                         .scrollDismissesKeyboard(.interactively)
//                         .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 0) }
                     }
                 }
             }
             .padding(.vertical, 22)
             .padding(.horizontal, horizontalPadding)
         }
         .navigationBarHidden(true)
     }
    
    private var loginView: some View {
        VStack {
            VStack(spacing: 24){
                headerSection
                VStack(spacing: 12){
                    emailInput
                    passwordInput
                    forgotPasswordButton
                }
            }
            Spacer()
            signInButton
            registerButton
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .onTapGesture {
            hideKeyboard()
        }
        .overlay(showAlert ? errorDialog : nil)
        .environment(\.locale, .init(identifier: settings.appLang))
        
    }
    
    // MARK: - UI Components
    private var headerSection: some View {
        VStack(alignment: .leading) {
            Text("sign_in")
                .font(.PoppinsBold(size: 26))
                .foregroundColor(Color(UIColor(named: "ColorDark")!))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
//    Not used
    private var emailInput: some View {
        InputView(
            placeholder: getLocalString(string: "email_or_phone_number"),
            text: $email,
            canHide: false,
            isError: wrongEmail == 2,
            isSecure: false,
            showError: errorEmail,
            errorMessage: $errorEmailMessage,
            showLabel: true
        )
        .padding(.bottom, 5)
    }
    
    private var passwordInput: some View {
        InputView(
            placeholder: getLocalString(string: "password"),
            text: $password,
            canHide: true,
            isError: wrongPassword == 2,
            isSecure: !showText,
            showError: errorPassword,
            errorMessage: $errorPasswordMessage,
            showLabel: true
        )
    }
    
    private var forgotPasswordButton: some View {
        HStack {
            Spacer()
            NavigationLink(destination: ForgetView()) {
                Text("forgot_password")
                .font(.PoppinsMedium(size: 16))
                    .foregroundColor(Color(UIColor(named: "ColorDark")!))
            }
        }
        .padding(.top, 8)
    }
    
    private var signInButton: some View {
        ButtonView(showLoading: $signin_loading, isDisabled: .constant(false), title: getLocalString(string: "sign_in")) {
            handleSignIn()
        }
    }
    
    private var registerButton: some View{
        HStack{
            Text("you_dont_have_account_yet_question")
                .font(.PoppinsMedium(size: 16))
                .foregroundColor(Color(UIColor(named: "ColorDark")!).opacity(0.8))
            NavigationLink(destination: RegisterView()) {
                Text("register")
                .font(.PoppinsBold(size: 16))
                .foregroundColor(Color(UIColor(named: "ColorDark")!).opacity(0.8))
            }
        }
    }
    
    // MARK: - Sign In Logic
    private func handleSignIn() {
        signin_loading = true
        
        var error_form = false
        if email.isEmpty {
            wrongEmail = 2
            error_form = true
        } else {
            wrongEmail = 0
        }
      
        if password.isEmpty {
            wrongPassword = 2
            error_form = true
        } else {
            wrongPassword = 0
        }
        
        if error_form {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                signin_loading = false
            }
            return
        }
        
        errorPassword = false
        errorEmail = false
        
        login(email: email, password: password) { response in
            signin_loading = false
            if response?.status == 200 {
                settings.account_uid = response?.token ?? ""
                settings.isLogined = true
//                isLoggedIn = true // Set logged in state to true
                presentationMode.wrappedValue.dismiss()
                settings.resetNavigationID = UUID()
            } else {
                if (response?.errors?.password != nil){
                    errorPassword = true
                    errorPasswordMessage = response?.errors?.password ?? ""
                }
                if response?.errors?.email != nil {
                    errorEmail = true
                    errorEmailMessage = response?.errors?.email ?? ""
                }
            }
        }
    }
    
    // MARK: - Alerts and Confirmations
    private var errorDialog: some View {
        CustomDialog(isActive: $showAlert, icone_type: 0, title: getLocalString(string: "mistake"), message: errorMess, buttonTitle: "", padd: 50) {
            print("Pass to viewModel")
        }
    }

}
