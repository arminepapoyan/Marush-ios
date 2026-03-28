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
                    AddToCartControl(
                        product: product,
                        addToCart: { product, completion in
                            AddToCart(data: ProductAddToCart(productID: product.id, count: 1)) { success in
                                completion(success != nil)
                            }
                        },
                        updateQuantity: { product, quantity in
                            AddToCart(data: ProductAddToCart(productID: product.id, count: quantity)) { _ in }
                        }
                    )
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
    var addToCart: (Product, @escaping (Bool) -> Void) -> Void
    var updateQuantity: (Product, Int) -> Void
    @ObservedObject private var cartManager = CartManager.shared
    @State private var isLoading: Bool = false

    private var quantity: Int {
        cartManager.count(for: product.id)
    }

    var body: some View {
        ZStack {
            if quantity > 0 {
                stepperView
            } else {
                HStack {
                    Spacer()
                    cartButton
                        .padding(.trailing, 10)
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: quantity)
    }
}


private extension AddToCartControl {
    
    var cartButton: some View {
        Button {
            isLoading = true
            addToCart(product) { success in
                isLoading = false
                if success {
                    CartManager.shared.setCount(1, for: product.id)
                }
            }
        } label: {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 44, height: 44)
                
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.7)
                } else {
                    Image("ic-basket")
                        .renderingMode(.template)
                        .foregroundColor(.black)
                }
            }
        }
    }
    var stepperView: some View {
        HStack(spacing: 12) {
            Button {
                let newCount = quantity - 1
                CartManager.shared.setCount(newCount, for: product.id)
                updateQuantity(product, newCount)
            } label: {
                Image(systemName: "minus")
                    .font(.system(size: 16, weight: .medium))
                    .frame(width: 30)
                    .foregroundColor(Color(UIColor(named: "ColorDark")!))
            }

            Text("\(quantity)")
                .font(.LatoBold(size: 14))
                .frame(minWidth: 30)

            Button {
                let newCount = quantity + 1
                CartManager.shared.setCount(newCount, for: product.id)
                updateQuantity(product, newCount)
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .medium))
                    .frame(width: 30)
                    .foregroundColor(Color(UIColor(named: "ColorDark")!))
            }
        }
        .frame(height: 40)
//        .padding(.horizontal, 10)
        .background(Color.white)
        .cornerRadius(8)
    }

}
