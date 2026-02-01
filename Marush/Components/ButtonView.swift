import SwiftUI


enum ButtonViewStyle {
    case filled
    case outline
}

struct ButtonView: View {
    @Binding private var showLoading: Bool
    @Binding private var isDisabled: Bool
    
    var title: String
    var action: () -> Void
    
    var style: ButtonViewStyle
    var height: CGFloat
    var cornerRadius: CGFloat
    
    /// Full control initializer
    init(
        showLoading: Binding<Bool>,
        isDisabled: Binding<Bool>,
        title: String,
        style: ButtonViewStyle = .filled,
        height: CGFloat = 56,
        cornerRadius: CGFloat = 30,
        action: @escaping () -> Void
    ) {
        self._showLoading = showLoading
        self._isDisabled = isDisabled
        self.title = title
        self.style = style
        self.height = height
        self.cornerRadius = cornerRadius
        self.action = action
    }
    
    /// Default initializer (showLoading & isDisabled = false)
    init(
        title: String,
        style: ButtonViewStyle = .filled,
        height: CGFloat = 56,
        cornerRadius: CGFloat = 30,
        action: @escaping () -> Void
    ) {
        self._showLoading = .constant(false)
        self._isDisabled = .constant(false)
        self.title = title
        self.style = style
        self.height = height
        self.cornerRadius = cornerRadius
        self.action = action
    }
    
    
    private var darkColor: Color {
        Color(UIColor(named: "ColorDark")!)
    }
    
    private var disabledColor: Color {
        Color(UIColor(named: "0F182D")!)
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                if showLoading {
                    ProgressView()
                        .progressViewStyle(
                            CircularProgressViewStyle(
                                tint: style == .filled ? .white : darkColor
                            )
                        )
                } else {
                    HStack {
                        Spacer()
                        
                        Text(title)
                            .font(.PoppinsMedium(size: 16))
                            .foregroundColor(textColor)
                        
                        Image(
                            isDisabled
                            ? "ic-chevron-right-gray"
                            : (style == .filled
                               ? "ic-chevron-right"
                               : "ic-chevron-right-dark")
                        )
                        
                        Spacer()
                    }
                }
            }
            .frame(height: height)
            .frame(maxWidth: .infinity)
            .background(backgroundBackground)
            .overlay(backgroundOverlay)
            .cornerRadius(cornerRadius)
        }
        .disabled(isDisabled || showLoading)
    }
    
    private var textColor: Color {
        if isDisabled {
            return disabledColor.opacity(0.4)
        }
        
        return style == .filled ? .white : darkColor
    }
    
    // MARK: - Background logic
    private var backgroundBackground: some View {
        Group {
            if isDisabled {
                disabledColor.opacity(0.1)
            } else{
                
                if style == .filled {
                    darkColor
                } else {
                    Color.clear
                }
            }
        }
    }
    
    private var backgroundOverlay: some View {
        Group {
            if style == .outline {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(darkColor, lineWidth: 1)
            }
        }
    }
}


struct ButtonViewConfirmation: View {
    
    @Binding var showLoading: Bool
    @Binding  var isDisabled: Bool
    @Binding  var showConfirm: Bool
    
    var title: String
    var action: () -> Void
   
    
    var backgroundColor: Color = .black
    var textColor: Color = .white
    var cornerRadius: CGFloat = 28
    var paddingVertical: CGFloat = 13
    var shadowOpacity: CGFloat = 0.2

    var body: some View {
        Button(action: action) {
            if showConfirm{
                GifImage("checkMark")
                    .frame(width: 16, height: 16)
                    .frame(maxWidth: .infinity)
            } else{
                if showLoading{
                    ProgressView()
                        .frame(width: 16, height: 16)
                        .frame(maxWidth: .infinity)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1)
                } else{
                    Text(title)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .foregroundColor(textColor)
        .padding(.vertical, paddingVertical)
        .background(backgroundColor.opacity(isDisabled ? 0.5 : 1))
        .cornerRadius(cornerRadius)
        .shadow(color: Color.gray.opacity(shadowOpacity), radius: 10)
        .padding(.vertical, 10)
        .disabled(isDisabled)
    }
}

//struct ButtonView_Previews: PreviewProvider {
//    static var previews: some View {
//        ButtonView(title: "Sign In", action: { print("Button tapped") })
//            .previewLayout(.sizeThatFits)
//            .padding()
//    }
//}
