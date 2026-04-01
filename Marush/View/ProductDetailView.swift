//
//  ProductDetailView.swift
//  Marush
//
//  Created by s2s s2s on 04.03.2026.
//

import SwiftUI
import SDWebImageSwiftUI

struct ProductDetailView: View {
    @EnvironmentObject var settings: UserSettings
    var productId: String
    @StateObject private var productData: ProductDetailsViewModel

    @State private var quantity: Int = 1

    
    @State var addToCartDisabled: Bool = false
    @State var productTotalAmount: Double = 0
    
    @State private var showAlert: Bool = false
    @State private var errorMess: String = ""
    
    init(productId: String) {
        self.productId = productId
        _productData = StateObject(wrappedValue: ProductDetailsViewModel(productId: productId))
    }
    
    @State var addCartLoading: Bool = false
    @State var addCartConfirm: Bool = false

    var body: some View {
        if let product = productData.productData {
            VStack(spacing: 0){
                HeaderView(title: "", showArrow: false)
                    .padding(.horizontal)
                
                ScrollView(.vertical,showsIndicators: false) {
                    VStack(spacing: 0) {
                        VStack(spacing: 20){
                            productDetails(product: product)
                        }
                        bottomShadowIgnore(count: 3)
                    }
                    .background(GeometryReader { proxy in
                        Color.clear.preference(key: ViewOffsetKey.self, value: -proxy.frame(in: .named("scroll")).origin.y)
                    })
                }
                AddToCartSection(product: product, addCartLoading: $addCartLoading, addCartConfirm: $addCartConfirm,  addToCartDisabled: $addToCartDisabled,  price: $productTotalAmount, showAlert: $showAlert, errorMess: $errorMess)
                    .environmentObject(settings)
            }
            .onAppear{
                productTotalAmount = product.price
            }
            .overlay(showAlert ? errorDialog : nil)
            .navigationBarBackButtonHidden(true)
        }
    }
    
    // Error Dialog Overlay
    private var errorDialog: some View {
        CustomDialog(isActive: $showAlert, icone_type: 0, title: getLocalString(string: "wrond_command"), message: errorMess, buttonTitle: "", padd: 50) {
        }
    }
}
struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

// MARK: - Reusable Components

struct productDetails: View {
    @State var product: Product
    
    @State private var webViewHeight: CGFloat = 0
    @State private var showPlaceholder = true

    var body: some View {
        VStack(spacing: 24){
            ZStack{
//                VStack{
//                    HStack {
//                        Spacer()
//                        Image(systemName: product.inWishlist ? "heart.fill" : "heart")
//                            .font(.title)
//                            .foregroundColor(product.inWishlist ? Color(UIColor(named: "FC474B")!) : .gray)
//                            .onTapGesture {
//                                handleAddToWishlist(
//                                    product: product,
//                                    fromWishlist: false,
//                                    productsArr: .constant([]),
//                                    toggleWishlist: { self.product.inWishlist.toggle() }
//                                )
//                            }
//                           
//                    }
//                    .padding(.horizontal)
//                    Spacer()
//                }
                
                if showPlaceholder {
                    productDetailImageShimmer()
                } else {
                    WebImage(url: URL(string: product.image ?? ""))
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 360)
                        .cornerRadius(15)
                        .clipped()
                }
              
            }
            VStack(alignment: .leading, spacing: 10){
                Text("composition")
                    .font(.Lato(size: 18))
                    .foregroundColor(Color(UIColor(named: "ColorDark")!))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(product.desc)
                    .font(.Lato(size: 16))
                    .foregroundColor(Color(UIColor(named: "ColorDark")!).opacity(0.6))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if let categoryName = product.categoryName{
                    Text("\(getLocalString(string: "category")): \(categoryName)")
                        .font(.Lato(size: 18))
                        .foregroundColor(Color(UIColor(named: "ColorDark")!))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
            }
            .padding(.horizontal, GlobalSettings.shared.horizontalPadding)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                showPlaceholder = false
            }
        }
        
        .padding(.horizontal)
        .padding(.bottom, 0)
    }
}

struct quantityStepper: View {
    @Binding var quantity: Int

    var body: some View {
        HStack {
            Button(action: {
                if quantity > 1 {
                    quantity -= 1
                }
            }) {
                Image(systemName: "minus.circle")
                    .foregroundColor(.black)
                    .font(.title2)
            }

            Text("\(quantity)")
                .padding(.horizontal, 10)

            Button(action: {
                quantity += 1
            }) {
                Image(systemName: "plus.circle")
                    .foregroundColor(.black)
                    .font(.title2)
            }
        }
    }
}

struct AddToCartSection: View {
    @EnvironmentObject var settings: UserSettings
    @Environment(\.dismiss) var dismiss
    var product: Product
    @Binding var addCartLoading: Bool
    @Binding var addCartConfirm: Bool
    @Binding var addToCartDisabled: Bool
    @Binding var price: Double
    @Binding var showAlert: Bool
    @Binding var errorMess: String

    @ObservedObject private var cartManager = CartManager.shared
    @State private var addQuantity: Int = 1

    private var cartCount: Int {
        cartManager.count(for: product.id)
    }

    var body: some View {
        VStack(spacing: 20) {
            Divider()
                .background(Color(UIColor(named: "ColorDark")!).opacity(0.1))
            VStack(spacing: 12) {
                HStack {
                    Text(product.name)
                        .font(.LatoBold(size: 18))
                        .foregroundColor(Color(UIColor(named: "ColorDark")!))
                    Spacer()
                    if addCartLoading {
                        ProgressView()
                            .frame(width: 16, height: 16)
                            .progressViewStyle(CircularProgressViewStyle(tint: .black))
                            .scaleEffect(1)
                    } else {
                        HStack(spacing: 4) {
                            Text("\(roundNumber(price * Double(cartCount > 0 ? cartCount : addQuantity)))")
                                .font(.LatoBold(size: 18))
                                .foregroundColor(Color(UIColor(named: "ColorDark")!))
                            Text("amd")
                                .font(.Lato(size: 18))
                                .foregroundColor(Color(UIColor(named: "ColorDark")!).opacity(0.4))
                        }
                    }
                }

                HStack(spacing: 16) {
                    if product.outOfStock {
                        Text("out_of_stock")
                            .font(.Lato(size: 16))
                            .foregroundColor(Color(UIColor(named: "CustomRed")!))
                    } else if cartCount > 0 {
                        // Already in cart — show inline stepper
                        HStack(spacing: 12) {
                            Button {
                                let newCount = cartCount - 1
                                CartManager.shared.setCount(newCount, for: product.id)
                                if newCount > 0 {
                                    AddToCart(data: ProductAddToCart(productID: product.id, count: newCount)) { _ in }
                                }
                            } label: {
                                Image(systemName: "minus")
                                    .font(.system(size: 16, weight: .medium))
                                    .frame(width: 44, height: 44)
                                    .foregroundColor(Color(UIColor(named: "ColorDark")!))
                            }

                            Text("\(cartCount)")
                                .font(.LatoBold(size: 16))
                                .frame(minWidth: 30, alignment: .center)

                            Button {
                                let newCount = cartCount + 1
                                CartManager.shared.setCount(newCount, for: product.id)
                                AddToCart(data: ProductAddToCart(productID: product.id, count: newCount)) { _ in }
                            } label: {
                                Image(systemName: "plus")
                                    .font(.system(size: 16, weight: .medium))
                                    .frame(width: 44, height: 44)
                                    .foregroundColor(Color(UIColor(named: "ColorDark")!))
                            }
                        }
                        .frame(height: 44)
                        .padding(.horizontal, 8)
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(UIColor(named: "ColorDark")!).opacity(0.15), lineWidth: 1))
                    } else {
                        // Not in cart yet — show quantity picker + Add button
                        QuantityChanger(quantity: $addQuantity)
                        ButtonViewConfirmation(
                            showLoading: $addCartLoading,
                            isDisabled: $addToCartDisabled,
                            showConfirm: $addCartConfirm,
                            title: getLocalString(string: "add")
                        ) {
                            addCartLoading = true
                            AddToCart(data: ProductAddToCart(productID: product.id, count: addQuantity)) { response in
                                addCartLoading = false
                                if response?.status == 200 {
                                    CartManager.shared.setCount(addQuantity, for: product.id)
                                    addCartConfirm = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        addCartConfirm = false
                                    }
                                } else {
                                    errorMess = getLocalString(string: "wrond_command")
                                    showAlert = true
                                }
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
        }
        .animation(.easeInOut(duration: 0.2), value: cartCount)
        .padding(.horizontal, GlobalSettings.shared.horizontalPadding)
    }
}

func handleAddToWishlist(
    product: Product,
    fromWishlist: Bool,
    productsArr: Binding<[Product]>,
    toggleWishlist: @escaping () -> Void
) {
    AddToWishlist(productId: product.id) { response in
        if let status = response?.status {
            switch status {
            case 200:
                if fromWishlist {
                    withAnimation {
                        if let index = productsArr.wrappedValue.firstIndex(where: { $0.id == product.id }) {
                            productsArr.wrappedValue.remove(at: index)
                        }
                    }
                }
                toggleWishlist()
            default:
                print("Error adding to wishlist")
            }
        }
    }
}
