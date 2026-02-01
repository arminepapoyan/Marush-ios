

import SwiftUI
//import IdramMerchantPayment
import SDWebImageSwiftUI
//import Lottie

struct HomeView: View {
    @EnvironmentObject var userData: UserViewModel
    @EnvironmentObject var settings: UserSettings
    @EnvironmentObject var appData: AppDataViewModel
    
    @State var showHeader: Bool = true
    @State private var offset = CGFloat.zero
    
    @State var isLoading = true
    
    @State private var showAlert: Bool = false
    @State private var errorMess: String = ""
    
    var body: some View {
        NavigationView{
            ZStack{
                ZStack{
                    Color(.white)
                        .ignoresSafeArea()
                    VStack(spacing: 0){
                        Text("aksjhkasjdhkasd")
                        ScrollView(.vertical,showsIndicators: false){
                            VStack(spacing: 10) {
                                
                                // Pass the converted array to BannerSlider
//                                if !appData.bannerImages.isEmpty {
//                                    if isLoading{
//                                        homeSliderShimmer()
//                                    } else{
//                                        BannerSlider(bannerSlider: appData.bannerImages)
//                                            .padding(.top, -2)
//                                    }
//                                }
//                                if !appData.productsBestseller.isEmpty {
//                                    ProductsSlider(isLoading: $isLoading, products: appData.productsBestseller)
//                                        .environmentObject(settings)
//                                }
//                                if !appData.newForYouImages.isEmpty {
//                                    newForYouGifSlider(isLoading: $isLoading, arr: appData.newForYouImages)
//                                        .environmentObject(settings)
//                                }
                            }
                            .background(GeometryReader {
                                Color.clear.preference(key: ViewOffsetKey.self,
                                                       value: -$0.frame(in: .named("scroll")).origin.y)
                            })
                            .onPreferenceChange(ViewOffsetKey.self) {
                                offset = $0
                                if offset > 0{
                                    withAnimation{
                                        showHeader = false
                                    }
                                } else{
                                    withAnimation{
                                        showHeader = true
                                    }
                                }
                            }
                            bottomShadowIgnore(count: UIDevice.current.localizedModel == "iPad" ? 7 : settings.cart_count == 0 ? 2 : 5)
                        }
                        .refreshable {
//                            loadData()
                        }
                        .coordinateSpace(name: "scroll")
                        .background(.white)
                    }
                    .onTapGesture {
                        hideKeyboard()
                    }
                }
            }
        }
        .id(settings.resetNavigationID)
        .onChange(of: settings.resetNavigationID) { newID in
//            loadData()
        }
//        .sheet(isPresented: $showOrderInfo) {
//            OrderInfo(order: $reviewOrderData)
//                .presentationSizingPage()
//        }
//        .fullScreenCover(isPresented: $showBonusInfoSheet) {
//            ZStack {
//                Color(.black)
//                    .opacity(0.5)
//                    .onTapGesture {
//                        showBonusInfoSheet = false
//                    }
//                BonusInfoSheet(bonusInfo: appData.bonusInfo ?? [])
//                    .presentationSizingPage()
//            }
//            .ignoresSafeArea(.all)
//            .clearModalBackground()
//        }
        .transaction({ transaction in
            transaction.disablesAnimations = true
        })
        //        .sheet(isPresented: $showBonusInfoSheet) {
        //            BonusInfoSheet(bonusInfo: appData.bonusInfo ?? [])
        //                .presentationSizingPage()
        //                .clearModalBackground()
        //        }
//        .onAppear{
//            //            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//            //                testIdram()
//            //            }
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                loadData()
//                isLoading = false
//            }
//        }
//        .overlay(showAlert ? errorDialog : nil)
//        .onReceive(NotificationCenter.default.publisher(for: .reloadHome)) { notification in
//            loadData()
//        }
//        
        .navigationBarHidden(true)
    }
    private var errorDialog: some View {
        CustomDialog(isActive: $showAlert, icone_type: 0, title: getLocalString(string: "wrond_command"), message: errorMess, buttonTitle: "", padd: 50) {
        }
    }
    
//    func loadData(){
//        isLoading = true
//        //        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//        appData.getData { data in
//            if let data = data {
//                if data.status == 501{
//                    handleLogout(settings: settings)
//                } else{
//                    appData.updateData(data)
//                    DispatchQueue.main.async {
//                        settings.cart_count = data.cart?.count ?? 0 // Update settings accordingly
//                        UserSettings.shared.cart_count = settings.cart_count
//                    }
//                }
//            } else {
//                print("Failed to fetch app data.")
//            }
//            isLoading = false
//        }
//        userData.getUser { data in
//            if let data = data {
//                userData.updateUserData(data)
//            } else {
//                print("Failed to fetch user data.")
//            }
//            isLoading = false
//        }
//        //        }
//        
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            if let ongoingOrder = appData.ongoingOrder?.first {
//                print("Timer start")
//                startTimer(ongoingOrder.id) // Pass the ongoingOrder.id to the startTimer function
//            } else {
//                print("Timer error: No ongoing order found.")
//            }
//        }
//    }
    
//    func testIdram(){
////        Idram test from home page
//        IdramPaymentManager.pay(withReceiverName: "Gotcha",
//                            receiverId: "110000639",
//                            title: "hKHWTaxaz5am32dFAqcMfhC8U5",
//                            amount: NSNumber(10),
//                            hasTip: false,
//                            callbackURLScheme: "gotcha://reorder")
//        ShowCustomDialog("error", "Idram testing", 0, settings: settings)
//        
//        var paymentUrlString = "idramapp://payment/?receiverName=Gotcha&receiverId=110000639&title=hKHWTaxaz5am32dFAqcMfhC8U5&amount=10"
////        Idram test from home page
//    }
}

struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}


struct accountIcon: View {
    var image: String
    var settings: UserSettings
    var body: some View {
        NavigationLink(
            destination:
                HomeView()
                .environmentObject(settings)
        ) {
            Group {
                if !image.isEmpty {
                    WebImage(url: URL(string: image))
                        .resizable()
                } else {
                    Image("ic-user")
                        .resizable()
                        .frame(width: 28, height: 28)
                }
            }
            .aspectRatio(contentMode: .fill)
            .frame(width: 28, height: 28)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.gray.opacity(0.4), lineWidth: 1))
        }
    }
}

struct processingCapsule: View{
    @Binding var active: Bool
    var body: some View{
        Capsule().fill(Color(UIColor(named: active ? "ColorPrimary" : "LightGray")!))
            .frame(height: 2)
    }
}
