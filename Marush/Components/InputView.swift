import SwiftUI
import PhoneNumberKit

struct InputView: View {
    var placeholder: String
    @Binding var text: String
    var canHide: Bool
    var isError: Bool
    @State var isSecure: Bool
    var showError: Bool
    @Binding var errorMessage: String
    var showLabel: Bool
    var isDisabled: Bool = false
    
    @State var showText: Bool = false
    
    var inputVerticalPadding: CGFloat = 12
    var inputHorizontalPadding: CGFloat = 20

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if showLabel{
                inputLabel(label: placeholder)
            }
            ZStack(alignment: .leading) {
//                !showLabel &&
                if text.isEmpty{
                    Text(placeholder)
                        .font(.Poppins(size: text.isEmpty ? 16: 13))
//                        .foregroundColor(text.isEmpty ? .black.opacity(0.5) : .black.opacity(0.7))
                        .foregroundColor(Color(UIColor(named: "8C95AA")!))
                        .padding(.horizontal, inputHorizontalPadding)
                        .offset(y: text.isEmpty ? 0 : -20)
                        .scaleEffect(text.isEmpty ? 1 : 0.9, anchor: .leading)
                }
                if isSecure {
                    SecureField("", text: $text)
                        .textInputAutocapitalization(.never)
//                        .font(.system(size: 18, design: .rounded))
                        .font(.Poppins(size: 16))
                        .foregroundColor(.black)
                        .offset(y: 0)
                        .padding(.horizontal, inputHorizontalPadding)
                } else {
                    TextField("", text: $text)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .font(.Poppins(size: 16))
                        .foregroundColor(.black)
                        .offset(y: 0)
                        .padding(.horizontal, inputHorizontalPadding)
                        .disabled(isDisabled)
                }
            }
            .padding(.vertical, inputVerticalPadding)
            
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color((showError || isError) ? UIColor(named: "F04751")! : UIColor(named: "CustomGray")!), lineWidth: (showError || isError) ? 1 : 1)
//                    .background(.white)
            )
            .background(Color.white)
            .padding(2)
            .overlay(alignment: .trailing){
                isError ?
                    VStack(alignment: .trailing) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.system(size: 20))
                            .padding(.trailing, canHide ? 50 : 8)
                    }
                : nil
            }
            .overlay(alignment: .trailing) {
                if canHide {
                    Button(action: {
                        showText.toggle()
                        isSecure.toggle()
                    }) {
                        Image(systemName: showText ? "eye.fill" : "eye.slash.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color(UIColor(named: "CustomGray")!))
                            .padding(.trailing, 8)
                    }
                }
            }
            .cornerRadius(30)

            if ((showError || isError) && !errorMessage.isEmpty){
                Text(errorMessage)
                    .font(.system(size: 15))
                    .foregroundColor(Color(UIColor(named: "CustomRed")!))
                    .multilineTextAlignment(.leading)
                    .padding(.leading, 15)
            }
        }
    }
}

struct PhoneNumberTextFieldView: UIViewRepresentable {
    @Binding var phoneNumber: String
    private let textField = PhoneNumberTextField()
 
    func makeUIView(context: Context) -> PhoneNumberTextField {
        textField.withExamplePlaceholder = true
        //textField.font = UIFont(name: GlobalConstant.paragraphFont.rawValue, size: 17)
        textField.withFlag = true
        textField.withPrefix = true
        // textField.placeholder = "Enter phone number"
        textField.becomeFirstResponder()
        return textField
    }

    func getCurrentText() {
        self.phoneNumber = textField.text!
    }
    
    func updateUIView(_ view: PhoneNumberTextField, context: Context) {
  
    }
    
}

//#Preview {
//    StatefulPreviewWrapper("John Doe") { binding in
//        InputView(placeholder: "Test", text: binding, canHide: false, isError: false, isSecure: false, showError: false, errorMessage: .constant(""), showLabel: false)
//        
//    }
//}
//
//struct StatefulPreviewWrapper<Value>: View {
//    @State private var value: Value
//    private var content: (Binding<Value>) -> InputView
//    
//    init(_ value: Value, content: @escaping (Binding<Value>) -> InputView) {
//        self._value = State(wrappedValue: value)
//        self.content = content
//    }
//
//    var body: some View {
//        content($value)
//    }
//}
