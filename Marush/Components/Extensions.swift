//
//  Extensions.swift
//  Marush
//
//  Created by S2S Company on 30.01.2025.
//

import SwiftUI
import Combine

extension Font {
    static func Poppins(size: CGFloat) -> Font {
        .custom("Poppins-Regular", size: size)
    }
    
    static func PoppinsBlack(size: CGFloat) -> Font {
        .custom("Poppins-Black", size: size)
    }
    
    static func PoppinsBlackItalic(size: CGFloat) -> Font {
        .custom("Poppins-BlackItalic", size: size)
    }
    
    static func PoppinsBold(size: CGFloat) -> Font {
        .custom("Poppins-Bold", size: size)
    }
    
    static func PoppinsBoldItalic(size: CGFloat) -> Font {
        .custom("Poppins-BoldItalic", size: size)
    }
    
    static func PoppinsExtraBold(size: CGFloat) -> Font {
        .custom("Poppins-ExtraBold", size: size)
    }
    
    static func PoppinsExtraBoldItalic(size: CGFloat) -> Font {
        .custom("Poppins-ExtraBoldItalic", size: size)
    }
    
    static func PoppinsExtraLight(size: CGFloat) -> Font {
        .custom("Poppins-ExtraLight", size: size)
    }
    
    static func PoppinsExtraLightItalic(size: CGFloat) -> Font {
        .custom("Poppins-ExtraLightItalic", size: size)
    }
    
    static func PoppinsItalic(size: CGFloat) -> Font {
        .custom("Poppins-Italic", size: size)
    }
    
    static func PoppinsLight(size: CGFloat) -> Font {
        .custom("Poppins-Light", size: size)
    }
    
    static func PoppinsLightItalic(size: CGFloat) -> Font {
        .custom("Poppins-LightItalic", size: size)
    }
    
    static func PoppinsMedium(size: CGFloat) -> Font {
        .custom("Poppins-Medium", size: size)
    }
    
    static func PoppinsMediumItalic(size: CGFloat) -> Font {
        .custom("Poppins-MediumItalic", size: size)
    }
    
    static func PoppinsSemiBold(size: CGFloat) -> Font {
        .custom("Poppins-SemiBold", size: size)
    }
    
    static func PoppinsSemiBoldItalic(size: CGFloat) -> Font {
        .custom("Poppins-SemiBoldItalic", size: size)
    }
    
    static func PoppinsThin(size: CGFloat) -> Font {
        .custom("Poppins-Thin", size: size)
    }
    
    static func PoppinsThinItalic(size: CGFloat) -> Font {
        .custom("Poppins-ThinItalic", size: size)
    }
}

extension Bundle {
    func decode<T: Decodable>(_ file: String) -> T {
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Failed to locate \(file) in bundle.")
        }

        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) from bundle.")
        }

        let decoder = JSONDecoder()

        guard let loaded = try? decoder.decode(T.self, from: data) else {
            fatalError("Failed to decode \(file) from bundle.")
        }

        return loaded
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
            
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
    
    func tabViewStyle(backgroundColor: Color? = nil,
                      itemColor: Color? = nil,
                      selectedItemColor: Color? = nil,
                      badgeColor: Color? = nil) -> some View {
        onAppear {
            let itemAppearance = UITabBarItemAppearance()
            if let uiItemColor = itemColor?.uiColor {
                itemAppearance.normal.iconColor = uiItemColor
                itemAppearance.normal.titleTextAttributes = [
                    .foregroundColor: uiItemColor
                ]
            }
            if let uiSelectedItemColor = selectedItemColor?.uiColor {
                itemAppearance.selected.iconColor = uiSelectedItemColor
                itemAppearance.selected.titleTextAttributes = [
                    .foregroundColor: uiSelectedItemColor
                ]
            }
            if let uiBadgeColor = badgeColor?.uiColor {
                itemAppearance.normal.badgeBackgroundColor = uiBadgeColor
                itemAppearance.selected.badgeBackgroundColor = uiBadgeColor
            }
            
            let appearance = UITabBarAppearance()
            if let uiBackgroundColor = backgroundColor?.uiColor {
                appearance.backgroundColor = uiBackgroundColor
            }
            
            appearance.stackedLayoutAppearance = itemAppearance
            appearance.inlineLayoutAppearance = itemAppearance
            appearance.compactInlineLayoutAppearance = itemAppearance
            
            UITabBar.appearance().standardAppearance = appearance
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
        }
    }
    
    func disableWithOpacity(_ condition: Bool) -> some View {
        self
            .disabled(condition)   // Disables the view when the condition is true
            .opacity(condition ? 0.6 : 1) // Changes opacity based on the condition
    }
}

//extension UITabBarController {
//    open override func viewWillLayoutSubviews() {
//        super.viewWillLayoutSubviews()
//
//        let appearance = UITabBarItemAppearance()
//          appearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.lightGray] // Normal state color
//          appearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black] // Selected state color
//        
//          // Apply the appearance settings to the tab bar
//          let tabBarAppearance = UITabBarAppearance()
//          tabBarAppearance.backgroundColor = UIColor.white
//          tabBarAppearance.stackedLayoutAppearance = appearance
//          tabBarAppearance.inlineLayoutAppearance = appearance
//          tabBarAppearance.compactInlineLayoutAppearance = appearance
//          
//          // Apply appearance to the tab bar
//          tabBar.standardAppearance = tabBarAppearance
//        if #available(iOS 15.0, *) {
//            tabBar.scrollEdgeAppearance = tabBarAppearance
//        }
//
//        
//        tabBar.layer.masksToBounds = true
//        tabBar.layer.cornerRadius = 15
//        // Choose with corners should be rounded
//        tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] // top left, top right
//
//        
//        let cartCount = UserSettings.shared.cart_count
//        print("Current cart count is \(cartCount)")
//
//        // Show or hide the shadow based on cart_count
//        if cartCount > 0 {
//            if let shadowView2 = view.subviews.first(where: { $0.accessibilityIdentifier == "TabBarShadow2" }) {
//                shadowView2.frame = tabBar.frame
//            } else {
//                let shadowView2 = UIView(frame: .zero)
//                shadowView2.frame = tabBar.frame
//                shadowView2.accessibilityIdentifier = "TabBarShadow2"
//                shadowView2.backgroundColor = UIColor.white
//                shadowView2.layer.cornerRadius = tabBar.layer.cornerRadius
//                shadowView2.layer.maskedCorners = tabBar.layer.maskedCorners
//                shadowView2.layer.masksToBounds = false
//                // Use the custom color "ColorPrimary" for shadowColor
//                if let colorPrimary = UIColor(named: "ColorPrimary") {
//                    shadowView2.layer.shadowColor = colorPrimary.cgColor // Custom shadow color
//                } else {
//                    // Fallback if the color is not found
//                    shadowView2.layer.shadowColor = UIColor.black.cgColor // Default shadow color
//                }
//                
//                shadowView2.layer.shadowOffset = CGSize(width: 0.0, height: UIDevice.current.localizedModel == "iPad" ? -40 : -45)
//                shadowView2.layer.shadowOpacity = 1
//                shadowView2.layer.shadowRadius = 0
//                view.addSubview(shadowView2)
//                view.bringSubviewToFront(tabBar)
//            }
//        } else {
//            // Remove shadow if cart_count is 0
//            if let shadowView2 = view.subviews.first(where: { $0.accessibilityIdentifier == "TabBarShadow2" }) {
//                shadowView2.removeFromSuperview()
//            }
//        }
//        
//        
//        if let shadowView = view.subviews.first(where: { $0.accessibilityIdentifier == "TabBarShadow1" }) {
//            shadowView.frame = tabBar.frame
//        } else {
//            let shadowView = UIView(frame: .zero)
//            shadowView.frame = tabBar.frame
//            shadowView.accessibilityIdentifier = "TabBarShadow1"
//            shadowView.backgroundColor = UIColor.white
//            shadowView.layer.cornerRadius = tabBar.layer.cornerRadius
//            shadowView.layer.maskedCorners = tabBar.layer.maskedCorners
//            shadowView.layer.masksToBounds = false
//            shadowView.layer.shadowColor = Color.gray.cgColor
//            shadowView.layer.shadowOffset = CGSize(width: 0.0, height: -1)
//            shadowView.layer.shadowOpacity = 0.2
//            shadowView.layer.shadowRadius = 0
////            shadowView.layer.zPosition = tabBar.layer.zPosition - 1
//           view.insertSubview(shadowView, belowSubview: tabBar)
//           self.view.insertSubview(self.tabBar, aboveSubview: shadowView)
//        }
//    }
//}

extension String {
    func trimmingAllSpaces(using characterSet: CharacterSet = .whitespacesAndNewlines) -> String {
        return components(separatedBy: characterSet).joined()
    }
}

extension Color {
    var uiColor: UIColor? {
        if #available(iOS 14.0, *) {
            return UIColor(self)
        } else {
            let scanner = Scanner(string: self.description.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
            var hexNumber: UInt64 = 0
            var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 0.0
            let result = scanner.scanHexInt64(&hexNumber)
            if result {
                r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                a = CGFloat(hexNumber & 0x000000ff) / 255
                return UIColor(red: r, green: g, blue: b, alpha: a)
            } else {
                return nil
            }
        }
    }
}

func selectionView(title: String, items: [String], selectedItem: Binding<String>) -> some View {
    VStack(alignment: .leading, spacing: 10) {
        Text(title)
            .font(.headline)
        
        HStack {
            ForEach(items, id: \.self) { item in
                HStack {
                    Image(systemName: selectedItem.wrappedValue == item ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(Color(UIColor(named: "ColorDark")!))
                        .onTapGesture {
                            selectedItem.wrappedValue = item
                        }
                    Text(item)
                        .onTapGesture {
                            selectedItem.wrappedValue = item
                        }
                }
            }
        }
    }
}


class ViewModel: ObservableObject {
    @Published var isActive = false
    @Published var showingAlert = false
    @Published var time: String = "2:00"
    @Published var minutes: Float = 1.0 {
        didSet {
            self.time = "\(Int(minutes)):00"
        }
    }
    @Published var canResendCode: Bool = false
    
    private var timer: AnyCancellable?
    var initialTime = 2
    var endDate = Date()
    var pauseDate = Date()
    var pauseInterval = 0.0

    // Start the timer with the given amount of minutes
    func start(minutes: Float) {
        self.initialTime = Int(minutes)
        self.reset()
        
        self.endDate = Date().addingTimeInterval(TimeInterval(initialTime * 60))
        self.isActive = true
        self.canResendCode = false
        
        // Start the timer
        timer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateCountdown()
            }
    }

    // Reset the timer
    func reset() {
        self.isActive = false
        self.pauseInterval = 0.0
        self.minutes = Float(initialTime)
        self.time = "\(Int(minutes)):00"
        
        // Cancel the timer
        timer?.cancel()
        timer = nil
    }

    func pause() {
        if self.isActive {
            pauseDate = Date()
        } else {
            // Keep track of the total time we're paused
            pauseInterval += Date().timeIntervalSince(pauseDate)
        }
        self.isActive.toggle()
    }

    // Show updates of the timer
    func updateCountdown() {
        guard isActive else { return }
        
        // Gets the current date and makes the time difference calculation
        let now = Date()
        let diff = endDate.timeIntervalSince(now) + pauseInterval
        
        // Checks that the countdown is not <= 0
        if diff <= 0 {
            self.isActive = false
            self.time = "0:00"
            self.showingAlert = true
            
            // Cancel the timer when finished
            timer?.cancel()
            timer = nil
            canResendCode = true
            return
        }
        
        // Turns the time difference calculation into sensible data and formats it
        let minutes = Int(diff) / 60
        let seconds = Int(diff) % 60
        
        // Updates the time string with the formatted time
        self.time = String(format: "%d:%02d", minutes, seconds)
    }
}


extension TimerView {
   final class ViewModel: ObservableObject {
       @Published var isActive = false
       @Published var showingAlert = false
       @Published var time: String = "2:00"
       @Published var minutes: Float = 2.0 {
           didSet {
               self.time = "\(Int(minutes)):00"
           }
       }
       var initialTime = 0
       var endDate = Date()
       var pauseDate = Date()
       var pauseInterval = 0.0
       
       // Start the timer with the given amount of minutes
       func start(minutes: Float) {
           self.initialTime = 2
           self.reset()
           self.endDate = Date()
           self.endDate = Calendar.current.date(byAdding: .minute, value: self.initialTime, to: endDate)!
           self.isActive = true
       }
       
       // Reset the timer
       func reset() {
           self.isActive = false
           self.pauseInterval = 0.0
           self.minutes = Float(initialTime)
           self.time = "\(Int(minutes)):00"
       }
       
       func pause() {
           if self.isActive {
               pauseDate = Date()
           } else {
               // keep track of the total time we're paused
               pauseInterval += Date().timeIntervalSince(pauseDate)
           }
           self.isActive.toggle()
       }
       
       // Show updates of the timer
       func updateCountdown(){
           guard isActive else { return }
           
           // Gets the current date and makes the time difference calculation
           let now = Date()
           let diff = endDate.timeIntervalSince1970 + self.pauseInterval - now.timeIntervalSince1970
           
           // Checks that the countdown is not <= 0
           if diff <= 0 {
               self.isActive = false
               self.time = "0:00"
               self.showingAlert = true
               return
           }
           
           // Turns the time difference calculation into sensible data and formats it
           let date = Date(timeIntervalSince1970: diff)
           let calendar = Calendar.current
           let minutes = calendar.component(.minute, from: date)
           let seconds = calendar.component(.second, from: date)
           
           // Updates the time string with the formatted time
           //self.minutes = Float(minutes)
           self.time = String(format:"%d:%02d", minutes, seconds)
       }
   }
}

struct TimerView: View {
   @ObservedObject var vm = ViewModel()
   let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
   let width: Double = 250
   
   var body: some View {
       VStack {
           
           Text("Timer: \(vm.time)")
               .font(.system(size: 50, weight: .medium, design: .rounded))
               .alert("Timer done!", isPresented: $vm.showingAlert) {
                   Button("Continue", role: .cancel) {
                       vm.start(minutes: Float(vm.minutes))
                   }
               }
               .padding()
          
       }
       .onAppear(){
           vm.start(minutes: Float(vm.minutes))
       }
       .onReceive(timer) { _ in
           vm.updateCountdown()
       }
       
   }
}

extension Dictionary {
    func mapKeys<T: Hashable>(_ transform: (Key) -> T) -> [T: Value] {
        Dictionary<T, Value>(uniqueKeysWithValues: map { (transform($0.key), $0.value) })
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = 0
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    @ViewBuilder
    func presentationSizingPage() -> some View {
        if #available(iOS 18.0, macOS 15.0, tvOS 18.0, visionOS 2.0, watchOS 11.0, *) {
            self.presentationSizing(.page)
        } else {
            self
        }
    }
}


extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}



struct KeyboardAwareModifier: ViewModifier {
    @State private var offset: CGFloat = 0
    let publisher = NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)

    func body(content: Content) -> some View {
        content
            .padding(.bottom, offset)
            .onReceive(publisher) { notification in
                if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    if frame.origin.y == UIScreen.main.bounds.height {
                        offset = 0
                    } else {
                        offset = frame.height - 40 // leave padding
                    }
                }
            }
            .animation(.easeOut(duration: 0.25), value: offset)
    }
}

extension View {
    func keyboardAware() -> some View {
        self.modifier(KeyboardAwareModifier())
    }
}
