//
//  CategoryDetailView.swift
//  Marush
//

import SwiftUI
import SDWebImageSwiftUI

// MARK: - Category Detail View

struct CategoryDetailView: View {
    @EnvironmentObject var settings: UserSettings
    @EnvironmentObject var userData: UserViewModel
    @EnvironmentObject var appData: AppDataViewModel

    let category: Category
    var onDismiss: (() -> Void)? = nil
    /// Called when the user taps a different top-level category in the slider.
    var onCategoryTap: ((Category) -> Void)? = nil

    @StateObject private var productsData = ProductsViewModel()
    @State private var isLoading = true
    @State private var selectedSubcategory: Category? = nil
    @State private var selectedOrderBy: String? = nil
    @State private var showFilterSheet = false
    @State private var showAllCategories = false

    let horizontalPadding = GlobalSettings.shared.horizontalPadding

    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    private var cardWidth: CGFloat {
        (UIScreen.main.bounds.width - horizontalPadding * 2 - 12) / 2
    }

    private var subcategories: [Category] {
        category.categories ?? []
    }

    var body: some View {
        VStack(spacing: 0) {
            headerBar

            if !subcategories.isEmpty {
                CategoryStrip(
                    categories: subcategories,
                    selected: $selectedSubcategory
                )
                .padding(.horizontal, horizontalPadding - 2)
                .padding(.vertical, 12)
                .onChange(of: selectedSubcategory) { _ in
                    loadProducts()
                }
            }

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    // ── All-categories slider (same as HomeView) ──
                    VStack(spacing: 16) {
                        SectionHeader(
                            title: getLocalString(string: "all_categories"),
                            fontSize: 20
                        ) {
                            showAllCategories = true
                        }
                        CategoryStrip(
                            categories: appData.categories,
                            selected: Binding(get: { category as Category? }, set: { _ in }),
                            onCategoryTap: { cat in onCategoryTap?(cat) }
                        )
                    }
                    .padding(.horizontal, horizontalPadding)
                    .padding(.top, 16)
                    .padding(.bottom, 8)

                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.top, 60)
                    } else if productsData.products.isEmpty {
                        emptyState
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
                        .padding(.top, 16)
                        .padding(.bottom, 25)
                    }
                    bottomShadowIgnore(count: settings.cart_count == 0 ? 2 : 5)
                }
            }
            .refreshable { loadProducts() }
        }
        .background(Color(UIColor(named: "F9F9F9")!))
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .sheet(isPresented: $showFilterSheet) {
            CategoryFilterSheet(selectedOrderBy: $selectedOrderBy) {
                loadProducts()
            }
            .presentationDetents([.height(420), .large])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showAllCategories) {
            AllCategoriesSheet(categories: appData.categories) { selected in
                withAnimation { showAllCategories = false }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    onCategoryTap?(selected)
                }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .onAppear { loadProducts() }
    }

    // MARK: – Header bar

    private var headerBar: some View {
        HStack(spacing: 0) {
            Button {
                onDismiss?()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(UIColor(named: "ColorDark")!))
                    .frame(width: 44, height: 44)
            }

            Spacer()

            Text(category.name)
                .font(.LatoBold(size: 18))
                .foregroundColor(Color(UIColor(named: "ColorDark")!))
                .lineLimit(1)

            Spacer()

            Button {
                showFilterSheet = true
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 18))
                        .foregroundColor(Color(UIColor(named: "ColorDark")!))
                        .frame(width: 44, height: 44)

                    if selectedOrderBy != nil {
                        Circle()
                            .fill(Color(UIColor(named: "ColorPrimary")!))
                            .frame(width: 9, height: 9)
                            .offset(x: -4, y: 8)
                    }
                }
            }
        }
        .padding(.horizontal, horizontalPadding - 4)
        .padding(.vertical, 4)
        .background(Color(UIColor(named: "F9F9F9")!))
    }

    // MARK: – Empty state

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(Color(UIColor(named: "ColorDark")!).opacity(0.25))
            Text(getLocalString(string: "product_not_found"))
                .font(.LatoBold(size: 18))
                .foregroundColor(Color(UIColor(named: "ColorDark")!).opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
        .padding(.bottom, 40)
    }

    // MARK: – Data

    private func loadProducts() {
        isLoading = true
        productsData.loadData(
            categoryId: selectedSubcategory?.id ?? category.id,
            orderBy: selectedOrderBy
        ) {
            isLoading = false
        }
    }
}

// MARK: - Filter / Sort Bottom Sheet

struct CategoryFilterSheet: View {
    @Binding var selectedOrderBy: String?
    var onApply: () -> Void
    @Environment(\.dismiss) var dismiss

    private let options: [(String, String?)] = [
        (getLocalString(string: "default"), nil),
        (getLocalString(string: "price_low_to_high"), "price_asc"),
        (getLocalString(string: "price_high_to_low"), "price_desc"),
        (getLocalString(string: "by_name"), "name_asc"),
        (getLocalString(string: "by_name_desc"), "name_desc")
    ]

    @State private var tempOrderBy: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(getLocalString(string: "filter"))
                .font(.LatoBold(size: 20))
                .foregroundColor(Color(UIColor(named: "ColorDark")!))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 20)
                .padding(.bottom, 8)

            Text(getLocalString(string: "what_do_you_want_to_view_first"))
                .font(.Lato(size: 14))
                .foregroundColor(Color(UIColor(named: "ColorDark")!).opacity(0.55))
                .padding(.horizontal, 24)
                .padding(.bottom, 16)

            Divider()
                .padding(.horizontal, 24)
                .padding(.bottom, 8)

            VStack(spacing: 0) {
                ForEach(options, id: \.0) { option in
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            tempOrderBy = option.1
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Text(option.0)
                                .font(.Lato(size: 16))
                                .foregroundColor(Color(UIColor(named: "ColorDark")!))
                            Spacer()
                            ZStack {
                                Circle()
                                    .stroke(
                                        tempOrderBy == option.1
                                            ? Color(UIColor(named: "ColorPrimary")!)
                                            : Color(UIColor(named: "ColorDark")!).opacity(0.25),
                                        lineWidth: 1.5
                                    )
                                    .frame(width: 22, height: 22)
                                if tempOrderBy == option.1 {
                                    Circle()
                                        .fill(Color(UIColor(named: "ColorPrimary")!))
                                        .frame(width: 13, height: 13)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                    }
                    if option.0 != options.last?.0 {
                        Divider().padding(.leading, 24)
                    }
                }
            }

            Spacer()

            ButtonView(title: getLocalString(string: "filter")) {
                selectedOrderBy = tempOrderBy
                onApply()
                dismiss()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .padding(.top, 30)
        .background(Color(UIColor(named: "F9F9F9")!).ignoresSafeArea())
        .onAppear { tempOrderBy = selectedOrderBy }
    }
}
