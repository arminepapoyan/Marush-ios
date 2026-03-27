//
//  PersonalDataView.swift
//  Marush
//
//  Created by s2s s2s on 21.03.2026.
//

import SwiftUI
import PhoneNumberKit

struct PersonalDataView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var userData: UserViewModel
    @EnvironmentObject var settings: UserSettings
    
    @StateObject private var dateSettings = DateSettings.shared
//    @StateObject private var userData = UserViewModel()
    
    @State private var old_password: String = ""
    @State private var password: String = ""
    @State private var repeatPassword: String = ""
    
    @State private var name: String = ""
    @State private var lastname: String = ""
    @State private var birthday: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var selectedGender = "male"
    @State var countryCode: String = "+374"
    @State var saveDataLoading: Bool = false
    @State var passwordBtnLoading: Bool = false
    
    let genders = ["male", "female"]
    
    @State var wrongname: Bool = false
    @State var wronglastname: Bool = false
    @State var wrongemail: Bool = false
    @State var wrongphone: Bool = false
    @State var wrongBirthdate: Bool = false
    @State var wrongOldPassword: Bool = false
    @State var wrongPassword: Bool = false
    @State var wrongRepeatPassword: Bool = false
    
    @State var wrongnameMessage: String = ""
    @State var wronglastnameMessage: String = ""
    @State var wrongOldPasswordMessage: String = ""
    @State var wrongpasswordMessage: String = ""
    @State var wrongrepeatpasswordMessage: String = ""
    
    // Date Picker State Variables
    @State private var dateEdit = false
    @State private var date = Date()
    @State private var dateMin = Date()
    
    let phoneNumberKit = PhoneNumberUtility()
    @State private var phoneField: PhoneNumberTextFieldView?
    
    @State private var showAlert = false
    
    @State private var showActionDialog = false
    @State private var showErrorDialog = false
    @State private var successTitle: String = ""
    @State private var successMessage: String = ""
    @State private var actionDialogType: String = "success"
    @State var errorMess = ""
    
    @FocusState private var focusedField: FocusFields?
    @FocusState private var passFocusedField: FocusFields?
    
    // Date Formatter
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.locale = Locale(identifier: "hy")
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 24){
            HeaderView(title: getLocalString(string: "personal_data"), showArrow: true, title_img: false)
            ScrollView(.vertical,showsIndicators: false){
                VStack(alignment: .leading, spacing: 20){
                    userDataView
                    saveDataButton
                    Text("change_password")
                        .font(.LatoBold(size: 16))
                    changePasswordView
                    bottomShadowIgnore(count: 2)
                }
            }
            .sheet(isPresented: $dateEdit) {
                datePickerSheet
                    .presentationDetents([.height(500)])
            }
        }
        .padding(.horizontal)
        .onAppear{
            name = userData.name
            lastname = userData.lastname
            birthday = userData.date_of_birth
            email = userData.email
            phone = userData.phone
            selectedGender = userData.gender
        }
        .onTapGesture {
            hideKeyboard()
        }
        .overlay( showAlert ?
                  CustomDialog(isActive: $showAlert, icone_type: 0, title: getLocalString(string:"wrond_command"), message: errorMess, buttonTitle: "",padd: 50) {
                    print("Pass to viewModel")
                }
                  : nil
        )
        .overlay(
            Group {
                if showActionDialog {
                    swalDialog(isPresented: $showActionDialog, title: successTitle, text: successMessage, type: actionDialogType, button: "OK")
                }
            }
         )
        .navigationBarBackButtonHidden(true)  // Hide the back button
    }
    
    private var userDataView: some View {
        VStack(alignment: .leading, spacing: 10) {
            inputField(placeholder: getLocalString(string: "name"), text: $name, showErrorImg: $wrongname, errorMess: $wrongnameMessage, isSecure: false, showLabel: true)
                .focused($focusedField, equals: .name)
                .submitLabel(.next)
                .onSubmit {
                    focusedField = .lastname
                }
            inputField(placeholder: getLocalString(string: "lastname"), text: $lastname, showErrorImg: $wronglastname, errorMess: $wronglastnameMessage, isSecure: false, showLabel: true)
                .focused($focusedField, equals: .lastname)
                .submitLabel(.next)
                .onSubmit {
                    focusedField = .email
                }
            inputLabel(label: getLocalString(string: "birthday"))
            birthdayInput(birthdate: $birthday, wrongBirthdate: $wrongBirthdate)
                .background(Color.white) // optional for hit testing
                .contentShape(Rectangle()) // makes the full area tappable
                .onTapGesture {
                    dateEdit = true
                }
            emailInput
                .focused($focusedField, equals: .email)
                .submitLabel(.next)
                .onSubmit {
                    focusedField = .phone
                }
            inputField(placeholder: getLocalString(string: "phone_number"), text: $phone, showErrorImg: .constant(false), errorMess: .constant(""), isSecure: false, showLabel: true, isDisabled: true)
                .focused($focusedField, equals: .phone)
                .submitLabel(.done)
                .onSubmit {
                    focusedField = nil
                }
            //            phoneInput
            genderSelection
        }
    }
    
    
    // changePasswordView View
    private var changePasswordView: some View {
        VStack(alignment: .leading, spacing: 10) {
            inputField(placeholder: getLocalString(string: "current_password"), text: $old_password, showErrorImg: $wrongOldPassword, errorMess: $wrongOldPasswordMessage,  isSecure: true, showLabel: false)
                .focused($focusedField, equals: .password)
                .submitLabel(.next)
                .onSubmit {
                    focusedField = .newPassword
                }
            inputField(placeholder: getLocalString(string: "new_password"), text: $password, showErrorImg: $wrongPassword, errorMess: $wrongpasswordMessage, isSecure: true, showLabel: false)
                .focused($focusedField, equals: .newPassword)
                .submitLabel(.next)
                .onSubmit {
                    focusedField = .repeatPassword
                }
            inputField(placeholder: getLocalString(string: "confirm_new_password"), text: $repeatPassword, showErrorImg: $wrongRepeatPassword, errorMess: $wrongrepeatpasswordMessage, isSecure: true, showLabel: false)
                .focused($focusedField, equals: .repeatPassword)
                .submitLabel(.done)
                .onSubmit {
                    focusedField = nil
                }
            ButtonView(showLoading: $passwordBtnLoading, isDisabled: .constant(false), title: getLocalString(string: "save")) {
                handleEditPassword()
            }
        }
    }
    
    // Email Input
    private var emailInput: some View {
        InputView(
            placeholder: getLocalString(string: "email"),
            text: $email,
            canHide: false,
            isError: wrongemail,
            isSecure: false,
            showError: false,
            errorMessage: .constant(""),
            showLabel: true
        )
    }
    // Gender Selection
    private var genderSelection: some View {
        selectionView(title: "Gender", items: genders, selectedItem: $selectedGender)
    }
    
    // Phone Input
    private var phoneInput: some View {
        PhoneInputView(presentSheet: false, countryCode: $countryCode, mobPhoneNumber: $phone, countryFlag: "🇦🇲", countryPattern: "## ######", countryLimit: 300)
            .frame(height: 64)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color(UIColor(named: "CustomGray")!), lineWidth: 1)
            )
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
    }
    
    // Next Button
    private var saveDataButton: some View {
        ButtonView(showLoading: $saveDataLoading,  isDisabled: .constant(false), title: getLocalString(string: "save")) {
            handleUserEdit()
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
                       birthday = String(format: "%02d/%02d/%d", day, month, year)
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
    
    private func handleUserEdit() {
        saveDataLoading = true
        var error = 0
        if name.isEmpty {
            wrongname = true
            error = 1
        } else {
            wrongname = false
        }
        
        if lastname.isEmpty {
            wronglastname = true
            error = 1
        } else {
            wronglastname = false
        }
        
        if email.isEmpty {
            wrongemail = true
            error = 1
        } else {
            wrongemail = false
        }
        
        if (error == 1){
            saveDataLoading = false
            return // Early exit if there are validation errors
        }
        
        updateUserData(data: UpdateUser(name: name, lastname: lastname, email: email, date_of_birth: birthday, gender: selectedGender)){
            response in
            saveDataLoading = false
            if(response?.status == 200){
                saveDataLoading = false
                successTitle = response?.title ?? ""
                successMessage = response?.message ?? ""
                showActionDialog.toggle()
                
                updateUserEnviroment()
            } else {
                if response?.errors?.email != nil {
                    wrongemail = true
                }
                if response?.errors?.name != nil {
                    wrongname = true
                }
                if response?.errors?.lastname != nil {
                    wronglastname = true
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
    
    private func handleEditPassword() {
        passwordBtnLoading = true
        var error = 0
        if password.isEmpty {
            wrongPassword = true
            error = 1
        } else {
            wrongPassword = false
        }
        
        if old_password.isEmpty {
            wrongOldPassword = true
            error = 1
        } else {
            wrongOldPassword = false
        }
        
        if repeatPassword.isEmpty {
            wrongRepeatPassword = true
            error = 1
        } else {
            wrongRepeatPassword = false
        }
        
        if password != repeatPassword{
            wrongRepeatPassword = true
            error = 1
        } else{
            wrongRepeatPassword = false
        }
        
        if (error == 1){
            passwordBtnLoading = false
            return // Early exit if there are validation errors
        }
        
        updateUserPassword(data: UpdateUserPassword(current_password: old_password, new_password: password, repeat_password: repeatPassword)){
            response in
            passwordBtnLoading = false
            if(response?.status == 200){
                passwordBtnLoading = false
                actionDialogType = "success"
                successTitle = response?.title ?? ""
                successMessage = response?.message ?? ""
                showActionDialog = true
                updateUserPasswordEnviroment()
            } else {
                showActionDialog = true
                successTitle = ""
                actionDialogType = "error"
                if response?.errors?.current_password != nil {
                    successMessage = response?.errors?.current_password ?? ""
                    wrongOldPassword = true
                }
                if response?.errors?.new_password != nil {
                    successMessage = response?.errors?.new_password ?? ""
                    wrongPassword = true
                }
                if response?.errors?.repeat_password != nil {
                    successMessage = response?.errors?.repeat_password ?? ""
                    wrongRepeatPassword = true
                }
                if response?.message != nil && response?.message != "" {
                    showAlert = true
                    errorMess = response?.message ?? ""
                }
            }
        }
    }
    
    private func updateUserEnviroment(){
        userData.name = name
        userData.lastname = lastname
        userData.date_of_birth = birthday
        userData.email = email
        userData.gender = selectedGender
    }
    private func updateUserPasswordEnviroment(){
        userData.password = password
    }
}



