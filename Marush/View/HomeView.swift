

import SwiftUI
//import IdramMerchantPayment
import SDWebImageSwiftUI
//import Lottie

struct HomeView: View {
    @EnvironmentObject var userData: UserViewModel
    @EnvironmentObject var settings: UserSettings
    @EnvironmentObject var appData: AppDataViewModel
    
    let horizontalPadding = GlobalSettings.shared.horizontalPadding
    
    @State var isLoading = true
    
    @State private var showAlert: Bool = false
    @State private var errorMess: String = ""
    
    @State private var selectedCategory: Category? = nil
    @State private var searchText = ""
    
    var body: some View {
        NavigationView{
            ZStack(alignment: .top) {
                Color(UIColor(named: "CEF0F7")!)
                    .frame(height: UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0)
                    .ignoresSafeArea(edges: .top)
                VStack(spacing: 0){
                    ScrollView(.vertical,showsIndicators: false){
                        GreetingView(isLoading: $isLoading, searchText: $searchText, name: userData.name, phone: appData.phone ?? "", horizontalPadding: horizontalPadding, settings: settings)
                        VStack(spacing: 20) {
                            categoriesSlider
                            
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
                        .padding(.vertical, 25)
                        .padding(.horizontal, horizontalPadding)
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
        .id(settings.resetNavigationID)
        .onChange(of: settings.resetNavigationID) { newID in
            loadData()
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
        .onReceive(NotificationCenter.default.publisher(for: .reloadHome)) { notification in
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
        userData.getUser { data in
            if let data = data {
                userData.updateUserData(data)
            } else {
                print("Failed to fetch user data.")
            }
            isLoading = false
        }
    }
    
    public var categoriesSlider: some View{
        VStack(spacing: 16) {
            HStack {
                Text("all_categories")
                    .font(.Lato(size: 22))
                Spacer()
                Button {
                    // navigate to section list
                } label: {
                    Text("view_all")
                        .font(.LatoBold(size: 15))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .foregroundStyle(.white)
                        .background(
                            Capsule().fill(Color(UIColor(named: "ColorPrimary")!))
                        )
                }
            }
            CategoryStrip(
                categories: appData.categories,
                selected: $selectedCategory
            )
        }
    }
}

struct CategoryStrip: View {
    let categories: [Category]
    @Binding var selected: Category?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(categories) { c in
                    CategoryPill(
                        title: c.name,
                        icon: c.appImage ?? "",
                        isSelected: selected == c
                    )
                    .onTapGesture {
                        selected = (selected == c) ? nil : c
                    }
                }
            }
        }
    }
}

struct CategoryPill: View {
    let title: String
    let icon: String
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 8) {
            WebImage(url: URL(string: icon))
                .resizable()
                .scaledToFit()
                .frame(width: 26, height: 26)
                .padding(8)
                .background(
                    Circle().fill(Color(UIColor(named: "F9F9F9")!))
                )

            Text(title)
                .font(.Lato(size: 14))
        }
        .foregroundStyle(Color(UIColor(named: "ColorDark")!))
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            RoundedRectangle(cornerRadius: 50, style: .continuous)
                .fill(isSelected ? Color(UIColor(named: "F3E6B1")!) : Color(.white))
        )
    }
}



struct GreetingView: View {
    @Binding var isLoading : Bool
    @Binding var searchText : String
    var name: String = ""
    var phone: String = ""
    var horizontalPadding: CGFloat = 0
    var settings: UserSettings
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(spacing: 24){
                HStack{
                    VStack(alignment: .leading) {
                        Text("\(getLocalString(string: "hi")) \(name)")
                            .font(.Poppins(size: 14))
                        Text("Saryan street, 21 >")
                            .font(.Poppins(size: 14))
                    }
                    Spacer()
                    CallButton(phone: phone)
                    CircleIcon(imageName: "ic-notifications", badgeCount: 3)
                    
                }
                SearchBar(text: $searchText)
            }
            .padding(.bottom, 10)
            .transition(AnyTransition.opacity.animation(.linear(duration: 0.2)))
            
        }
        .padding(.top, 0)
        .padding(.bottom, 40)
        .padding(.horizontal, horizontalPadding)
        .background(Color(UIColor(named: "CEF0F7")!))
    }
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
