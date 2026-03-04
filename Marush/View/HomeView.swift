

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
                            VStack(spacing: 20){
                                categoriesSlider
                                if !appData.productCategories.isEmpty{
                                    ForEach(appData.productCategories) { categoryItem in
                                        ProductsGrid(isLoading: $isLoading, cart: appData.cart,title: categoryItem.name,products: categoryItem.products)
                                            .environmentObject(settings)
                                    }
                                }
                            }
                            .padding(.horizontal, horizontalPadding)
                            BrandBenefitsCard(
                                benefits: [
                                    ("Natural ingredients", "ic-benefit-1"),
                                    ("Qualified specialists", "ic-benefit-2"),
                                    ("Professional service", "ic-benefit-3")
                                ]
                            )
                            SeasonalBanner(
                                title: "Christmas is coming 🎄🎄",
                                buttonTitle: getLocalString(string: "view_all")
                            )
                            .padding(.top, -20)
                            
                            if !appData.productsBestseller.isEmpty{
                                ProductsGrid(isLoading: $isLoading, cart: appData.cart, title: getLocalString(string: "bestseller"), products: appData.productsBestseller)
                                    .environmentObject(settings)
                                    .padding(.horizontal, horizontalPadding)
                            }
                            
                            if !appData.productsBestseller.isEmpty{
                                ProductsGrid(isLoading: $isLoading, cart: appData.cart, title: getLocalString(string: "bestseller"), products: appData.productsBestseller)
                                    .environmentObject(settings)
                                    .padding(.horizontal, horizontalPadding)
                            }
                            
                            SubscriptionHero(
                                titleTop: "Subscribe for your",
                                planTitle: "Monthly",
                                titleBottom: "sweet box!"
                            )

                            if !appData.productsNews.isEmpty{
                                ProductsGrid(isLoading: $isLoading, cart: appData.cart, title: getLocalString(string: "new_in"), products: appData.productsNews)
                                    .environmentObject(settings)
                                    .padding(.horizontal, horizontalPadding)
                            }
                            
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
            SectionHeader(
                title: getLocalString(string: "all_categories"),
                fontSize: 22
            ) {
                print("All categories is clicked")
            }
            CategoryStrip(
                categories: appData.categories,
                selected: $selectedCategory
            )
        }
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
struct BrandBenefitsCard: View {
    let benefits: [(String, String)]

    var body: some View {
        ZStack {
            VStack(spacing: 70) {
                VStack(spacing: 15){
                    Text("Pastry shop by")
                        .font(.Lato(size: 26))
                        .foregroundStyle(.white)
                    
                    Image("Marush")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150)
                }
                
                VStack(alignment: .leading, spacing: 80) {
                    ForEach(benefits.indices, id: \.self) { i in
                        HStack(alignment: .bottom, spacing: 10) {
//                            Image(benefits[i].1)
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 120)
                            AnimatedBenefitIcon(
                                imageName: benefits[i].1,
                                type: animationType(for: i)
                            )
                                .frame(width: 120)
                            Text(benefits[i].0)
                                .font(.LatoBold(size: 18))
                                .foregroundStyle(.white)
                                .padding(.leading, -50)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 50)
        .padding(.bottom, 100)
        .background(Color(UIColor(named: "ColorPrimary")!))
    }
    
    private func animationType(for index: Int) -> BenefitAnimationType {
        switch index {
        case 0:
            return .rotateWithPause
        case 1:
            return .swing180
        case 2:
            return .continuous
        default:
            return .continuous
        }
    }

}
struct SeasonalBanner: View {
    let title: String
    let buttonTitle: String
    
    @State private var animateImages = false

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .center, spacing: 100) {
                VStack(alignment: .center, spacing: 40) {
                    Text(title)
                        .font(.Lato(size: 24))
                    
                    ButtonView(title: buttonTitle){
                        print("Button Clicked")
                    }
                    .frame(width: 160)
                }
                
                seasonalBannerImages
                    .background(
                        GeometryReader { geo in
                            Color.clear
                                .onChange(of: geo.frame(in: .global).minY) { value in
                                    
                                    let screenHeight = UIScreen.main.bounds.height
                                    let triggerPoint = screenHeight * 0.9
                                    
                                    withAnimation(.easeInOut(duration: 1.5)) {
                                        if value < triggerPoint && value > -350 {
                                            animateImages = true
                                        } else {
                                            animateImages = false
                                        }
                                    }
                                }
                        }
                    )
            }
            .padding(.vertical, 80)
            .padding(.horizontal, 35)
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
    }

    
    private var seasonalBannerImages: some View{
        // Image Stack
        ZStack {
            // Back image (slides in)
            Image("christmas1")
                .resizable()
                .scaledToFill()
                .frame(width: 200 , height: 230)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .offset(x: animateImages ? -75 : 500, y: animateImages ? 180 : 0)
                .animation(.easeInOut(duration: 1.5), value: animateImages)
            
            // Middle image (main)
            Image("christmas2")
                .resizable()
                .scaledToFill()
                .frame(width: animateImages ? 210 : 320, height: animateImages ? 250 : 380)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .zIndex(1)
            
            // Front bottom image (slides in)
            Image("christmas3")
                .resizable()
                .scaledToFill()
                .frame(width: 200 , height: 230)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .offset(x: animateImages ? 75 : 500, y: animateImages ? -180 : 0)
                .animation(.easeInOut(duration: 1.5).delay(0.15), value: animateImages)
        }
        .frame(height: animateImages ? 450 : 400)
    }
}

struct SubscriptionHero: View {
    let titleTop: String
    let planTitle: String
    let titleBottom: String
    
    @State private var animateImages = true
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                
                // subscribe1 → TOP LEADING
                Image("subscribe1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250)
                    .position(
                        x: animateImages ? 50 : 0,
                        y: animateImages ? 100 : 50
                    )
                
                // subscribe2 → BOTTOM LEADING
                Image("subscribe2")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180)
                    .position(
                        x: animateImages ? 50 : 0,
                        y: animateImages ?  geo.size.height - 150 : geo.size.height
                    )
                    .animation(.easeInOut(duration: 1.5), value: animateImages)
                
                // subscribe3 → RIGHT CENTER
                Image("subscribe3")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200)
                    .position(
                        x: animateImages ? geo.size.width - 20 : geo.size.width,
                        y: animateImages ?  geo.size.height - 250 : geo.size.height - 200
                    )
                    .offset(x: -10)
                
                
                // Content
                VStack(spacing: 30) {
                    
                    Text(titleTop)
                        .font(.Lato(size: 38))
                        .foregroundColor(Color(UIColor(named: "ColorDark")!))
                        .multilineTextAlignment(.center)
                    
                    Text(planTitle)
                        .font(.LatoBold(size: 20))
                        .foregroundColor(Color(UIColor(named: "F3E6B1")!))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(UIColor(named: "ColorPrimary")!))
                        )
                    
                    Text(titleBottom)
                        .font(.Lato(size: 38))
                        .foregroundColor(Color(UIColor(named: "ColorDark")!))
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .clipped()
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onChange(of: geo.frame(in: .global).minY) { value in
                            
                            let screenHeight = UIScreen.main.bounds.height
                            let triggerPoint = screenHeight * 0.9
                            
                            withAnimation(.easeInOut(duration: 1.5)) {
                                if value < triggerPoint && value > -350 {
                                    animateImages = true
                                } else {
                                    animateImages = false
                                }
                            }
                        }
                }
            )
        }
        .frame(height: UIScreen.main.bounds.height * 4/5)
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
