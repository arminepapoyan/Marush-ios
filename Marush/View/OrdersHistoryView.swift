//
//  OrdersHistoryView.swift
//  Marush
//

import SwiftUI
import Shimmer
import SDWebImageSwiftUI

// MARK: - OrdersHistoryView

struct OrdersHistoryView: View {
    @EnvironmentObject var userData: UserViewModel
    @EnvironmentObject var settings: UserSettings
    @EnvironmentObject var appData: AppDataViewModel

    @StateObject private var ordersVM = OrdersViewModel()
    @State private var isLoading      = true
    @State private var selectedTab    = 0
    @State private var showOrderView  = false
    @State private var selectedOrder: Order? = nil
    @State private var showAlert      = false
    @State private var errorMess      = ""

    // MARK: - Filtered orders per tab

    private var filteredOrders: [Order] {
        switch selectedTab {
        case 0:  return ordersVM.data.filter { !($0.isFinished ?? false) && !($0.isCancelled ?? false) }
        case 1:  return ordersVM.data.filter {  ($0.isFinished ?? false) }
        case 2:  return ordersVM.data.filter {  ($0.isCancelled ?? false) }
        default: return []
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color(UIColor(named: "F3E6B1")!).ignoresSafeArea()

            VStack(spacing: 0) {
                // ── GreetingView — yellow header ──────────────────────────────
                GreetingView(
                    isLoading: .constant(false),
                    searchText: .constant(""),
                    name: userData.name,
                    phone: appData.phone ?? "",
                    horizontalPadding: GlobalSettings.shared.horizontalPadding,
                    settings: settings,
                    backgroundColor: Color(UIColor(named: "F3E6B1")!),
                    showsSearchBar: false
                )
                .environmentObject(userData)
                .environmentObject(appData)

                // ── White content card (ZStack so OrderInfo can slide in) ─────
                ZStack(alignment: .top) {

                    // Main list
                    VStack(spacing: 0) {
                        Text(getLocalString(string: "my_orders"))
                            .font(.LatoBold(size: 26))
                            .foregroundColor(Color(UIColor(named: "ColorDark")!))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, GlobalSettings.shared.horizontalPadding)
                            .padding(.top, 24)
                            .padding(.bottom, 16)

                        tabRow
                            .padding(.bottom, 16)

                        if isLoading {
                            shimmerList
                        } else if filteredOrders.isEmpty {
                            emptyState
                        } else {
                            orderList
                        }
                    }
                    

                    // OrderInfo slides in from trailing edge
                    if showOrderView, let order = selectedOrder {
                        OrderInfo(order: order) {
                            withAnimation(.easeInOut(duration: 0.28)) {
                                showOrderView = false
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                selectedOrder = nil
                            }
                        }
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal:   .move(edge: .trailing)
                        ))
                        .zIndex(1)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(UIColor(named: "F9F9F9")!))
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .padding(.top, -30)
            }
        }
        .onAppear { loadData() }
        .overlay(showAlert ? errorDialog : nil)
    }

    // MARK: - Tab row

    private var tabRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                tabButton(index: 0, title: getLocalString(string: "active"),    icon: "ic-active")
                tabButton(index: 1, title: getLocalString(string: "completed"), icon: "ic-completed")
                tabButton(index: 2, title: getLocalString(string: "canceled"),  icon: "ic-canceled")
            }
            .padding(.horizontal, GlobalSettings.shared.horizontalPadding)
        }
    }

    private func tabButton(index: Int, title: String, icon: String) -> some View {
        let isSelected = selectedTab == index
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) { selectedTab = index }
        } label: {
            HStack(spacing: 8) {
                // Icon with gray circle background
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .padding(6)
                    .background(
                        Circle()
                            .fill(isSelected
                                  ? Color.white.opacity(0.6)
                                  : Color.gray.opacity(0.12))
                    )
                Text(title)
                    .font(isSelected ? .LatoBold(size: 14) : .Lato(size: 14))
                    .foregroundColor(Color(UIColor(named: "ColorDark")!))
                    .fixedSize()          // keep full text — no truncation
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected
                          ? Color(UIColor(named: "F3E6B1")!)
                          : Color.white)
            )
            .overlay(
                Capsule()
                    .stroke(isSelected
                            ? Color(UIColor(named: "F3E6B1")!)
                            : Color.gray.opacity(0.2),
                            lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Order list

    private var orderList: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 12) {
                ForEach(filteredOrders) { order in
                    OrderCard(order: order) {
                        selectedOrder = order
                        withAnimation(.easeInOut(duration: 0.28)) { showOrderView = true }
                    }
                }
            }
            .padding(.horizontal, GlobalSettings.shared.horizontalPadding)
            .padding(.top, 16)
            bottomShadowIgnore(count: settings.cart_count == 0 ? 2 : 5)
        }
        .refreshable { loadData() }
    }

    // MARK: - Shimmer

    private var shimmerList: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 12) {
                ForEach(0..<4, id: \.self) { _ in OrderHistoryShimmer() }
            }
            .padding(.horizontal, GlobalSettings.shared.horizontalPadding)
            .padding(.top, 16)
        }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 16) {
//            Spacer()
            Text(emptyTitle)
                .font(.LatoBold(size: 18))
                .foregroundColor(Color(UIColor(named: "ColorDark")!))
                .multilineTextAlignment(.center)
            Text(emptySubtitle)
                .font(.Lato(size: 15))
                .foregroundColor(Color(UIColor(named: "ColorDark")!).opacity(0.55))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
//            if selectedTab == 0 {
                ButtonView(
                    showLoading: .constant(false),
                    isDisabled: .constant(false),
                    title: getLocalString(string: "shop")
                ) {
                    settings.selection = 0
                }
                .frame(width: 160)
                .padding(.top, 8)
//            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, GlobalSettings.shared.horizontalPadding)
        .padding(.top, 30)
    }

    private var emptyTitle: String {
        switch selectedTab {
        case 1:  return getLocalString(string: "no_completed_orders")
        case 2:  return getLocalString(string: "no_canceled_orders")
        default: return getLocalString(string: "no_active_orders")
        }
    }

    private var emptySubtitle: String {
        switch selectedTab {
        case 1:  return getLocalString(string: "no_orders_desc")
        case 2:  return getLocalString(string: "no_orders_desc")
        default: return getLocalString(string: "no_orders_desc")
        }
    }

    // MARK: - Helpers

    func loadData() {
        isLoading = true
        ordersVM.getData { data in
            if let data = data { ordersVM.updateData(data) }
            isLoading = false
        }
    }

    private var errorDialog: some View {
        CustomDialog(isActive: $showAlert, icone_type: 0,
                     title: getLocalString(string: "wrond_command"),
                     message: errorMess, buttonTitle: "", padd: 50) { }
    }
}

// MARK: - OrderCard

struct OrderCard: View {
    let order: Order
    var onTap: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 0) {

            // ── Main content ─────────────────────────────────────────────────
            HStack(alignment: .top, spacing: 14) {

                // Product image + courier avatar
//                    WebImage(url: URL(string: order.products.first?.product?.image ?? ""))
//                        .resizable()
//                        .scaledToFill()
//                        .frame(width: 80, height: 80)
//                        .clipShape(RoundedRectangle(cornerRadius: 12))
//                        .background(
//                            RoundedRectangle(cornerRadius: 12)
//                                .fill(Color.gray.opacity(0.08))
//                        )
                
                // Order info
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top) {
                        Text("\(getLocalString(string: "order_num"))\(order.id)")
                            .font(.LatoBold(size: 15))
                            .foregroundColor(Color(UIColor(named: "ColorDark")!))
                            .lineLimit(1)
                        Spacer()
                        Text("\(order.products.count) \(getLocalString(string: order.products.count > 1 ? "items" : "item"))")
                            .font(.Lato(size: 13))
                            .foregroundColor(Color(UIColor(named: "ColorDark")!))
                    }
                    HStack(alignment: .top) {
                        Text(order.isDelivery ? (order.billingAddress ?? "") : (order.shop?.name ?? ""))
                            .font(.Lato(size: 13))
                            .foregroundColor(Color(UIColor(named: "ColorDark")!))
                        Spacer()
                        Text("\(order.statusName)")
                            .font(.Lato(size: 13))
                            .foregroundColor(Color(UIColor(named: "ColorDark")!))
                    }
                    HStack(alignment: .top) {
//                        Text(order.isDelivery ? (order.billingAddress ?? "") : (order.shop?.name ?? ""))
//                            .font(.Lato(size: 13))
//                            .foregroundColor(Color(UIColor(named: "ColorDark")!))
                        Spacer()
                        HStack(alignment: .lastTextBaseline, spacing: 4) {
                            Text("\(Int(order.total))")
                                .font(.LatoBold(size: 16))
                                .foregroundColor(Color(UIColor(named: "ColorDark")!))
                            Text("AMD")
                                .font(.Lato(size: 14))
                                .foregroundColor(Color(UIColor(named: "ColorDark")!).opacity(0.4))
                        }
                    }
                }
            }
            .padding(12)

            // ── Bottom: product images + delivery time ────────────────────────
            if !order.products.isEmpty {
                Divider().padding(.horizontal, 12)

                HStack(spacing: 8) {
                    productImagesRow

                    Spacer()

                    // Delivery time — active orders only
                    if isActive,
                       let date = order.deliveryDate,
                       let time = order.deliveryTime,
                       !date.isEmpty || !time.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(getLocalString(string: order.isDelivery ? "delivery_time" : "pick_up_time"))
                                    .font(.Lato(size: 11))
                                    .foregroundColor(Color(UIColor(named: "ColorDark")!).opacity(0.4))
                                Text("\(date) \(time)".trimmingCharacters(in: .whitespaces))
                                    .font(.LatoBold(size: 12))
                                    .foregroundColor(Color(UIColor(named: "ColorDark")!))
                            }
                        }
                    }
                }
                .padding(12)
                .background(Color(UIColor(named: "F9F9F9")!))
            }
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        .onTapGesture { onTap?() }
    }

    // MARK: - Computed helpers

    private var isActive: Bool {
        !(order.isFinished ?? false) && !(order.isCancelled ?? false)
    }

    private var productImagesRow: some View {
        let total        = order.products.count
        let showOverflow = total > 3
        let visibleCount = showOverflow ? 2 : total   // show 2 + "+N" when overflow
        let extraCount   = total - visibleCount

        return HStack(spacing: -10) {
            ForEach(0..<visibleCount, id: \.self) { i in
                WebImage(url: URL(string: order.products[i].product?.image ?? ""))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .zIndex(Double(visibleCount - i))
            }

            if extraCount > 0 {
                ZStack {
                    Circle()
                        .fill(Color(UIColor(named: "ColorDark")!))
                        .frame(width: 36, height: 36)
                    Text("+\(extraCount)")
                        .font(.LatoBold(size: 12))
                        .foregroundColor(.white)
                }
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
            }
        }
    }

    private func courierBubble(letter: String) -> some View {
        Text(letter.isEmpty ? "•" : letter)
            .font(.LatoBold(size: 11))
            .foregroundColor(.white)
            .frame(width: 24, height: 24)
            .background(Circle().fill(Color(red: 0.16, green: 0.60, blue: 0.27)))
            .overlay(Circle().stroke(Color.white, lineWidth: 2))
    }
}


// MARK: - OrderInfo

struct OrderInfo: View {
    let order: Order
    var onDismiss: (() -> Void)? = nil

    private var orderTitle: String {
        let prefix: String
        if order.isCancelled ?? false      { prefix = getLocalString(string: "canceled") }
        else if order.isFinished ?? false  { prefix = getLocalString(string: "completed") }
        else                               { prefix = getLocalString(string: "active") }
        return "\(prefix) \(getLocalString(string: "order_num"))\(order.id)"
    }

    var body: some View {
        VStack(spacing: 0) {

            // ── Header ───────────────────────────────────────────────────────
            ZStack {
                Text(orderTitle)
                    .font(.LatoBold(size: 18))
                    .foregroundColor(Color(UIColor(named: "ColorDark")!))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 48)

                HStack {
                    Button { onDismiss?() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(Color(UIColor(named: "ColorDark")!))
                    }
                    .buttonStyle(.plain)
                    Spacer()
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 14)

            // ── Info strip: date | shop | payment ────────────────────────────
            HStack(spacing: 0) {
                // Date + time
                if let date = order.deliveryDate, let time = order.deliveryTime {
                    Text("\(date) \(time)".trimmingCharacters(in: .whitespaces))
                        .font(.Lato(size: 12))
                        .foregroundColor(Color(UIColor(named: "ColorDark")!).opacity(0.55))
                }

                Spacer()

                // Shop name
                if let shop = order.shop {
                    Text(shop.name)
                        .font(.Lato(size: 12))
                        .foregroundColor(Color(UIColor(named: "ColorDark")!).opacity(0.55))
                        .lineLimit(1)
                }

                Spacer()

                // Payment method
                HStack(spacing: 4) {
                    if !order.paymentMethod.icon.isEmpty {
                        WebImage(url: URL(string: order.paymentMethod.icon))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                    }
                    Text(order.paymentMethod.name)
                        .font(.Lato(size: 12))
                        .foregroundColor(Color(UIColor(named: "ColorDark")!).opacity(0.55))
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)

            Divider()

            // ── Products section ─────────────────────────────────────────────
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    Text(getLocalString(string: "order_contents"))
                        .font(.LatoBold(size: 15))
                        .foregroundColor(Color(UIColor(named: "ColorDark")!).opacity(0.55))
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 12)

                    VStack(spacing: 0) {
                        ForEach(order.products) { item in
                            orderProductRow(item)
                            if item.id != order.products.last?.id {
                                Divider().padding(.leading, 16)
                            }
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(16)
                    .padding(.horizontal, 16)

                    bottomShadowIgnore(count: 3)
                }
            }

            // ── Repeat order button ──────────────────────────────────────────
            ButtonView(
                showLoading: .constant(false),
                isDisabled: .constant(false),
                title: getLocalString(string: "repeat_order")
            ) {
                // TODO: implement reorder
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor(named: "F9F9F9")!))
    }

    @ViewBuilder
    private func orderProductRow(_ item: OrderedProduct) -> some View {
        HStack(spacing: 12) {
            // Product image
            WebImage(url: URL(string: item.product?.image ?? ""))
                .resizable()
                .scaledToFill()
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.07)))

            // Name + unit price
            VStack(alignment: .leading, spacing: 4) {
                Text(item.product?.name ?? "")
                    .font(.LatoBold(size: 15))
                    .foregroundColor(Color(UIColor(named: "ColorDark")!))
                    .lineLimit(2)
                HStack(alignment: .lastTextBaseline, spacing: 3) {
                    Text(item.price)
                        .font(.LatoBold(size: 14))
                        .foregroundColor(Color(UIColor(named: "ColorDark")!))
                    Text("AMD")
                        .font(.Lato(size: 12))
                        .foregroundColor(.gray)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Count pill + total
            VStack(alignment: .trailing, spacing: 6) {
                Text("\(item.count ?? "1") \(getLocalString(string: "pieces"))")
                    .font(.Lato(size: 13))
                    .foregroundColor(Color(UIColor(named: "ColorDark")!))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.gray.opacity(0.1)))

                HStack(alignment: .lastTextBaseline, spacing: 3) {
                    Text(item.total ?? item.price)
                        .font(.LatoBold(size: 15))
                        .foregroundColor(Color(UIColor(named: "ColorDark")!))
                    Text("AMD")
                        .font(.Lato(size: 12))
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(16)
    }
}

// MARK: - HistoryProductCard

struct HistoryProductCard: View {
    let orderProduct: OrderedProduct
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                WebImage(url: URL(string: orderProduct.product?.image ?? ""))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60)
                VStack(alignment: .leading, spacing: 7) {
                    Text(orderProduct.product?.name ?? "")
                        .font(.LatoBold(size: 16))
                    Text("\(orderProduct.count ?? "1") x \(orderProduct.price) ֏")
                        .font(.LatoBold(size: 16))
                }
                Spacer()
            }
            DashedDivider()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color(UIColor(named: "ABABAB")!), lineWidth: 1)
        )
    }
}

// MARK: - DetailRow

struct DetailRow: View {
    let label: String
    let value: String
    let price: String?

    init(label: String, value: String, price: String? = nil) {
        self.label = label
        self.value = value
        self.price = price
    }

    var body: some View {
        HStack {
            HStack(spacing: 3) {
                Text("\(label):")
                    .font(.Lato(size: 14))
                    .foregroundColor(Color(UIColor(named: "CustomGray")!))
                Text(value)
                    .font(.LatoBold(size: 14))
                    .foregroundColor(.black)
            }
            Spacer()
            if let price = price {
                Text(price)
                    .font(.Lato(size: 13))
                    .foregroundColor(Color(UIColor(named: "CustomGray")!))
            }
        }
    }
}

// MARK: - OrderDetailRow

struct OrderDetailRow: View {
    let label: String
    let value: String
    var valueColor: Color = .black
    var isBold: Bool = false
    var icon: String = ""

    var body: some View {
        HStack(spacing: 3) {
            Text("\(label):")
                .font(.LatoBold(size: 14))
                .foregroundColor(.black)
            HStack(spacing: 5) {
                Text(value)
                    .font(isBold ? .LatoBold(size: 14) : .Lato(size: 14))
                    .foregroundColor(valueColor)
                if !icon.isEmpty {
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12)
                }
            }
        }
    }
}
