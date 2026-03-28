

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

    @State private var searchText = ""
    @State private var showAllCategories = false

    // Category detail
    @State private var categoryForDetail: Category? = nil
    @State private var showCategoryDetail = false

    // Recreating the ScrollView with a new ID resets its position to 0
    @State private var scrollViewID = UUID()

    // MARK: – Helpers

    /// Find the full Category model (with sub-categories) matching a ProductCategory id.
    private func fullCategory(for productCategory: ProductCategory) -> Category? {
        appData.categories.first(where: { $0.id == productCategory.id })
    }

    /// Open CategoryDetailView for the given Category.
    private func openCategoryDetail(_ cat: Category) {
        categoryForDetail = cat
        scrollViewID = UUID()    // recreate ScrollView at position 0 so GreetingView is visible
        withAnimation(.easeInOut(duration: 0.28)) {
            showCategoryDetail = true
        }
    }

    private func closeCategoryDetail() {
        withAnimation(.easeInOut(duration: 0.28)) {
            showCategoryDetail = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            categoryForDetail = nil
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // ── 1. GreetingView — always first in hierarchy, taps always work ──
                GreetingView(
                    isLoading: $isLoading,
                    searchText: $searchText,
                    name: userData.name,
                    phone: appData.phone ?? "",
                    horizontalPadding: horizontalPadding,
                    settings: settings,
                    context: .home,
                    onSearchTap: {
                        var t = Transaction()
                        t.disablesAnimations = true
                        withTransaction(t) { settings.showSearch = true }
                    }
                )
                .environmentObject(userData)
                .environmentObject(appData)
                .background(Color(UIColor(named: "CEF0F7")!))

                // ── 2. Content card — overlaps GreetingView by 30pt ──
                // Home content and CategoryDetailView live here side by side.
                // No z-index juggling needed — GreetingView is simply above this in the VStack.
                ZStack(alignment: .top) {

                    // Home scroll content
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                            VStack(spacing: 20) {
                                VStack(spacing: 20) {
                                    categoriesSlider
                                    if !appData.productCategories.isEmpty {
                                        ForEach(appData.productCategories) { categoryItem in
                                            VStack(spacing: 10) {
                                                ProductsGrid(
                                                    isLoading: $isLoading,
                                                    title: categoryItem.name,
                                                    products: categoryItem.products,
                                                    onViewAll: {
                                                        if let cat = fullCategory(for: categoryItem) {
                                                            openCategoryDetail(cat)
                                                        }
                                                    }
                                                )
                                                .environmentObject(settings)

                                                if let cat = fullCategory(for: categoryItem),
                                                   let subcats = cat.categories,
                                                   !subcats.isEmpty {
                                                    ScrollView(.horizontal, showsIndicators: false) {
                                                        HStack(spacing: 8) {
                                                            ForEach(subcats) { sub in
                                                                CategoryPill(
                                                                    title: sub.name,
                                                                    icon: sub.appImage ?? "",
                                                                    isSelected: categoryForDetail?.id == sub.id && showCategoryDetail
                                                                )
                                                                .onTapGesture {
                                                                    openCategoryDetail(sub)
                                                                }
                                                            }
                                                        }
                                                        .padding(.horizontal, 2)
                                                    }
                                                }
                                            }
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

                                if !appData.productsBestseller.isEmpty {
                                    ProductsGrid(isLoading: $isLoading, title: getLocalString(string: "bestseller"), products: appData.productsBestseller)
                                        .environmentObject(settings)
                                        .padding(.horizontal, horizontalPadding)
                                }

                                if !appData.productsBestseller.isEmpty {
                                    ProductsGrid(isLoading: $isLoading, title: getLocalString(string: "bestseller"), products: appData.productsBestseller)
                                        .environmentObject(settings)
                                        .padding(.horizontal, horizontalPadding)
                                }

                                SubscriptionHero(
                                    titleTop: "Subscribe for your",
                                    planTitle: "Monthly",
                                    titleBottom: "sweet box!"
                                )

                                if !appData.productsNews.isEmpty {
                                    ProductsGrid(isLoading: $isLoading, title: getLocalString(string: "new_in"), products: appData.productsNews)
                                        .environmentObject(settings)
                                        .padding(.horizontal, horizontalPadding)
                                }
                            }
                            .padding(.vertical, 25)

                            bottomShadowIgnore(count: UIDevice.current.localizedModel == "iPad" ? 7 : settings.cart_count == 0 ? 2 : 5)
                        }
                    }
                    .id(scrollViewID)
                    .refreshable { loadData() }

                    // CategoryDetailView slides in over home content
                    if showCategoryDetail, let cat = categoryForDetail {
                        CategoryDetailView(
                            category: cat,
                            onDismiss: { closeCategoryDetail() },
                            onCategoryTap: { newCat in categoryForDetail = newCat }
                        )
                        .id(cat.id)
                        .environmentObject(settings)
                        .environmentObject(userData)
                        .environmentObject(appData)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .trailing)
                        ))
                        .zIndex(1)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(UIColor(named: "F9F9F9")!))
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .padding(.top, -30)   // overlap GreetingView by 30pt
            }
            .background(Color(UIColor(named: "CEF0F7")!).ignoresSafeArea())
            .onTapGesture { hideKeyboard() }
        }
        .id(settings.resetNavigationID)
        .onChange(of: settings.resetNavigationID) { newID in
            // Home tab was re-tapped: dismiss overlays and reload
            var t = Transaction()
            t.disablesAnimations = true
            withTransaction(t) { settings.showSearch = false }
            if showCategoryDetail {
                showCategoryDetail = false
                categoryForDetail = nil
            }
            loadData()
        }
        .sheet(isPresented: $showAllCategories) {
            AllCategoriesSheet(categories: appData.categories) { category in
                withAnimation {
                    showAllCategories = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    openCategoryDetail(category)
                }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
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
        .overlay(
            Group {
                if settings.showSearch {
                    SearchView(onDismiss: {
                        var t = Transaction()
                        t.disablesAnimations = true
                        withTransaction(t) { settings.showSearch = false }
                    })
                    .environmentObject(settings)
                    .environmentObject(userData)
                    .environmentObject(appData)
                    .transition(.identity)
                }
            }
        )
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
    
    private var categoriesSlider: some View {
        VStack(spacing: 16) {
            SectionHeader(
                title: getLocalString(string: "all_categories"),
                fontSize: 20
            ) {
                showAllCategories = true
            }
            CategoryStrip(
                categories: appData.categories,
                selected: Binding(
                    get: { showCategoryDetail ? categoryForDetail : nil },
                    set: { _ in }
                ),
                onCategoryTap: { cat in
                    openCategoryDetail(cat)
                }
            )
        }
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
    /// When set, tapping a pill fires this callback instead of toggling `selected`.
    var onCategoryTap: ((Category) -> Void)? = nil

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(categories) { c in
                    CategoryPill(
                        title: c.name,
                        icon: c.appImage ?? "",
                        isSelected: selected?.id == c.id
                    )
                    .onTapGesture {
                        if let handler = onCategoryTap {
                            handler(c)
                        } else {
                            selected = (selected?.id == c.id) ? nil : c
                        }
                    }
                }
            }
            .padding(.horizontal, 2) // prevent pill shadow clipping
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
