//
//  TabContentView.swift
//  Gotcha
//
//  Created by s2s s2s on 28.10.2024.
//

import SwiftUI
import UIKit

struct TabContent: View {
    
//    init() {
//        TabBarAppearance.setup()
//    }
    
    @EnvironmentObject var settings: UserSettings
    @EnvironmentObject var userData: UserViewModel
    @EnvironmentObject var globalSettings: GlobalSettings
    @EnvironmentObject var appData: AppDataViewModel
//    @State private var selection = 0
    @State private var resetNavigationID = UUID()
    
    @State var webViewFinishedLoading = false
    @State var closePaymentAlert: Bool = false
    
    
//    @State var testSheet: Bool = true
    var body: some View {
        //        NavigationStack{
        let selectable = Binding(
            get: { settings.selection },
            set: { settings.selection = $0
                settings.resetNavigationID = UUID()
            })
        
        TabView(selection: $settings.selection) {
            TabBarItem(
                tag: 0,
                selection: settings.selection,
                title: getLocalString(string: "home"),
                icon: "ic-home"
            ) {
                HomeView()
                    .environmentObject(settings)
                    .environmentObject(userData)
                    .environmentObject(appData)
                    .id(settings.resetNavigationID)
            }

            TabBarItem(
                tag: 1,
                selection: settings.selection,
                title: getLocalString(string: "my_orders"),
                icon: "ic-orders"
            ) {
                HomeView()
                    .environmentObject(settings)
            }

            TabBarItem(
                tag: 2,
                selection: settings.selection,
                title: getLocalString(string: "my_cart"),
                icon: "ic-cart"
            ) {
                HomeView()
                    .environmentObject(settings)
            }

            TabBarItem(
                tag: 3,
                selection: settings.selection,
                title: getLocalString(string: "my_profile"),
                icon: "ic-profile"
            ) {
                HomeView()
                    .environmentObject(settings)
            }
        }
        
//        VStack(spacing: 0){
//            TabView(selection: $settings.selection) {
//                TabBarItem(
//                    tag: 0,
//                    selection: settings.selection,
//                    title: getLocalString(string: "home"),
//                    icon: "ic-home"
//                ) {
//                    HomeView()
//                        .environmentObject(settings)
//                        .environmentObject(userData)
//                        .environmentObject(appData)
//                        .id(settings.resetNavigationID)
//                }
//
//                TabBarItem(
//                    tag: 1,
//                    selection: settings.selection,
//                    title: getLocalString(string: "my_orders"),
//                    icon: "ic-orders"
//                ) {
//                    HomeView()
//                        .environmentObject(settings)
//                }
//
//                TabBarItem(
//                    tag: 2,
//                    selection: settings.selection,
//                    title: getLocalString(string: "my_cart"),
//                    icon: "ic-cart"
//                ) {
//                    HomeView()
//                        .environmentObject(settings)
//                }
//
//                TabBarItem(
//                    tag: 3,
//                    selection: settings.selection,
//                    title: getLocalString(string: "my_profile"),
//                    icon: "ic-profile"
//                ) {
//                    HomeView()
//                        .environmentObject(settings)
//                }
//            }
//            .environmentObject(settings)
//            .environmentObject(userData)
//            .environmentObject(appData)
//            .padding(.bottom, UIDevice.current.localizedModel == "iPad" ? 15 : 0)
//            .onOpenURL { url in
//                handleDeepLink(url: url)
//            }
////            .overlay(){ middleOrderButton }
////            .sheet(isPresented: Binding(
////                get: { settings.showProductDialog || settings.showCartDialog },
////                set: { value in
////                    if !value {
////                        settings.showProductDialog = false
////                        settings.showCartDialog = false
////                    }
////                }
////            )) {
////                if settings.showProductDialog {
////                    ProductDetailView(productId: settings.dialogProducId)
////                        .environmentObject(settings)
////                        .presentationSizingPage()
////                } else if settings.showCartDialog {
////                    CartView()
////                        .environmentObject(settings)
////                        .environmentObject(userData)
////                        .presentationSizingPage()
////                }
////            }
////            .sheet(isPresented: $settings.showPayment) {
////                paymentSheet
////            }
////            .overlay(settings.orderPaymentResult.showPaymentDialog ? paymentDialog : nil)
//            .overlay(settings.customDialog.showDialog ? messageDialog : nil)
//        }
////        .environmentObject(settings)
////        .ignoresSafeArea(.all,edges: .bottom)
////        .ignoresSafeArea(edges: .top)
//        .environment(\.locale, .init(identifier: settings.appLang))
//        .navigationBarBackButtonHidden(true)
//        .onChange(of: settings.cart_count) { newValue in
//            NotificationCenter.default.post(name: .cartCountChange, object: nil, userInfo: ["cart_count": settings.cart_count])
//        }
//        .onReceive(NotificationCenter.default.publisher(for: .orderPayed)) { notification in
//            if let userInfo = notification.userInfo{
//                if let orderIdString = userInfo["orderId"] as? String,
//                   let orderId = Int(orderIdString) {
//                    if settings.showPayment {
//                        if settings.orderId == orderId{
//                            settings.showPayment = false
////                            getOrderData(settings, selection: 0)
//                        }
//                    }
//                }
//            }
//        }
    }
        
    var paymentSheet: some View{
        ZStack{
            VStack{
                HStack{
                    Button( action: {
                        closePaymentAlert.toggle()
                    },label:{
                        Text("card_close_page")
                            .font(.system(size: 18))
                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                            .foregroundColor(.white)
                            .frame(minWidth: 0, maxWidth: .infinity)
                    })
                }
                .padding(.vertical,15)
                .background(.black)
                VStack{
                    WebView(url: settings.paymentUrl)
                }
                .padding(.horizontal,10)
            }
        }
        .interactiveDismissDisabled(true)
        .overlay(
            Group {
                if closePaymentAlert {
                    CustomConfirmationDialog(
                        isPresented: $closePaymentAlert,
                        title: getLocalString(string: "card_close_page"),
                        text: getLocalString(string: "are_you_sure_you_want_to_close_page"),
                        confirmButton: getLocalString(string: "close"),
                        cancelButton: getLocalString(string: "cancel"),
                        onConfirm: {
//                            getOrderData(settings, selection: 0)
                            closePaymentAlert.toggle()
                            settings.showPayment.toggle()
                        })
                    .transition(.scale)  // Smooth transition animation
                    .animation(.easeInOut, value: closePaymentAlert)
                }
            }
        )
    }
    var middleOrderButton: some View{
        VStack {
            Spacer()
            HStack {
                VStack{
                    ZStack {
                        Image("topIconBackgroundSVG")
                            .frame(width: 85)
                            .offset(y: -2)
                        ZStack{
                            Circle()
                                .foregroundColor(Color(UIColor(named: "FCF3F6")!))
                                .frame(width: 77, height: 77)
                            
                            VStack {
                                Image(settings.selection == 2 ? "ic-order-fill" : "ic-order")
                                Text("order")
                                    .font(.PoppinsMedium(size: 10))
                                    .foregroundColor(settings.selection == 2 ?  .black : Color(UIColor(named: "TextGray")!))
                                    .fontWeight(settings.selection == 2 ? .bold : .medium)
                            }
                        }
                        .offset(y: -1)
                    }
                    .onTapGesture {
                        settings.selection = 2
                    }
                }
            }
            .offset(y: UIDevice.current.localizedModel == "iPad" ? 3 : -15) // Adjust to match the TabView position
        }
    }
    
//    var paymentDialog: some View {
//        return CustomDialog(
//            isActive: $settings.orderPaymentResult.showPaymentDialog,
//            icone_type: settings.orderPaymentResult.iconType,
//            title: settings.orderPaymentResult.getOrderAlertTitle,
//            message: settings.orderPaymentResult.getOrderAlertMessage,
//            buttonTitle: "Close",
//            padd: 50
//        ) {
//        }
//    }
    
    var messageDialog: some View {
        return CustomDialog(
            isActive: $settings.customDialog.showDialog,
            icone_type: settings.customDialog.iconType,
            title: settings.customDialog.title,
            message: settings.customDialog.message,
            buttonTitle: "Close",
            padd: 50
        ) {
        }
    }
    
    private func getOverlayContent() -> AnyView {
//        if let cartCount = appData.cart?.count, cartCount > 0 {
        if settings.cart_count > 0 {
            return AnyView(
                Text("\(settings.cart_count < 100 ? "\(settings.cart_count)" : "99+")")
                    .font(.PoppinsBold(size: 11))
                    .foregroundColor(.black)
                    .padding(.top, 5)
                    .padding(.leading, 4)
            )
        } else {
            return AnyView(EmptyView())
        }
    }
    
    private func handleDeepLink(url: URL) {
        guard let host = url.host
        else {
            print("Host not found")
            return
        }
        
        switch host {
        case "my_cart":
            settings.selection = 2
        case "home":
            settings.selection = 0
        case "my_orders":
            settings.selection = 1
        case "my_profile":
            settings.selection = 3
        case "idramPayment":
            settings.selection = 0
        default:
            break
        }
        
        if url.pathComponents.contains("payment") && url.pathComponents.contains("idram"){
            print("Get order data for idram launched")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                getOrderData(settings, selection: settings.selection)
            }
        }
    }
}

struct CompactSizeModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 18.0, *) {
            content.environment(\.horizontalSizeClass, .compact)
        } else {
            content
        }
    }
}
