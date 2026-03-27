//
//  SearchView.swift
//  Marush
//
//  Created by s2s s2s on 27.03.2026.
//



import SwiftUI
//import IdramMerchantPayment
import SDWebImageSwiftUI
//import Lottie

struct SearchView: View {
    @EnvironmentObject var userData: UserViewModel
    @EnvironmentObject var settings: UserSettings
    @EnvironmentObject var appData: AppDataViewModel
    
    let horizontalPadding = GlobalSettings.shared.horizontalPadding
    
    @StateObject var data = ProductsViewModel()
    
    @State var isLoading = true
    
    @State private var showAlert: Bool = false
    @State private var errorMess: String = ""
    
    @State private var searchText = ""
    
    var body: some View {
        NavigationView{
            ZStack(alignment: .top) {
                VStack(spacing: 0){
                    ScrollView(.vertical,showsIndicators: false){
                        GreetingView(
                            isLoading: $isLoading,
                            searchText: $searchText,
                            name: userData.name,
                            phone: appData.phone ?? "",
                            horizontalPadding: horizontalPadding,
                            settings: settings,
                            context: .search,
                            backgroundColor: Color(UIColor(named: "F9F9F9")!)
                        )
                        VStack(spacing: 20) {
                        }
                        .padding(.vertical, 25)
                        .background(
                            Color(UIColor(named: "F9F9F9")!)
                                .clipShape(
                                    RoundedRectangle(
                                        cornerRadius: 30,
                                        style: .continuous
                                    )
                                )
                        )
                        .offset(y: -25)
                        bottomShadowIgnore(count: UIDevice.current.localizedModel == "iPad" ? 7 : settings.cart_count == 0 ? 2 : 5)
                    }
                    .refreshable {
                        loadData()
                    }
                    .coordinateSpace(name: "scroll")
                }
                .onTapGesture {
                    hideKeyboard()
                }
            }
        }
        .onChange(of: settings.resetNavigationID) { newID in
            loadData()
        }
        .onAppear{
            //            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            //                testIdram()
            //            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                loadData()
                isLoading = false
            }
        }
        //        .overlay(showAlert ? errorDialog : nil)
        .onReceive(NotificationCenter.default.publisher(for: .reloadSearchView)) { notification in
            loadData()
        }
        
        .navigationBarHidden(true)
    }
    private var errorDialog: some View {
        CustomDialog(isActive: $showAlert, icone_type: 0, title: getLocalString(string: "wrond_command"), message: errorMess, buttonTitle: "", padd: 50) {
        }
    }
    
    func loadData(){
        isLoading = true
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        appData.getData { data in
            if let data = data {
                if data.status == 501{
                    handleLogout(settings: settings)
                } else{
                    appData.updateData(data)
                    DispatchQueue.main.async {
                        settings.cart_count = data.cart?.count ?? 0 // Update settings accordingly
                        UserSettings.shared.cart_count = settings.cart_count
                    }
                }
            } else {
                print("Failed to fetch app data.")
            }
            isLoading = false
        }
    }
}

//#Preview {
//    SubscriptionHero(
//        titleTop: "Enjoy Unlimited",
//        planTitle: "PREMIUM PLAN",
//        titleBottom: "Fresh Flowers"
//    )
//}
//struct ViewOffsetKey: PreferenceKey {
//    typealias Value = CGFloat
//    static var defaultValue = CGFloat.zero
//    static func reduce(value: inout Value, nextValue: () -> Value) {
//        value += nextValue()
//    }
//}
