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

    var onDismiss: (() -> Void)? = nil

    let horizontalPadding = GlobalSettings.shared.horizontalPadding

    @StateObject var productsData = ProductsViewModel()

    @State var isLoading = true
    @State private var searchText = ""
    @State private var searchTask: DispatchWorkItem? = nil

    // 2-column grid layout
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    private var cardWidth: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let spacing: CGFloat = 12
        return (screenWidth - horizontalPadding * 2 - spacing) / 2
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color(UIColor(named: "F9F9F9")!).ignoresSafeArea()
            VStack(spacing: 0) {

                // Fixed search header — always visible, never scrolls away
                GreetingView(
                    isLoading: $isLoading,
                    searchText: $searchText,
                    name: userData.name,
                    phone: appData.phone ?? "",
                    horizontalPadding: horizontalPadding,
                    settings: settings,
                    context: .search,
                    backgroundColor: Color(UIColor(named: "F9F9F9")!),
                    onBack: {
                        var t = Transaction()
                        t.disablesAnimations = true
                        withTransaction(t) { onDismiss?() }
                    }
                )

                // Scrollable products below the header
                ScrollView(.vertical, showsIndicators: false) {
                    if isLoading && productsData.products.isEmpty {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.top, 60)
                    } else if !isLoading && productsData.products.isEmpty {
                        // Empty state
                        VStack(spacing: 16) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 48, weight: .light))
                                .foregroundColor(Color(UIColor(named: "ColorDark")!).opacity(0.25))
                            Text(getLocalString(string: "product_not_found"))
                                .font(.LatoBold(size: 18))
                                .foregroundColor(Color(UIColor(named: "ColorDark")!).opacity(0.5))
                            if !searchText.isEmpty {
                                Text("\"\(searchText)\"")
                                    .font(.Lato(size: 15))
                                    .foregroundColor(Color(UIColor(named: "ColorDark")!).opacity(0.35))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, horizontalPadding)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 80)
                    } else {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(productsData.products) { product in
                                ProductCard(
                                    isLoading: $isLoading,
                                    product: product,
                                    width: cardWidth
                                )
                                .onTapGesture {
                                    settings.dialogProducId = product.id
                                    settings.showProductDialog = true
                                }
                            }
                        }
                        .padding(.horizontal, horizontalPadding)
                        .padding(.top, 12)
                        .padding(.bottom, 25)
                    }
                    bottomShadowIgnore(count: UIDevice.current.localizedModel == "iPad" ? 7 : settings.cart_count == 0 ? 2 : 5)
                }
                .refreshable {
                    runSearch(query: searchText)
                }
                .coordinateSpace(name: "searchScroll")
            }
        }
        .simultaneousGesture(
            TapGesture().onEnded { hideKeyboard() }
        )
        // Debounced search on every keystroke
        .onChange(of: searchText) { newValue in
            searchTask?.cancel()
            let task = DispatchWorkItem {
                isLoading = true
                productsData.loadData(search: newValue) {
                    isLoading = false
                }
            }
            searchTask = task
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: task)
        }
        .onAppear {
            isLoading = true
            productsData.loadData(search: "") {
                isLoading = false
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .reloadSearchView)) { _ in
            runSearch(query: searchText)
        }
    }

    private func runSearch(query: String) {
        isLoading = true
        productsData.loadData(search: query) {
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
