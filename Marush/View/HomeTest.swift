//
//  HomeTest.swift
//  Marush
//
//  Created by s2s s2s on 10.02.2026.
//


import SwiftUI

// MARK: - Models

struct Category1: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let icon: String // SF Symbol
}

struct Product1: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    let price: Double
    let oldPrice: Double?
    let imageName: String // Asset name
    var isFavorite: Bool = false
}

// MARK: - Home

struct HomeTestView: View {
    @State private var searchText = ""
    @State private var selectedCategory: Category1? = nil

    @State private var productsBySection: [HomeSection] = HomeSection.mock
    @State private var cart: [UUID: Int] = [:]

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        header

                        SearchBar(text: $searchText)
                            .padding(.horizontal, 16)

                        .padding(.horizontal, 16)

                        VStack(spacing: 18) {
                            ForEach(filteredSections) { section in
//                                SectionBlock(
//                                    title: section.title,
//                                    viewAllTitle: section.viewAllTitle
//                                ) {
//                                    productGrid(products: section.products)
//                                }
                            }

                            // Red brand block (like your screenshot)
//                            BrandBenefitsCard(
//                                brand: "MARRUSH",
//                                benefits: [
//                                    ("Natural ingredients", "leaf"),
//                                    ("Qualified specialists", "checkmark.seal"),
//                                    ("Professional service", "person.2.badge.gearshape")
//                                ]
//                            )
//                            .padding(.horizontal, 16)

                            // Christmas banner + CTA
//                            SeasonalBanner(
//                                title: "Christmas is coming 🎄🎄",
//                                buttonTitle: "View all"
//                            )
//                            .padding(.horizontal, 16)

                            // Big image banner
                            BigImageBanner(imageName: "banner_1")
                                .padding(.horizontal, 16)

                            Spacer(minLength: 30)
                        }
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 90) // room for tab bar
                }

                BottomTabBar()
            }
            .navigationBarHidden(true)
            .background(Color(.systemGroupedBackground))
        }
    }

    // MARK: - UI Pieces

    private var header: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Hi, let’s pick your")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("Sweet box")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.primary)
            }

            Spacer()

            Button {
                // notifications
            } label: {
                ZStack {
                    Circle()
                        .fill(Color(.secondarySystemBackground))
                        .frame(width: 40, height: 40)

                    Image(systemName: "bell")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.primary)
                }
            }
        }
        .padding(.horizontal, 16)
    }

//    private func productGrid(products: [Product1]) -> some View {
//        let cols = [
//            GridItem(.flexible(), spacing: 12),
//            GridItem(.flexible(), spacing: 12)
//        ]
//
//        return LazyVGrid(columns: cols, spacing: 12) {
//            ForEach(products) { product in
//                ProductCard(
//                    product: product,
//                    count: Binding(
//                        get: { cart[product.id] ?? 0 },
//                        set: { cart[product.id] = $0 }
//                    ),
//                    onToggleFavorite: { toggled in
//                        toggleFavorite(productID: product.id, isFav: toggled)
//                    }
//                )
//            }
//        }
//        .padding(.horizontal, 16)
//    }

    private var filteredSections: [HomeSection] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return productsBySection }

        return productsBySection.map { section in
            let filtered = section.products.filter {
                $0.title.lowercased().contains(q) || $0.subtitle.lowercased().contains(q)
            }
            return HomeSection(id: section.id, title: section.title, viewAllTitle: section.viewAllTitle, products: filtered)
        }
        .filter { !$0.products.isEmpty }
    }

    private func toggleFavorite(productID: UUID, isFav: Bool) {
        for i in productsBySection.indices {
            if let j = productsBySection[i].products.firstIndex(where: { $0.id == productID }) {
                productsBySection[i].products[j].isFavorite = isFav
            }
        }
    }
}

// MARK: - Sections

struct HomeSection: Identifiable, Hashable {
    let id: UUID
    let title: String
    let viewAllTitle: String
    var products: [Product1]

    init(id: UUID = UUID(), title: String, viewAllTitle: String = "View all", products: [Product1]) {
        self.id = id
        self.title = title
        self.viewAllTitle = viewAllTitle
        self.products = products
    }

    static let mock: [HomeSection] = [
        .init(title: "All categories", products: Product1.mock),
        .init(title: "Traditional", products: Product1.mock.shuffled()),
        .init(title: "Pastry", products: Product1.mock.shuffled()),
        .init(title: "Cakes", products: Product1.mock.shuffled()),
        .init(title: "Ice Cream", products: Product1.mock.shuffled()),
        .init(title: "Big-big sales", products: Product1.mock.shuffled()),
        .init(title: "New in Marrush", products: Product1.mock.shuffled())
    ]
}

// MARK: - Components
//struct SectionBlock<Content: View>: View {
//    let title: String
//    let viewAllTitle: String
//    @ViewBuilder let content: Content
//
//    var body: some View {
//        VStack(spacing: 12) {
//            HStack {
//                Text(title)
//                    .font(.headline.weight(.semibold))
//                Spacer()
//                Button {
//                    // navigate to section list
//                } label: {
//                    Text(viewAllTitle)
//                        .font(.caption.weight(.semibold))
//                        .foregroundStyle(.white)
//                        .padding(.horizontal, 10)
//                        .padding(.vertical, 7)
//                        .background(
//                            Capsule().fill(Color.red)
//                        )
//                }
//            }
//            .padding(.horizontal, 16)
//
//            content
//        }
//    }
//}

//struct ProductCard: View {
//    @State var product: Product1
//    @Binding var count: Int
//
//    var onToggleFavorite: (Bool) -> Void
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 10) {
//            ZStack(alignment: .topTrailing) {
//                RoundedRectangle(cornerRadius: 16, style: .continuous)
//                    .fill(Color(red: 0.73, green: 0.07, blue: 0.16)) // deep red like screenshot
//                    .frame(height: 150)
//                    .overlay(
//                        Image(product.imageName)
//                            .resizable()
//                            .scaledToFit()
//                            .padding(12)
//                    )
//                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
//
//                Button {
//                    product.isFavorite.toggle()
//                    onToggleFavorite(product.isFavorite)
//                } label: {
//                    ZStack {
//                        Circle()
//                            .fill(Color.white.opacity(0.95))
//                            .frame(width: 30, height: 30)
//                        Image(systemName: product.isFavorite ? "heart.fill" : "heart")
//                            .font(.system(size: 14, weight: .semibold))
//                            .foregroundStyle(product.isFavorite ? Color.red : Color.black)
//                    }
//                }
//                .padding(10)
//            }
//
//            VStack(alignment: .leading, spacing: 4) {
//                Text(product.title)
//                    .font(.subheadline.weight(.semibold))
//                    .lineLimit(1)
//
//                Text(product.subtitle)
//                    .font(.caption)
//                    .foregroundStyle(.secondary)
//                    .lineLimit(1)
//            }
//
//            HStack(alignment: .firstTextBaseline) {
//                Text(priceText(product.price))
//                    .font(.subheadline.weight(.semibold))
//
//                if let old = product.oldPrice, old > product.price {
//                    Text(priceText(old))
//                        .font(.caption.weight(.semibold))
//                        .foregroundStyle(.secondary)
//                        .strikethrough()
//                }
//
//                Spacer()
//            }
//
//            HStack(spacing: 10) {
//                if count == 0 {
//                    Button {
//                        count = 1
//                    } label: {
//                        Text("Add")
//                            .font(.caption.weight(.semibold))
//                            .foregroundStyle(.white)
//                            .padding(.horizontal, 12)
//                            .padding(.vertical, 8)
//                            .background(Capsule().fill(Color.black))
//                    }
//                } else {
//                    StepperControl(count: $count)
//                }
//
//                Spacer(minLength: 0)
//            }
//        }
//        .padding(12)
//        .background(
//            RoundedRectangle(cornerRadius: 18, style: .continuous)
//                .fill(Color(.systemBackground))
//                .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 6)
//        )
//    }
//
//    private func priceText(_ value: Double) -> String {
//        // If you want AMD formatting, replace with NumberFormatter
//        String(format: "%.0f ֏", value)
//    }
//}

struct StepperControl: View {
    @Binding var count: Int

    var body: some View {
        HStack(spacing: 10) {
            Button {
                count = max(0, count - 1)
            } label: {
                Image(systemName: "minus")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 28, height: 28)
                    .background(Circle().fill(Color.black))
            }

            Text("\(count)")
                .font(.caption.weight(.semibold))
                .frame(minWidth: 16)

            Button {
                count += 1
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 28, height: 28)
                    .background(Circle().fill(Color.black))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule().fill(Color(.secondarySystemBackground))
        )
    }
}





struct BigImageBanner: View {
    let imageName: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(.secondarySystemBackground))

            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 170)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
        .frame(height: 170)
        .clipped()
    }
}


struct BottomTabBar: View {
    var body: some View {
        HStack {
            tabItem("house.fill", "Home", isActive: true)
            Spacer()
            tabItem("heart", "Fav", isActive: false)
            Spacer()
            tabItem("cart", "Cart", isActive: false)
            Spacer()
            tabItem("person", "Profile", isActive: false)
        }
        .padding(.horizontal, 22)
        .padding(.top, 12)
        .padding(.bottom, 22)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 18, x: 0, y: -2)
        )
        .padding(.horizontal, 14)
        .padding(.bottom, 10)
    }

    private func tabItem(_ icon: String, _ title: String, isActive: Bool) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
            Text(title)
                .font(.caption2.weight(.semibold))
        }
        .foregroundStyle(isActive ? Color.black : Color.secondary)
    }
}

// MARK: - Mock Data

extension Category1 {
    static let mock: [Category1] = [
        .init(title: "All", icon: "square.grid.2x2"),
        .init(title: "Traditional", icon: "sparkles"),
        .init(title: "Pastry", icon: "birthday.cake"),
        .init(title: "Cakes", icon: "takeoutbag.and.cup.and.straw"),
        .init(title: "Pie", icon: "circle.hexagongrid"),
        .init(title: "Ice Cream", icon: "snowflake")
    ]
}

extension Product1 {
    static let mock: [Product1] = [
        .init(title: "Ice cream", subtitle: "Strawberry", price: 790, oldPrice: 860, imageName: "icecream_1"),
        .init(title: "Ice cream", subtitle: "Vanilla", price: 790, oldPrice: nil, imageName: "icecream_1"),
        .init(title: "Ice cream", subtitle: "Chocolate", price: 790, oldPrice: 860, imageName: "icecream_1"),
        .init(title: "Ice cream", subtitle: "Berry mix", price: 790, oldPrice: nil, imageName: "icecream_1"),
        .init(title: "Ice cream", subtitle: "Pistachio", price: 790, oldPrice: 860, imageName: "icecream_1"),
        .init(title: "Ice cream", subtitle: "Mango", price: 790, oldPrice: nil, imageName: "icecream_1")
    ]
}

// MARK: - Preview

#Preview {
    HomeView()
}
