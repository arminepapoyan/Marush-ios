//
//  Untitled.swift
//  Marush
//
//  Created by S2S Company on 30.01.2025.
//

import SwiftUI
import SDWebImageSwiftUI

struct defaultUserImage: View{
    var body: some View{
        ZStack{
            Circle().stroke(Color.gray.opacity(0.5), lineWidth: 1)
                .frame(width: 70, height: 70)
                .foregroundColor(.white)
            Image("ic-user")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                
        }
        .background(.white)
        .cornerRadius(100)
    }
}


struct bottomShadowIgnore: View{
    var count: Int = 4
    var body: some View{
        ForEach(1...count, id: \.self) { number in
            Spacer()
        }
    }
}

struct CustomConfirmationDialog: View {
    @Binding var isPresented: Bool  // To control the presentation state
    var title: String
    var text: String
    var confirmButton: String
    var cancelButton: String
    
    var onConfirm: () -> Void  // Action when "Logout" is pressed
    
    @State private var showLoading = false
    var body: some View {
        ZStack{
            // Fully transparent background
           Color.black.opacity(0.3) // Almost invisible but still captures taps to dismiss
               .ignoresSafeArea()
               .onTapGesture {
                   isPresented = false  // Dismiss the dialog when tapped outside
               }
            VStack(spacing: 15) {
                Text("\(title)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Text("\(text)")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                
                ButtonView(
                   showLoading: $showLoading,
                   isDisabled: .constant(false),
                   title: confirmButton,
                   action: {
                       showLoading = true  // Start loading
                       DispatchQueue.main.asyncAfter(deadline: .now() + 1) {  // Simulate some delay
                           onConfirm()  // Perform logout
                           showLoading = false  // Stop loading
                           isPresented = false  // Dismiss dialog
                       }
                   }
               )
               .padding(.horizontal)

                
                Button(action: {
                    isPresented = false  // Just close the dialog
                }) {
                    Text("\(cancelButton)")
                        .font(.body)
                        .foregroundColor(.gray)
                        .underline()
                }
            }
            
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 10)
            .frame(maxWidth: UIScreen.main.bounds.width - 40)  // Dialog width control
        }
    }
}


struct swalDialog: View {
    @Binding var isPresented: Bool  // To control the presentation state
    var title: String
    var text: String
    var type: String
    var button: String
    
    @State private var showLoading = false
    var body: some View {
        ZStack{
            // Fully transparent background
           Color.black.opacity(0.3) // Almost invisible but still captures taps to dismiss
               .ignoresSafeArea()
               .onTapGesture {
                   isPresented = false  // Dismiss the dialog when tapped outside
               }
            VStack(spacing: 15) {
                Image(type == "success" ? "ic-success" : "ic-error")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 50)
                Text("\(title)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Text("\(text)")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                ButtonView(
                   showLoading: $showLoading,
                   isDisabled: .constant(false),
                   title: button,
                   action: {
                       showLoading = true  // Start loading
                       DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {  // Simulate some delay
                           showLoading = false  // Stop loading
                           isPresented = false  // Dismiss dialog
                       }
                   }
               )
               .padding(.horizontal, 40)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 10)
            .frame(maxWidth: UIScreen.main.bounds.width - 40)  // Dialog width control
        }
    }
}


// Input Field Helper
func inputField(placeholder: String, text: Binding<String>, showErrorImg: Binding<Bool>, errorMess: Binding<String>, isSecure: Bool, showLabel: Bool, isDisabled: Bool = false) -> some View {
    InputView(
        placeholder: placeholder,
        text: text,
        canHide: isSecure,
        isError: showErrorImg.wrappedValue,
        isSecure: isSecure,
        showError: false,
        errorMessage: errorMess,
        showLabel: showLabel,
        isDisabled: isDisabled
    )
}

// Birthday Input
struct birthdayInput: View {
    @Binding var birthdate: String
    @Binding var wrongBirthdate: Bool
    var body: some View{
        HStack {
            ZStack(alignment: .leading) {
                Text("Birthdate")
                    .font(.Poppins(size: birthdate.isEmpty ? 16: 13))
                    .foregroundColor(.black.opacity(0.5))
                    .padding(.horizontal, 10)
                    .offset(y: birthdate.isEmpty ? 0 : -15)
                    .scaleEffect(birthdate.isEmpty ? 1 : 0.9, anchor: .leading)
                
                TextField("", text: $birthdate)
                    .font(.system(size: 18, design: .rounded))
                    .foregroundColor(.black)
                    .padding(.horizontal, 10)
                    .disabled(true)  // Make the TextField read-only
                    .offset(y: birthdate.isEmpty ? 0 : 8)
            }
            
            if wrongBirthdate{
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.black)
                    .padding(.trailing, 8)
            }
        }
        .padding(.vertical, 20)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color(UIColor(named: "CustomGray")!), lineWidth: 1)
        )
        .overlay(alignment: .trailing){
            wrongBirthdate ?
            VStack(alignment: .trailing) {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.system(size: 20))
                    .padding(.trailing, 8)
            }
            : nil
        }
        .cornerRadius(15)
    }
}

struct inputLabel: View{
    var label: String
    var body: some View{
        Text("\(label)")
            .font(.PoppinsMedium(size: 14))
            .foregroundColor(Color(UIColor(named: "ColorDark")!))
    }
}

struct CustomSlider: View {
    @Binding var value: Double
//    @Binding var selectedFeatures: [Int: String]
//    var feature: Feature
    var range: ClosedRange<Double> = 0...100
    var step: Double = 25
    var lineHeight: CGFloat = 8
    var customIcon: String = "ic-slider-arrow"  // Use SF Symbols or custom images

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background line with customizable height
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color(UIColor(named: "ToggleColor")!))
                    .frame(width: geometry.size.width - (value == range.upperBound ? 10 : 0),  height: lineHeight)

                // Foreground line representing the slider's current value
                RoundedRectangle(cornerRadius: 0)
                    .fill(Color(UIColor(named: "3B3B3B")!))
                    .frame(width: CGFloat(value / range.upperBound) * geometry.size.width - (value == range.lowerBound ? 0 : 10), height: lineHeight)
                    .cornerRadius(5, corners: [.topLeft, .bottomLeft])

                // Custom icon for the slider knob
                Image(customIcon)
                    .foregroundColor(Color(UIColor(named: "3B3B3B")!))
                    .offset(x: CGFloat(value / range.upperBound) * geometry.size.width - (value == range.lowerBound ? 0 : 10) , y: 0)
                    .gesture(
                        DragGesture()
                            .onChanged { drag in
                                let newValue = max(min(drag.location.x / geometry.size.width * range.upperBound, range.upperBound), range.lowerBound)
                                value = (newValue / step).rounded() * step
                            }
                    )
            }
        }
    }
}


struct sliderNumber: View{
    var num: Int
    var spacer: Bool = true
    
    var body: some View{
        VStack(spacing: 9){
            Rectangle()
                .frame(width: 1, height: 8)
                .foregroundColor(Color(UIColor(named: "ToggleColor")!))
            Text("\(num)")
                .font(.Poppins(size: 12))
        }
        if spacer {
            Spacer()
        }
    }
}



struct QuantityChanger: View {
    @Binding var quantity: Int

    var body: some View {
        HStack(spacing: 10) {
            Button(action: {
                if quantity > 1 {
                    quantity -= 1
                }
            }) {
                Image(systemName: "minus.circle")
                    .font(.system(size: 24))
                    .foregroundColor(.black)
            }
            
            Text("\(quantity)")
                .font(.PoppinsBold(size: 18))
                .frame(minWidth: 25)
            
            Button(action: {
                quantity += 1
            }) {
                Image(systemName: "plus.circle")
                    .font(.system(size: 24))
                    .foregroundColor(.black)
            }
        }
    }
}

struct CircleIcon: View {

    let imageName: String
    var size: CGFloat = 48
    var imageSize: CGFloat = 25
    var backgroundColor: Color = .white
    var badgeCount: Int? = nil

    var body: some View {
        Circle()
            .fill(backgroundColor)
            .frame(width: size, height: size)
            .overlay(
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: imageSize, height: imageSize)
            )
            .overlay(alignment: .topTrailing) {
                if let badge = badgeCount, badge > 0 {
                    BadgeView(count: badge)
                        .offset(x: 3, y: 0)
                }
            }
    }
}


struct BadgeView: View {
    let count: Int

    var body: some View {
        Text("\(count)")
            .font(.PoppinsBold(size: 12))
            .foregroundColor(.white)
            .frame(width: 16, height: 16)
            .background(Circle().fill(Color(UIColor(named: "ColorPrimary")!)))
    }
}


struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: 10) {
            TextField("search_for", text: $text)
                .font(.Poppins(size: 14))
                .foregroundColor(Color(UIColor(named: "ColorDark")!))
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color(UIColor(named: "ColorDark")!))
                }
            }
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
                .foregroundColor(Color(UIColor(named: "ColorDark")!))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(Color(.white))
        )
    }
}

struct CallButton: View {
    let phone: String?

    var body: some View {
        if let phone,
           !phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {

            Button {
                call(phone)
            } label: {
                CircleIcon(imageName: "ic-phone-call")
            }
        }
    }

    private func call(_ phone: String) {
        let cleanPhone = phone
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")

        if let url = URL(string: "tel://\(cleanPhone)"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

struct SectionHeader: View {
    var title: String
    var fontSize: CGFloat = 22
    var buttonTitle: String = getLocalString(string: "view_all")
    var action: () -> Void
    
    var body: some View {
        HStack {
            Text(title)
                .font(.Lato(size: fontSize))
            Spacer()
            LabelButton(title: buttonTitle) {
                action()
            }
        }
    }
}
