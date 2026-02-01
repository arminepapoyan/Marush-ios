//
//  RegisterView.swift
//  Marush
//
//  Created by s2s s2s on 31.01.2026.
//

import SwiftUI
import PhoneNumberKit

struct RegisterView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject private var dateSettings = DateSettings.shared
    @EnvironmentObject var settings:UserSettings
    @EnvironmentObject var vm : ViewModel
    
    // Form State Variables
    @State private var name = ""
    @State private var lastname = ""
    @State private var email = ""
    @State private var phoneNumber = ""
//    Not used
    @State private var birthdate = ""
    @State private var selectedGender = "male"
//    Not used
    @State private var verificationMethod = "email"
    @State var password : String = ""
    @State var repeatpassword : String = ""
    @State var countryCode: String = "+374"
    
    @State var wrongname: Bool = false
    @State var wronglastname: Bool = false
    @State var wrongemail: Bool = false
    @State var wrongphone: Bool = false
    @State var wrongBirthdate: Bool = false
    @State var wrongpassword = false
    @State var wrongrepeatpassword = false
    @State var wrongCode = false
    
    @State var wrongnameMessage: String = ""
    @State var wronglastnameMessage: String = ""
    @State var wrongemailMessage: String = ""
    @State var wrongphoneMessage: String = ""
    @State var wrongBirthdateMessage: String = ""
    @State var wrongpasswordMessage: String = ""
    @State var wrongrepeatpasswordMessage: String = ""
    
    @State private var phone_user = ""
    
    @State var showPass = false
    @State var showPassw = false

    
    // Error and Validation States
    @State private var showText = false
    @State private var errorPassword = false
    @State private var errorPasswordMessage = ""
    @State private var showAlert = false
    
    // Gender and Verification Method Options
    let genders = ["male", "female"]
    let verificationMethods = ["email", "phone"]
    
    // Date Picker State Variables
    @State private var dateEdit = false
    @State private var date = Date()
    @State private var dateMin = Date()
    
    let phoneNumberKit = PhoneNumberUtility()
    @State private var phoneField: PhoneNumberTextFieldView?
    
    // Date Formatter
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.locale = Locale(identifier: "hy")
        return formatter
    }()
    
    @State var showloading = false
    @State private var signup_loading: Bool = false
    @State private var next_loading: Bool = false
    @State private var actionBtnLoading: Bool = false
    
    @State var errorMess = ""
    
    @State var showCode: Bool = false
    @State var code : String = ""
    @State var wrongcode  = 0
    
    let horizontalPadding = GlobalSettings.shared.horizontalPadding
    
    var body: some View {
        NavigationStack {
            ZStack{
                VStack{
                    if showCode{
                        codeView
                    } else{
                        registrationView
                    }
                }
                .padding(.horizontal, horizontalPadding)
                .sheet(isPresented: $dateEdit) {
                    datePickerSheet
                        .presentationDetents([.height(500)])
                }
                .overlay(showAlert ?
                         CustomDialog(isActive: $showAlert, icone_type: 0, title: getLocalString(string:"wrond_command"), message: errorMess, buttonTitle: "",padd: 50) {
                    print("Pass to viewModel")
                }
                         : nil
                )
            }
            .onTapGesture {
                hideKeyboard()
            }
        }
        .navigationBarHidden(true)
    }
    
    private var registrationView: some View{
        VStack(spacing: 12) {
            ScrollView(showsIndicators: false) {
                headerSection
                registrationForm
            }
            actionBtn
                .padding(.top, 10)
            signInSection
//            Spacer()
        }
        .padding(.vertical)
    }
    
    private var codeView: some View {
        VStack{
            VStack(alignment: .leading){
                Button(action: {
                    showCode = false
                }) {
                    Image("ic-chevron-left-dark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 14, height: 14)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 16)
                
                ScrollView(showsIndicators: false) {
                    verifyCodeHeaderSection
//                    inputField(placeholder: getLocalString(string: "confirm_code"), text: $code, showErrorImg: $wrongCode, errorMess: .constant(""), isSecure: false, showLabel: false)
                    VerificationCodeView(code: $code, hasError: $wrongCode)
                        .padding(.top, 20)

                    resendCodeSection
                }
            }
            Spacer()
            // register Button
            actionBtn
            signInSection
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical)
    }
    
    private var resendCodeSection: some View {
        HStack{
            HStack{
                Text("resend_code")
                    .font(.PoppinsMedium(size: 16))
                    .foregroundColor(.black)
            }
            Spacer()
            
            HStack{
                if vm.showingAlert {
                    VStack(alignment: .trailing){
                        Button(action: {
                            vm.showingAlert.toggle()
                            vm.start(minutes: Float(vm.minutes))
                            sendRegisterCode(data: Registration(name: name, lastname: lastname, email: email, phone: phone_user, code_type: verificationMethod, code: "", password: password, repeat_password: repeatpassword)){ response in
                                print("sendRegisterCode response is \(response)")
//                                if(response?.status == 200){
//                                    showCode = true
//                                } else {
//                                    if (response?.message != nil){
//                                        errorMess = response?.message ?? ""
//                                    } else{
//                                        errorMess = getLocalString(string: "wrond_command")
//                                    }
//                                    showAlert = true
//                                }
                            }
                        }, label: {
//                            Text("send_again")
//                                .font(.montserratBold(size: 16))
//                                .foregroundColor(.black)
                            Image(systemName: "arrow.circlepath")
                                .resizable()
                                .frame(width: 16, height: 16)
                                .foregroundColor(Color(UIColor(named: "ColorDark")!))
                        })
                    }
                } else {
                    Text("\(vm.time)")
                        .font(.system(size: 16))
                        .foregroundColor(Color(UIColor(named: "ColorDark")!))
                }
            }
        }
        .padding(.vertical,10)
        .padding(.bottom,20)
        .padding(.horizontal,5)
        
        .onAppear(){
            vm.start(minutes: Float(vm.minutes))
        }
    }
    
    // MARK: - UI Components
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("lets_get_started")
                .font(.PoppinsBold(size: 26))
                .foregroundColor(Color(UIColor(named: "ColorDark")!))
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("fill_out_your_details")
                .font(.PoppinsBold(size: 26))
                .foregroundColor(Color(UIColor(named: "ColorDark")!))
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("will_verify_text")
                .font(.PoppinsMedium(size: 14))
                .foregroundColor(Color(UIColor(named: "ColorDark")!))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private var verifyCodeHeaderSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("enter_the_code")
                .font(.PoppinsBold(size: 26))
                .foregroundColor(Color(UIColor(named: "ColorDark")!))
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(String(format: NSLocalizedString("verification_sent_code_txt", comment: ""), "\(verificationMethod == "email" ? email : phoneNumber)"))
                .font(.PoppinsMedium(size: 14))
        }
    }
    // Title Text
    private var titleText: some View {
        Text("Registration")
            .font(.PoppinsBold(size: 16))
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .center)
    }
    
    // Registration Form
    private var registrationForm: some View {
        VStack(alignment: .leading, spacing: 12) {
            inputField(placeholder: getLocalString(string: "name"), text: $name, showErrorImg: $wrongname, errorMess: $wrongnameMessage, isSecure: false, showLabel: true)
            inputField(placeholder: getLocalString(string: "lastname"), text: $lastname, showErrorImg: $wronglastname,  errorMess: $wronglastnameMessage, isSecure: false, showLabel: true)
            emailInput
            phoneInput
//            birthdayInputHelper
            inputField(placeholder: getLocalString(string: "password"), text: $password, showErrorImg: $wrongpassword, errorMess: $wrongpasswordMessage, isSecure: true, showLabel: true)
            inputField(placeholder: getLocalString(string: "repeat_password"), text: $repeatpassword, showErrorImg: $wrongrepeatpassword, errorMess: $wrongrepeatpasswordMessage, isSecure: true, showLabel: true)
//            genderSelection
            verificationMethodSelection
        }
    }
    
    // Input Field Helper
//    private func inputField(placeholder: String, text: Binding<String>, showErrorImg: Binding<Bool>, isSecure: Bool) -> some View {
//        InputView(
//            placeholder: placeholder,
//            text: text,
//            canHide: isSecure,
//            isError: showErrorImg.wrappedValue,
//            isSecure: isSecure,
//            showError: false,
//            errorMessage: ""
//        )
//
//    }
    
    // Email Input
    private var emailInput: some View {
        InputView(
            placeholder: getLocalString(string: "email"),
            text: $email,
            canHide: false,
            isError: wrongemail,
            isSecure: false,
            showError: false,
            errorMessage: $wrongemailMessage,
            showLabel: true
        )
    }
    
    // Phone Input
    private var phoneInput: some View {
        VStack(alignment: .leading, spacing: 4){
            inputLabel(label: getLocalString(string: "phone_number"))
            PhoneInputView(presentSheet: false, countryCode: $countryCode, mobPhoneNumber: $phoneNumber, countryFlag: "🇦🇲", countryPattern: "## ######", countryLimit: 300)
                .frame(height: 50)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color(UIColor(named: "CustomGray")!), lineWidth: 1)
                )
                .padding(2)
                .overlay(alignment: .trailing){
                    wrongphone ?
                    VStack(alignment: .trailing) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.system(size: 20))
                            .padding(.trailing, 8)
                    }
                    : nil
                }
                .cornerRadius(15)
            
            if wrongphone{
                Text(wrongphone ? wrongphoneMessage : "")
                    .font(.system(size: 15))
                    .foregroundColor(Color(UIColor(named: "CustomRed")!))
                    .multilineTextAlignment(.leading)
                    .padding(.leading, 15)
            }
        }
    }
    
    // Birthday Input
//    private var birthdayInputHelper: some View {
//        HStack {
//            ZStack(alignment: .leading) {
//                Text("Birthdate")
//                    .font(.PoppinsMedium(size: birthdate.isEmpty ? 16: 13))
//                    .foregroundColor(.black.opacity(0.5))
//                    .padding(.horizontal, 10)
//                    .offset(y: birthdate.isEmpty ? 0 : -15)
//                    .scaleEffect(birthdate.isEmpty ? 1 : 0.9, anchor: .leading)
//                
//                TextField("", text: $birthdate)
//                    .font(.system(size: 18, design: .rounded))
//                    .foregroundColor(.black)
//                    .padding(.horizontal, 10)
//                    .disabled(true)  // Make the TextField read-only
//                    .offset(y: birthdate.isEmpty ? 0 : 8)
//            }
//            
//            if wrongBirthdate{
//                Image(systemName: "exclamationmark.circle.fill")
//                    .font(.system(size: 20))
//                    .foregroundColor(.black)
//                    .padding(.trailing, 8)
//            }
//        }
//        .padding(.vertical, 20)
//        .overlay(
//            RoundedRectangle(cornerRadius: 15)
//                .stroke(Color(UIColor(named: "CustomGray")!), lineWidth: 1)
//        )
//        .overlay(alignment: .trailing){
//            wrongBirthdate ?
//                VStack(alignment: .trailing) {
//                    Image(systemName: "exclamationmark.circle.fill")
//                        .font(.system(size: 20))
//                        .padding(.trailing, 8)
//                }
//            : nil
//        }
//        .cornerRadius(15)
//        .onTapGesture {
//            dateEdit = true  // Show the date picker when tapped
//        }
//    }
//    
//    // Gender Selection
//    private var genderSelection: some View {
//        selectionView(title: getLocalString(string: "gender"), items: genders, selectedItem: $selectedGender)
//    }
    
    // Verification Method Selection
    private var verificationMethodSelection: some View {
        selectionView(title: getLocalString(string: "send_verification_code_by"), items: verificationMethods, selectedItem: $verificationMethod)
            .padding(.top, 15)
    }
    
//    // Next Button
//    private var nextButton: some View {
//        ButtonView(showLoading: $next_loading, isDisabled: .constant(false), title: getLocalString(string: "continue")) {
//            handleSignUp()
////            showAlert = true
//        }
//    }
    
    // Action Button
    private var actionBtn: some View {
        ButtonView(showLoading: $actionBtnLoading, isDisabled: .constant(false), title: getLocalString(string: showCode ? "registration" : "continue")) {
            if showCode {
                handleNextCode()
            } else{
                handleSignUp()
            }
        }
    }
    
    // Sign In Section
    private var signInSection: some View {
        HStack{
            Text("Already have an account?")
                .font(.PoppinsMedium(size: 16))
                .foregroundColor(Color(UIColor(named: "ColorDark")!).opacity(0.8))
            NavigationLink(destination: LoginView()) {
                Text("sign_in")
                    .font(.PoppinsBold(size: 16))
                    .foregroundColor(Color(UIColor(named: "ColorDark")!).opacity(0.8))
            }
        }
    }
    
    private var datePickerSheet: some View{
        VStack {
           VStack(spacing: 0) {
               HStack {
                   Text("\(date, formatter: dateFormatter)")
                       .font(.system(size: 18))
                       .foregroundColor(.white)
                       .padding(.vertical, 15)
                       .frame(maxWidth: .infinity)
                       .background(Color.black)
               }
               
               DatePicker(
                   "",
                   selection: $date,
                   in: dateSettings.minDate...dateSettings.maxDate,
                   displayedComponents: [.date]
               )
               .datePickerStyle(.graphical)
               .labelsHidden()
               .accentColor(.black)
               .environment(\.locale, Locale(identifier: settings.appLang))
               .onAppear {
                   if date > dateSettings.maxDate {
                       date = dateSettings.maxDate
                   }
               }
               
               HStack {
                   Button("Cancel") { dateEdit = false }
                       .font(.system(size: 16))
                       .foregroundColor(.black)
                       .padding(.horizontal, 10)
                   
                   Button("Save") {
                       let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
                       let year = components.year ?? 0
                       let month = components.month ?? 0
                       let day = components.day ?? 0
                       birthdate = String(format: "%02d/%02d/%d", day, month, year)
                       dateEdit = false
                   }
                   .font(.system(size: 16))
                   .foregroundColor(.black)
               }
           }
           .padding(20)
           .background(Color.white)
           .cornerRadius(20)
           .frame(maxHeight: UIDevice.current.localizedModel == "iPad" ? 600 : 450)
       }
    }
    
    private func handleSignUp() {
        actionBtnLoading = true
        var error = 0
        var phone_error = 0
        if name.isEmpty {
            wrongnameMessage = getLocalString(string: "name_cant_be_empty")
            wrongname = true
            error = 1
        } else {
            wrongname = false
        }
        
        if lastname.isEmpty {
            wronglastnameMessage = getLocalString(string: "lastname_cant_be_empty")
            wronglastname = true
            error = 1
        } else {
            wronglastname = false
        }
        
        if email.isEmpty {
            wrongemailMessage = getLocalString(string: "email_field_is_required")
            wrongemail = true
            error = 1
        } else {
            wrongemail = false
        }
        
        if phoneNumber.isEmpty {
            wrongphoneMessage = getLocalString(string: "phone_field_is_required")
            wrongphone = true
            error = 1
        } else {
            wrongphone = false
        }
        
        if password.isEmpty{
            wrongpasswordMessage = getLocalString(string: "password_is_not_correct")
            wrongpassword = true
            error = 1
        } else{
            wrongpassword = false
        }

        if password != repeatpassword{
            wrongrepeatpasswordMessage = getLocalString(string: "password_not_match")
            wrongrepeatpassword = true
            error = 1
        } else{
            wrongrepeatpassword = false
        }
        
        phoneNumber =  phoneNumber.trimmingAllSpaces()
        
        phone_user = "\(countryCode)\(phoneNumber)".trimmingAllSpaces()
        
        self.phoneField = PhoneNumberTextFieldView(phoneNumber: .constant(phone_user))
        do {
            self.phoneField?.getCurrentText()
            let validatedPhoneNumber = try phoneNumberKit.parse(phone_user)
            
            // Integrate with your login/registration system here...
        }
        catch {
            phone_error = 1
            wrongphone = true
            wrongphoneMessage = getLocalString(string: "phone_number_is_wrong")
        }
        
        if (error == 1 || phone_error == 1){
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                actionBtnLoading = false
            }
            return // Early exit if there are validation errors
        }
        
        
        // Continue with registration logic...
        
        //        if error == 1 || error1 == 1 {
        //            showloading = false
        //            return
        //        }
                
        sendRegisterCode(data: Registration(name: name, lastname: lastname, email: email, phone: phone_user, code_type: verificationMethod, code: "", password: password, repeat_password: repeatpassword)){ response in
            actionBtnLoading = false
            
            if(response?.status == 200){
                showCode = true
                vm.start(minutes: Float(vm.minutes))
            } else {
                if (response?.errors?.password != nil){
                    wrongpassword = true
                    wrongpasswordMessage = response?.errors?.password ?? ""
                }
                if response?.errors?.email != nil {
                    wrongemail = true
                    wrongemailMessage = response?.errors?.email ?? ""
                }
                if response?.errors?.name != nil {
                    wrongname = true
                    wrongnameMessage = response?.errors?.name ?? ""
                }
                if response?.errors?.lastname != nil {
                    wronglastname = true
                    wronglastnameMessage = response?.errors?.lastname ?? ""
                }
                if response?.errors?.phone != nil {
                    wrongphone = true
                    wrongphoneMessage = response?.errors?.phone ?? ""
                }
                if response?.errors?.repeatpassword != nil {
                    wrongrepeatpassword = true
                    wrongrepeatpasswordMessage = response?.errors?.repeatpassword ?? ""
                }
                if response?.errors?.date_of_birth != nil {
                    wrongBirthdate = true
                }
                if response?.message != nil && response?.message != ""{
                    showAlert = true
                    errorMess = response?.message ?? ""
                }
            }
        }
    }
    
    private func handleNextCode(){
        actionBtnLoading = true
        var error = 0
        if code.count != 6 || !code.allSatisfy({ $0.isNumber }) {
            wrongcode = 2
            error = 1
        } else {
            wrongcode = 0
        }
        if error == 1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                actionBtnLoading = false
            }
            showloading = false
            return
        }
        
        sendRegisterCode(data: Registration(name: name, lastname: lastname, email: email, phone: phone_user, code_type: verificationMethod, code: code, password: password, repeat_password: repeatpassword)){ response in
            actionBtnLoading = false
            if(response?.status == 200){
                print("sendRegisterCode final response is success \(response)")
//                if let token = response?.token, !token.isEmpty {
//                    settings.account_uid = token
//                    settings.isLogined = true
//                    presentationMode.wrappedValue.dismiss()
//                    settings.resetNavigationID = UUID()
//                } else {
//                    errorMess = "Unknown error occurred"
//                    showAlert = true
//                }
            } else {
                errorMess = response?.message ?? "Unknown error occurred"
                if (response?.errors?.code != nil){
                    errorMess = response?.errors?.code ?? ""
                } else{
                    errorMess = getLocalString(string: "wrond_command")
                }
                showAlert = true
            }
        }
    }
}
