//
//  ForgetView.swift
//  Marush
//
//  Created by s2s s2s on 01.02.2026.
//

import SwiftUI
import PhoneNumberKit

struct ForgetView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var settings: UserSettings
    
    // Form State Variables
    @State private var code: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var repeatPassword: String = ""
    
    @State private var showAlert: Bool = false
    @State private var showSuccessMessage: Bool = false

    @State private var errorMess: String = ""
    @State private var step: Int = 0
    @State private var btnLoading: Bool = false
    @State private var navigateToAuthorization: Bool = false
    
    @State private var showData: Bool = true
    @State private var showCode: Bool = false
    @State private var showPassword: Bool = false
    @State private var wrongCode: Bool = false
    @State private var wrongEmail: Bool = false
    @State private var wrongPassword: Bool = false
    @State private var wrongRepeatPassword: Bool = false
    
    @State private var wrongCodeMessage: String = ""
    @State private var wrongEmailMessage: String = ""
    @State var wrongpasswordMessage: String = ""
    @State var wrongrepeatpasswordMessage: String = ""
    
    let horizontalPadding = GlobalSettings.shared.horizontalPadding
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    VStack(alignment: .leading){
                        Button(action: {
                            navigateToAuthorization = true
                        }) {
                            Image("ic-chevron-left-dark")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 14, height: 14)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 16)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    ScrollView {
                        titleText
                        if showData {
                            dataView
                                .padding(.top, 20)
                        } else if showCode {
                            codeView
                        } else if showPassword {
                            passwordView
                        }
                    }
                    Spacer()
                    // register Button
                    actionBtn
                    signInSection
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.vertical)
                .overlay(showAlert ? errorDialog : nil)
                .overlay(showSuccessMessage ? successDialog : nil)
                .onTapGesture { hideKeyboard() }
                
                NavigationLink(destination: LoginView(), isActive: $navigateToAuthorization) {
                    EmptyView() // Navigation link to AuthorizationView
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, horizontalPadding)
            .navigationBarHidden(true)
        }
    }
    
    // Action Button
    private var actionBtn: some View {
        ButtonView(showLoading: $btnLoading, isDisabled: .constant(false), title: getLocalString(string: showPassword ? "submit" : "continue")) {
            handleForgot()
        }
    }
    
    // Sign In Section
    private var signInSection: some View {
        HStack{
            Text("already_have_an_account")
                .font(.PoppinsMedium(size: 16))
                .foregroundColor(Color(UIColor(named: "ColorDark")!).opacity(0.8))
            NavigationLink(destination: LoginView()) {
                Text("sign_in")
                    .font(.PoppinsBold(size: 16))
                    .foregroundColor(Color(UIColor(named: "ColorDark")!).opacity(0.8))
            }
        }
    }
    
    // Data View
    private var dataView: some View {
        VStack {
            subtitleText
            emailInput
            Spacer()
        }
    }
    
    // Code View
    private var codeView: some View {
        VStack(alignment: .leading) {
            verifyCodeHeaderSection
//                    inputField(placeholder: getLocalString(string: "confirm_code"), text: $code, showErrorImg: $wrongCode, errorMess: .constant(""), isSecure: false, showLabel: false)
            VerificationCodeView(code: $code, hasError: $wrongCode)
                .padding(.top, 20)
        }
        .padding(.top, 30)
    }
    
    private var verifyCodeHeaderSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("enter_the_code")
                .font(.PoppinsBold(size: 26))
                .foregroundColor(Color(UIColor(named: "ColorDark")!))
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(String(format: NSLocalizedString("verification_sent_code_txt", comment: ""), "\(email)"))
                .font(.PoppinsMedium(size: 14))
        }
    }
    
    // Password View
    private var passwordView: some View {
        VStack(alignment: .leading, spacing: 10) {
            inputField(placeholder: getLocalString(string: "password"), text: $password, showErrorImg: $wrongPassword, errorMess: $wrongpasswordMessage, isSecure: true, showLabel: false)
            inputField(placeholder: getLocalString(string: "password_repeat"), text: $repeatPassword, showErrorImg: $wrongRepeatPassword,  errorMess: $wrongrepeatpasswordMessage, isSecure: true, showLabel: false)
//            ButtonView(showLoading: $btnLoading, isDisabled: .constant(false), title: getLocalString(string: "submit")) {
//                handleForgot()
//            }
        }
    }
    
    // Title Text
    private var titleText: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("forgot_your_password")
                .font(.PoppinsBold(size: 26))
                .foregroundColor(Color(UIColor(named: "ColorDark")!))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    // Subtitle Text
    private var subtitleText: some View {
        Text("enter_your_email")
            .font(.PoppinsMedium(size: 14))
            .foregroundColor(Color(UIColor(named: "ColorDark")!))
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // Email Input
    private var emailInput: some View {
        inputField(placeholder: getLocalString(string: "email"), text: $email, showErrorImg: $wrongEmail, errorMess: $wrongEmailMessage, isSecure: false, showLabel: false)
    }
    
    // Error Dialog Overlay
    private var errorDialog: some View {
        CustomDialog(isActive: $showAlert, icone_type: 0, title: getLocalString(string: "wrond_command"), message: errorMess, buttonTitle: "", padd: 50) {
            print("Pass to viewModel")
        }
    }
    private var successDialog: some View {
        CustomDialog(isActive: $showSuccessMessage, icone_type: 1, title: getLocalString(string: "success"), message: getLocalString(string: "your_password_has_been_reset_successfully"), buttonTitle: "", padd: 50, closeOutside: false) {
            withAnimation{
                navigateToAuthorization = true
            }
        }
    }
    
    private func handleForgot() {
        btnLoading = true
        
        if !validateInputs() {
            btnLoading = false
            return // Early exit if there are validation errors
        }
        
        let requestData = ForgotPassword(email: email, code: code, password: password, password_repeat: repeatPassword)
        
        forgetPassword(data: requestData) { response in
            btnLoading = false
            
            if let status = response?.status {
                switch status {
                case 201:
                    if code.isEmpty {
                        showData = false
                        showCode = true
                        showPassword = false
                        step = 1
                    } else {
                        showData = false
                        showCode = false
                        showPassword = true
                        step = 2
                    }
                case 200:
                    showSuccessMessage = true // Trigger the success message
                default:
                    errorMess = response?.message ?? getLocalString(string: "wrond_command")
                    showAlert = true
                }
            } else {
                errorMess = response?.message ?? getLocalString(string: "wrond_command")
                showAlert = true
            }
        }
    }
    
    private func validateInputs() -> Bool {
        var isValid = true
        wrongEmail = false
        wrongCode = false
        wrongPassword = false
        wrongRepeatPassword = false
        
        if email.isEmpty {
            wrongEmail = true
            isValid = false
        } else {
            wrongEmail = false
        }
        
        if step == 1 && (code.count != 6 || !code.allSatisfy({ $0.isNumber })) {
            wrongCode = true
            isValid = false
        } else {
            wrongCode = false
        }
        
        if step == 2 {
            if password.isEmpty {
                wrongPassword = true
                isValid = false
            } else {
                wrongPassword = false
            }
            
            if password != repeatPassword {
                wrongRepeatPassword = true
                isValid = false
            } else {
                wrongRepeatPassword = false
            }
        }
        
        return isValid
    }
}
