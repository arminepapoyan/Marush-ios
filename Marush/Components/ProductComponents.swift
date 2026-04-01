//
//  ProductComponents.swift
//  Marush
//
//  Created by s2s s2s on 11.02.2026.
//

import SwiftUI
import SDWebImageSwiftUI

struct ProductsGrid: View {
    @EnvironmentObject var settings: UserSettings
    @Binding var isLoading: Bool
    var title: String = ""
    var backgroundColor: UIColor = .clear
    var products: [Product] = []
    var outline: Bool = true
    var onViewAll: (() -> Void)? = nil
    
    
    private var columns: [GridItem] {
        [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]
    }
    
    
    var body: some View {
        VStack(spacing: 15) {
            SectionHeader(
                title: title,
                fontSize: 18
            ) {
                onViewAll?()
            }
            //            LazyVGrid(columns: columns, spacing: 12) {
            //                ForEach(products) { product in
            //                    ProductCard(
            //                        isLoading: $isLoading,
            //                        product: product,
            //                        outline: outline
            //                    )
            //                    .onTapGesture {
            //                        settings.dialogProducId = product.id
            //                        settings.showProductDialog = true
            //                    }
            //                }
            //            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 16){
                    ForEach(products) { product in
                        ProductCard(isLoading: $isLoading, product: product, outline: outline, width: cardWidth)
                            .onTapGesture {
                                settings.dialogProducId = product.id
                                settings.showProductDialog = true
                            }
                    }
                }
            }
        }
        .padding(.vertical)
        .background(Color(backgroundColor))
    }
    private var cardWidth: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let horizontalPadding = GlobalSettings.shared.horizontalPadding * 2
        let spacing: CGFloat = 16
        return (screenWidth - horizontalPadding - spacing) / 2
    }
}

struct ProductCard: View {
    @Binding var isLoading: Bool
    let product: Product
    var outline: Bool = true
    var width: CGFloat
    
    let maxNameLines: Int = 3 // Maximum lines for product name
    
    var body: some View {
        if isLoading{
            productsSliderItemShimmer()
        } else{
            VStack(alignment: .leading, spacing: 8) {
                ZStack(alignment: .bottom){

                    if let image = product.appImage{
                        WebImage(url: URL(string: image))
                            .resizable()
                            .scaledToFill()
                            .frame(width: width)
                            .frame(height: 200)
                            .clipped()
                    }
//                    CircleIcon(imageName: "ic-basket")
//                        .padding(.trailing, 10)
//                        .padding(.bottom, 5)
                    AddToCartControl(product: product)
//                    .padding(.trailing, 10)
                    .padding(.bottom, 5)

                }
                
                VStack(alignment: .leading, spacing: 5){
                    HStack(spacing: 2){
                        Text("\(roundNumber(product.price))")
                            .font(.LatoBold(size: 14))
                            .foregroundColor(Color(UIColor(named: "ColorDark")!))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        Text("\(getLocalString(string: "dram_sign"))")
                            .font(.Lato(size: 14))
                            .foregroundColor(Color(UIColor(named: "ColorDark")!).opacity(0.4))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    
                    Text(product.name)
                        .font(.Lato(size: 14))
                        .foregroundColor(Color(UIColor(named: "ColorDark")!))
                        .lineLimit(maxNameLines)
                    //                            .frame(height: calculateTextHeight(maxLines: maxNameLines + 1, fontSize: 12)) // Fixed height for alignment
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 15)
            }
            .frame(width: width)
            .background(.white)
            .cornerRadius(10)
            .padding(1)
            .background(outline ? RoundedRectangle(cornerRadius: 10).stroke(Color(UIColor(named: "ColorDark")!).opacity(0.1), lineWidth: 1) : nil)
            
        }
    }
    
    private func calculateTextHeight(maxLines: Int, fontSize: CGFloat) -> CGFloat {
        let lineHeight = UIFont(name: "Lato-Regular", size: fontSize)?.lineHeight ?? fontSize * 1.2
        return lineHeight * CGFloat(maxLines)
    }
}


struct ProductBadge: View {
    let title: String
    let colorHex: String

    var body: some View {
        Text(title)
            .font(.PoppinsBold(size: 12))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Color(hex: colorHex.isEmpty ? "#FF7A00" : colorHex))
            .cornerRadius(20)
            .padding(.top, 6)
            .zIndex(10)
    }
}

struct AddToCartControl: View {
    let product: Product
    @ObservedObject private var cartManager = CartManager.shared
    /// True while the basket-button add + CartManager update is in flight.
    @State private var isAdding: Bool = false
    @State private var showRemoveConfirm: Bool = false

    private var quantity: Int { cartManager.count(for: product.id) }

    var body: some View {
        ZStack {
            if isAdding {
                HStack {
                    Spacer()
                    ProgressView()
                        .scaleEffect(0.8)
                        .frame(width: 44, height: 44)
                        .padding(.trailing, 10)
                }
            } else if quantity > 0 {
                // Full-width stepper — absorbs taps so the parent ProductCard
                // doesn't open ProductDetailView when the user misses a button.
                CartQuantityStepper(
                    quantity: quantity,
                    style: .product,
                    onDecrease: { decreaseQuantity() },
                    onIncrease: { increaseQuantity() }
                )
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 10)
                .contentShape(Rectangle())
                .onTapGesture { }   // absorb stray taps — prevents ProductCard navigation
            } else {
                HStack {
                    Spacer()
                    addButton
                        .padding(.trailing, 10)
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: quantity)
        .animation(.easeInOut(duration: 0.15), value: isAdding)
        .overlay(showRemoveConfirm ? removeConfirmOverlay : nil)
    }

    // MARK: - Remove confirmation overlay

    private var removeConfirmOverlay: some View {
        CustomConfirmationDialog(
            isPresented: $showRemoveConfirm,
            title: getLocalString(string: "remove_product"),
            text: product.name,
            confirmButton: getLocalString(string: "remove"),
            cancelButton: getLocalString(string: "cancel"),
            onConfirm: {
                CartManager.shared.setCount(0, for: product.id)
            }
        )
        .transition(.opacity.animation(.easeInOut(duration: 0.2)))
    }

    // MARK: - First-add basket button

    private var addButton: some View {
        Button {
            guard !isAdding else { return }
            isAdding = true
            AddToCart(data: ProductAddToCart(productID: product.id, count: 1)) { result in
                DispatchQueue.main.async {
                    if result != nil {
                        CartManager.shared.setCount(1, for: product.id)
                    }
                    isAdding = false
                }
            }
        } label: {
            ZStack {
                Circle().fill(Color.white).frame(width: 44, height: 44)
                Image("ic-basket").renderingMode(.template).foregroundColor(.black)
            }
        }
    }

    // MARK: - Stepper actions (optimistic + rollback)

    private func decreaseQuantity() {
        let newCount = quantity - 1
        if newCount == 0 {
            // Would reach 0 — ask for confirmation before removing
            showRemoveConfirm = true
            return
        }
        let prev = quantity
        CartManager.shared.setCount(newCount, for: product.id)
        AddToCart(data: ProductAddToCart(productID: product.id, count: newCount)) { result in
            DispatchQueue.main.async {
                if result == nil { CartManager.shared.setCount(prev, for: product.id) }
            }
        }
    }

    private func increaseQuantity() {
        let prev = quantity
        let newCount = quantity + 1
        CartManager.shared.setCount(newCount, for: product.id)
        AddToCart(data: ProductAddToCart(productID: product.id, count: newCount)) { result in
            DispatchQueue.main.async {
                if result == nil { CartManager.shared.setCount(prev, for: product.id) }
            }
        }
    }
}
