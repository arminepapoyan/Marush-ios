//
//  CartView.swift
//  Marush
//

import SwiftUI
import SDWebImageSwiftUI

// MARK: - CartView

struct CartView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userData: UserViewModel
    @EnvironmentObject var settings: UserSettings
    @EnvironmentObject var appData: AppDataViewModel

    @StateObject private var cartData = CartViewModel()

    @State private var cartInfo: CartResponse?
    @State private var showAlert = false
    @State private var errorMess = ""
    @State private var isLoading = false

    // Quantities keyed by cartId — source of truth for +/- display
    @State private var localQuantities: [String: Int] = [:]
    // Total from CartResponse.total, kept in sync with every +/- tap
    @State private var localTotal: Double = 0

    // Remove confirmation dialog state (lifted here so dialog is full-screen)
    @State private var itemPendingRemoval: CartItem? = nil
    @State private var showRemoveConfirm = false

    let horizontalPadding = GlobalSettings.shared.horizontalPadding

    private var currentCart: CartResponse? { cartInfo ?? cartData.data }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {

                // ── 1. Greeting strip (address bar, no search) ──────────────────
                GreetingView(
                    isLoading: $isLoading,
                    searchText: .constant(""),
                    name: userData.name,
                    phone: appData.phone ?? "",
                    horizontalPadding: horizontalPadding,
                    settings: settings,
                    backgroundColor: Color(UIColor(named: "F3E6B1")!),
                    showsSearchBar: false
                )
                .environmentObject(userData)
                .environmentObject(appData)
                .background(Color(UIColor(named: "F3E6B1")!))

                // ── 2. Content card ─────────────────────────────────────────────
                VStack(spacing: 0) {
                    cartHeader

                    if let cart = currentCart {
                        if cart.list.isEmpty {
                            CartEmptyView()
                                .environmentObject(settings)
                        } else {
                            cartContent(cart: cart)
                        }
                    } else {
                        Spacer()
                        ProgressView()
                            .tint(Color(UIColor(named: "ColorDark")!))
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(UIColor(named: "F9F9F9")!))
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .padding(.top, -30)
            }
            .background(Color(UIColor(named: "F3E6B1")!).ignoresSafeArea())
            .onTapGesture { hideKeyboard() }
        }
        .navigationBarHidden(true)
        // ── Error overlay ───────────────────────────────────────────────────────
        .overlay(showAlert ? errorDialog : nil)
        // ── Remove confirmation dialog (full-screen overlay) ────────────────────
        .overlay(showRemoveConfirm ? removeConfirmDialog : nil)
        .onAppear {
            cartData.reload()
        }
        .onReceive(cartData.$data) { newData in
            guard let d = newData else { return }
            cartInfo = d
            localTotal = d.total
            syncQuantities(from: d.list)
        }
    }

    // MARK: - Quantity helpers

    /// Seeds/updates localQuantities when the server list arrives.
    /// - Adds new items with their server count.
    /// - Removes entries for items no longer in the cart.
    /// - Preserves any in-flight local changes the user already made.
    private func syncQuantities(from list: [CartItem]) {
        let activeIds = Set(list.map { $0.cartId })
        // Drop quantities for removed items
        localQuantities = localQuantities.filter { activeIds.contains($0.key) }
        // Seed quantities for brand-new items (first load or new additions)
        for item in list where localQuantities[item.cartId] == nil {
            localQuantities[item.cartId] = item.count
        }
    }

    // MARK: - Cart header

    private var cartHeader: some View {
        ZStack {
            HStack {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(UIColor(named: "ColorDark")!))
                        .frame(width: 36, height: 36)
                }
                Spacer()
            }
            Text(getLocalString(string: "cart"))
                .font(.LatoBold(size: 22))
                .foregroundColor(Color(UIColor(named: "ColorDark")!))
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.top, 24)
        .padding(.bottom, 12)
    }

    // MARK: - Cart content (items + bottom bar)

    private func cartContent(cart: CartResponse) -> some View {
        VStack(spacing: 0) {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 12) {
                    ForEach(cart.list) { item in
                        CartItemRow(
                            item: item,
                            // Bind to localQuantities; also delta-update localTotal instantly
                            quantity: Binding(
                                get: { localQuantities[item.cartId] ?? item.count },
                                set: { newValue in
                                    let prev = localQuantities[item.cartId] ?? item.count
                                    localTotal += item.price * Double(newValue - prev)
                                    localQuantities[item.cartId] = newValue
                                }
                            ),
                            onQuantityRevertNeeded: { revertQty in
                                // Called when UpdateCart API fails — roll back quantity + total
                                let current = localQuantities[item.cartId] ?? item.count
                                localTotal += item.price * Double(revertQty - current)
                                localQuantities[item.cartId] = revertQty
                            },
                            onRemoveRequested: { itemToRemove in
                                itemPendingRemoval = itemToRemove
                                showRemoveConfirm = true
                            },
                            showAlert: $showAlert,
                            errorMess: $errorMess
                        )
                    }
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.top, 8)
                .padding(.bottom, 16)

                bottomShadowIgnore(count: UIDevice.current.localizedModel == "iPad" ? 7 : 4)
            }
            .refreshable {
                cartData.reload()
            }

            cartBottomBar
        }
    }

    // MARK: - Bottom total + Next button

    private var cartBottomBar: some View {
        VStack(spacing: 14) {
            HStack {
                Text(getLocalString(string: "total"))
                    .font(.LatoBold(size: 18))
                    .foregroundColor(Color(UIColor(named: "ColorDark")!))
                Spacer()
                // localTotal updates instantly when user taps +/-
                CartAMDPrice(price: localTotal, fontSize: 18, bold: true)
            }
            .padding(.horizontal, horizontalPadding)

            ButtonView(
                title: getLocalString(string: "next"),
                showArrow: false,
                action: { /* TODO: navigate to checkout */ }
            )
            .padding(.horizontal, horizontalPadding)
            .padding(.bottom, 16)
        }
        .padding(.top, 14)
        .background(
            Color.white
                .clipShape(
                    RoundedCornersShape(
                        corners: UIRectCorner([.topLeft, .topRight]),
                        radius: 24
                    )
                )
                .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: -4)
        )
    }

    // MARK: - Remove confirmation dialog

    private var removeConfirmDialog: some View {
        CustomConfirmationDialog(
            isPresented: $showRemoveConfirm,
            title: getLocalString(string: "remove_product"),
            text: itemPendingRemoval?.product.name ?? "",
            confirmButton: getLocalString(string: "remove"),
            cancelButton: getLocalString(string: "cancel"),
            onConfirm: {
                performRemove(item: itemPendingRemoval)
            }
        )
        .transition(.opacity.animation(.easeInOut(duration: 0.2)))
    }

    // MARK: - Remove API call

    private func performRemove(item: CartItem?) {
        guard let item = item else { return }
        let req = RemoveCartData(cart_id: item.cartId, use_bonus_amount: 0)
        RemoveFromCart(data: req) { response in
            DispatchQueue.main.async {
                if let res = response {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        cartInfo = res.cart
                        localTotal = res.cart.total
                        // Sync quantities: removes the deleted item, keeps rest intact
                        syncQuantities(from: res.cart.list)
                        // Keep CartManager in sync so the tab badge reflects unique product count
                        CartManager.shared.load(from: res.cart)
                        // Safe to update badge — RemoveFromCart returns reliable count
                        settings.cart_count = res.cart.count
                    }
                } else {
                    errorMess = getLocalString(string: "wrond_command")
                    showAlert = true
                }
                itemPendingRemoval = nil
            }
        }
    }

    // MARK: - Error overlay

    private var errorDialog: some View {
        CustomDialog(
            isActive: $showAlert,
            icone_type: 0,
            title: getLocalString(string: "wrond_command"),
            message: errorMess,
            buttonTitle: "",
            padd: 50
        ) {}
    }
}

// MARK: - AMD Price

struct CartAMDPrice: View {
    let price: Double
    let fontSize: CGFloat
    var bold: Bool = false

    private var priceInt: Int { Int(price) }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 3) {
            Text("\(priceInt)")
                .font(bold ? .LatoBold(size: fontSize) : .Lato(size: fontSize))
                .foregroundColor(Color(UIColor(named: "ColorDark")!))
            Text("AMD")
                .font(bold ? .LatoBold(size: fontSize - 2) : .Lato(size: fontSize - 2))
                .foregroundColor(Color(UIColor(named: "ColorDark")!).opacity(0.45))
        }
    }
}

// MARK: - CartItemRow

struct CartItemRow: View {
    let item: CartItem

    /// Bound to CartView.localQuantities — mutating this instantly updates the total.
    @Binding var quantity: Int

    /// Called when the UpdateCart API fails so CartView can roll back the binding.
    var onQuantityRevertNeeded: ((Int) -> Void)?
    /// Called when removal is requested; parent shows the confirmation dialog.
    var onRemoveRequested: ((CartItem) -> Void)?

    @Binding var showAlert: Bool
    @Binding var errorMess: String

    @State private var offset: CGFloat = 0
    @State private var isSwiped = false

    /// Snapshot taken just before each optimistic quantity change, used for rollback.
    @State private var prevQuantity: Int = 0

    private let swipeThreshold: CGFloat = 40
    private let maxSwipeOffset: CGFloat = -80

    var totalPrice: Double { item.price * Double(quantity) }

    var body: some View {
        ZStack(alignment: .trailing) {
            // ── Red delete button (stays fixed, behind card) ─────────────────
            deleteBackground

            // ── White card (slides left on swipe) ────────────────────────────
            HStack(spacing: 14) {

                // Product image — swipe gesture attached here
                WebImage(url: URL(string: item.product.image ?? ""))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 72, height: 72)
                    .background(Color(UIColor(named: "F3E6B1")!))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(swipeGesture)

                // Name + per-unit price — swipe gesture attached here too
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.product.name)
                        .font(.LatoBold(size: 15))
                        .foregroundColor(Color(UIColor(named: "ColorDark")!))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    CartAMDPrice(price: item.price, fontSize: 14)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlay(swipeGesture)

                // Quantity stepper + row total — NO gesture overlay (buttons must tap)
                VStack(alignment: .trailing, spacing: 8) {
                    quantityStepper
                    CartAMDPrice(price: totalPrice, fontSize: 15, bold: true)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(Color.white)
            .offset(x: offset)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Swipe gesture (reused on image + text areas)

    private var swipeGesture: some View {
        SwipePanGesture(
            onChanged: { dx in
                if isSwiped {
                    offset = min(max(maxSwipeOffset + dx, maxSwipeOffset), 0)
                } else {
                    offset = dx < 0 ? max(dx, maxSwipeOffset) : 0
                }
            },
            onEnded: { dx in
                if isSwiped {
                    dx > swipeThreshold ? closeSwipe() : openSwipe()
                } else {
                    dx < -swipeThreshold ? openSwipe() : closeSwipe()
                }
            }
        )
    }

    // MARK: - Delete background

    private var deleteBackground: some View {
        Button {
            closeSwipe()
            onRemoveRequested?(item)
        } label: {
            ZStack {
                Color(red: 0.84, green: 0.18, blue: 0.18)
                Image(systemName: "trash")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
            }
            .frame(width: abs(maxSwipeOffset))
            .frame(maxHeight: .infinity)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Quantity stepper

    private var quantityStepper: some View {
        HStack(spacing: 10) {
            Button {
                decreaseQuantity()
            } label: {
                Image(systemName: "minus")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(UIColor(named: "ColorDark")!))
                    .frame(width: 28, height: 28)
                    .overlay(
                        Circle()
                            .stroke(
                                Color(UIColor(named: "ColorDark")!).opacity(0.25),
                                lineWidth: 1.5
                            )
                    )
            }
            .buttonStyle(.plain)

            Text("\(quantity)")
                .font(.LatoBold(size: 16))
                .foregroundColor(Color(UIColor(named: "ColorDark")!))
                .frame(minWidth: 18, alignment: .center)

            Button {
                increaseQuantity()
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(UIColor(named: "ColorDark")!))
                    .frame(width: 28, height: 28)
                    .overlay(
                        Circle()
                            .stroke(
                                Color(UIColor(named: "ColorDark")!).opacity(0.25),
                                lineWidth: 1.5
                            )
                    )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Swipe helpers

    private func openSwipe() {
        withAnimation(.easeInOut(duration: 0.25)) {
            offset = maxSwipeOffset
            isSwiped = true
        }
    }

    private func closeSwipe() {
        withAnimation(.easeInOut(duration: 0.25)) {
            offset = 0
            isSwiped = false
        }
    }

    // MARK: - Quantity actions

    private func decreaseQuantity() {
        if quantity > 1 {
            prevQuantity = quantity        // snapshot for potential rollback
            quantity -= 1                  // optimistic update → localTotal refreshes instantly
            callUpdateCart()
        } else {
            // Would reach 0 — remove instead
            closeSwipe()
            onRemoveRequested?(item)
        }
    }

    private func increaseQuantity() {
        prevQuantity = quantity
        quantity += 1
        callUpdateCart()
    }

    /// Calls the UpdateCart API. On failure rolls back the binding via the callback.
    private func callUpdateCart() {
        let snap = prevQuantity          // capture before async dispatch
        let req = CartUpdate(cart_id: item.cartId, count: quantity, use_bonus_amount: 0)
        UpdateCart(data: req) { response in
            DispatchQueue.main.async {
                if response == nil {
                    // Roll back optimistic update
                    onQuantityRevertNeeded?(snap)
                    errorMess = getLocalString(string: "wrond_command")
                    showAlert = true
                }
                // On success: quantity binding + localTotal are already correct — nothing to do.
                // We deliberately do NOT replace cartInfo here because cart/update may return
                // an incomplete CartResponse (empty list, count = 0) that would break the UI.
            }
        }
    }
}

// MARK: - Empty Cart

struct CartEmptyView: View {
    @EnvironmentObject var settings: UserSettings

    var body: some View {
        VStack(spacing: 14) {
            Spacer()

            Text(getLocalString(string: "your_cart_is_empty"))
                .font(.LatoBold(size: 20))
                .foregroundColor(Color(UIColor(named: "ColorDark")!))
                .multilineTextAlignment(.center)

            Text(getLocalString(string: "want_to_add_something"))
                .font(.Lato(size: 15))
                .foregroundColor(Color(UIColor(named: "ColorDark")!).opacity(0.55))
                .multilineTextAlignment(.center)

            ButtonView(
                title: getLocalString(string: "shop"),
                showArrow: false,
                isFullWidth: false,
                action: { settings.selection = 0 }
            )
            .padding(.horizontal, 60)
            .padding(.top, 6)

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
