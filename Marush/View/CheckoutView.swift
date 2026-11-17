//
//  CheckoutView.swift
//  Marush
//

import SwiftUI
import SDWebImageSwiftUI

// MARK: - CheckoutView (Bottom Sheet)

struct CheckoutView: View {
    var onDismiss: (() -> Void)?
    var initialTotal: Double = 0

    @EnvironmentObject var userData: UserViewModel
    @EnvironmentObject var settings: UserSettings
    @EnvironmentObject var appData: AppDataViewModel

    // Checkout data from API
    @State private var checkoutData: CheckoutResponse? = nil
    @State private var isLoading = true
    /// True while `cart/checkout` is re-pricing, so the stale fee is not shown.
    @State private var isPricing = false

    // Order state
    @State private var isDelivery: Int = 0          // 0 = pickup, 1 = delivery
    @State private var isAsap: Int = 1
    @State private var selectedAddress: Address? = nil
    @State private var selectedShop: Shop? = nil
    @State private var deliveryDate: String = ""
    @State private var deliveryTime: String = ""
    @State private var selectedPaymentKey: String = ""
    @State private var selectedCardId: Int = 0
    @State private var useBonusAmount: Int = 0
    @State private var appliedCoupon: String = ""
    @State private var comment: String = ""
    @State private var billingName: String = ""
    @State private var billingLastname: String = ""
    @State private var billingPhone: String = ""
    @State private var billingEmail: String = ""

    // Address details — editable here, seeded from the selected address.
    @State private var apartment: String = ""
    @State private var doorPhone: String = ""
    @State private var entrance: String = ""
    @State private var floor: String = ""

    // Phone input state
    @State private var countryCode: String = "+374"

    // Sub-sheet state
    @State private var showAddressPicker = false
    @State private var showShopPicker    = false
    @State private var showPaymentPicker = false
    @State private var showDatePicker    = false
    @State private var showTimePicker    = false

    // Temporary picker values (committed on "OK")
    @State private var pickerDate: Date = Date()
    @State private var pickerTime: Date = Date()

    // Order placement state
    @State private var isPlacingOrder = false
    @State private var showError      = false
    @State private var errorMessage   = ""

    /// Single inset used by both the header and the scrolling content, so the back
    /// arrow and every section below start on the same line.
    let horizontalPadding = GlobalSettings.shared.horizontalPadding

    // MARK: Computed helpers

    private var productsTotal: Double { checkoutData?.cart.productsTotal ?? initialTotal }
    private var shippingTotal: Double { checkoutData?.cart.shippingTotal ?? 0 }
    private var currentTotal:  Double { checkoutData?.cart.total ?? initialTotal }

    /// Android shows a dash until delivery is actually selected and priced.
    private var deliveryFeeText: String {
        guard isDelivery == 1 else { return "-" }
        return shippingTotal > 0 ? "\(Int(shippingTotal)) AMD" : getLocalString(string: "free")
    }

    /// How long an ASAP order takes. This is a fixed figure, exactly as on Android —
    /// `min_time`/`max_time` are the shop's opening hours, not a preparation estimate.
    private var estimatedTimeText: String {
        getLocalString(string: "asap_estimate")
    }

    /// Opening hours — fixed copy, like Android. The backend's `min_time`/`max_time`
    /// are not used for this line.
    private var workingHoursText: String {
        getLocalString(string: "our_working_hours")
    }

    private var selectedPaymentMethod: PaymentMethod? {
        guard let methods = checkoutData?.paymentMethods else { return nil }
        return methods.first(where: { $0.key == selectedPaymentKey }) ?? methods.first
    }

    /// Saved card backing the current selection, when the method is card-based.
    private var selectedCard: CardsList? {
        guard let cards = checkoutData?.cardsList, !cards.isEmpty else { return nil }
        if selectedCardId != 0 { return cards.first(where: { $0.id == selectedCardId }) }
        return cards.first(where: { $0.isDefault })
    }

    /// Renders a card as `****1234`, matching the design.
    private func maskedCard(_ card: CardsList) -> String {
        let digits = card.cardCode.filter(\.isNumber)
        return "****" + String(digits.suffix(4))
    }

    /// Drops the country code from a stored number: the field only shows the local part,
    /// since `+374` is already rendered by the input control.
    private func localPhone(_ raw: String) -> String {
        var number = raw.trimmingAllSpaces()
        if number.hasPrefix("+")  { number.removeFirst() }
        if number.hasPrefix("00") { number.removeFirst(2) }
        let code = countryCode.replacingOccurrences(of: "+", with: "")
        if !code.isEmpty, number.hasPrefix(code) { number.removeFirst(code.count) }
        return number
    }

    /// Full number sent to the API — country code re-attached, as Login/Register do.
    private var fullPhone: String {
        "\(countryCode)\(billingPhone)".trimmingAllSpaces()
    }

    // MARK: Colors

    private var pillGrayBg: Color  { Color(UIColor.systemGray6) }
    private var borderColor: Color { Color(UIColor(named: "ColorDark")!).opacity(0.13) }
    private var dark: Color        { Color(UIColor(named: "ColorDark")!) }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            // ── Drag handle ─────────────────────────────────────────────
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(UIColor.systemGray4))
                .frame(width: 40, height: 5)
                .padding(.top, 10)
                .padding(.bottom, 6)

            // ── Header ───────────────────────────────────────────────────
            sheetHeader

            if isLoading {
                Spacer()
                ProgressView().tint(dark)
                Spacer()
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 26) {
                        personalInfoSection
                        deliveryConditionsSection
                        deliveryTimeSection
                        if let methods = checkoutData?.paymentMethods, !methods.isEmpty {
                            paymentSection(methods: methods)
                        }
                    }
                    .padding(.horizontal, horizontalPadding)
                    .padding(.top, 24)
                    .padding(.bottom, 24)
                }

                confirmButton
            }
        }
        .background(Color.white)
        .onAppear {
            billingName     = userData.name
            billingLastname = userData.lastname
            billingEmail    = userData.email
            billingPhone    = localPhone(userData.phone)
            loadData()
        }
        .onChange(of: selectedAddress) { newValue in
            if let address = newValue { applyAddress(address) }
        }
        .onTapGesture { hideKeyboard() }
        .sheet(isPresented: $showTimePicker)    { timePicker         }
        .overlay(showError   ? errorDialog   : nil)
        .sheet(isPresented: $showAddressPicker) { addressPickerSheet }
        .sheet(isPresented: $showShopPicker)    { shopPickerSheet    }
        .sheet(isPresented: $showPaymentPicker) { paymentPickerSheet }
        .sheet(isPresented: $showDatePicker)    { datePicker         }
    }

    // MARK: - Header

    private var sheetHeader: some View {
        VStack(spacing: 0) {
            ZStack {
                HStack {
                    Button { onDismiss?() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(dark)
                            // Leading-aligned inside the 36pt tap target so the glyph itself
                            // lands on the padding line instead of being centred past it.
                            .frame(width: 36, height: 36, alignment: .leading)
                    }
                    Spacer()
                }
                Text(getLocalString(string: "make_order"))
                    .font(.LatoBold(size: 20))
                    .foregroundColor(dark)
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, 10)
//            Divider()
        }
    }

    // MARK: - My Information

    private var personalInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("my_info")

            // Name + Lastname side by side
            HStack(spacing: 12) {
                inputField(
                    placeholder: getLocalString(string: "name"),
                    text: $billingName,
                    showErrorImg: .constant(false),
                    errorMess: .constant(""),
                    isSecure: false,
                    showLabel: true
                )
                inputField(
                    placeholder: getLocalString(string: "lastname"),
                    text: $billingLastname,
                    showErrorImg: .constant(false),
                    errorMess: .constant(""),
                    isSecure: false,
                    showLabel: true
                )
            }

            // Phone
            VStack(alignment: .leading, spacing: 4) {
                inputLabel(label: getLocalString(string: "phone_number"))
                PhoneInputView(
                    presentSheet: false,
                    countryCode: $countryCode,
                    mobPhoneNumber: $billingPhone,
                    countryFlag: "🇦🇲",
                    countryPattern: "## ######",
                    countryLimit: 300
                )
                .frame(height: 50)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color(UIColor(named: "CustomGray")!), lineWidth: 1)
                )
                .padding(2)
                .cornerRadius(30)
            }
        }
    }

    // MARK: - Delivery Conditions

    private var deliveryConditionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("delivery_conditions")

            HStack(spacing: 12) {
                conditionPill(
                    topLabel: getLocalString(string: "pickup"),
                    bottomValue: getLocalString(string: "free"),
                    isSelected: isDelivery == 0
                ) { selectTerms(delivery: 0) }

                conditionPill(
                    topLabel: getLocalString(string: "delivery"),
                    bottomValue: deliveryFeeText,
                    isSelected: isDelivery == 1,
                    isLoading: isDelivery == 1 && isPricing
                ) { selectTerms(delivery: 1) }
            }
            .fixedSize(horizontal: false, vertical: true)

            // Address (delivery) or shop (pickup) summary row.
            deliveryInfoRow
        }
    }

    /// Applies a delivery-terms choice and re-prices the cart when the mode changes.
    private func selectTerms(delivery: Int) {
        if delivery == 1 && checkoutData?.disableDelivery == true { return }
        guard delivery != isDelivery else { return }
        isDelivery = delivery
        refreshData()
    }

    /// Bookmark · address + detail line · edit pencil — mirrors Android's `adapter_address`.
    private var deliveryInfoRow: some View {
        let title: String
        let detail: String

        if isDelivery == 1 {
            if let address = selectedAddress {
                title = [address.address, address.building]
                    .filter { !$0.isEmpty }
                    .joined(separator: ", ")
                detail = addressDetailLine(address)
            } else {
                title = getLocalString(string: "select_delivery_address")
                detail = ""
            }
        } else {
            title = selectedShop?.name ?? getLocalString(string: "select_shop")
            detail = selectedShop?.address ?? ""
        }

        return HStack(spacing: 12) {
            Image(systemName: "bookmark")
                .font(.system(size: 17))
                .foregroundColor(dark)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.Lato(size: 15))
                    .foregroundColor(dark.opacity(0.75))
                    .fixedSize(horizontal: false, vertical: true)
                if !detail.isEmpty {
                    Text(detail)
                        .font(.Lato(size: 14))
                        .foregroundColor(Color(UIColor(named: "8C95AA")!))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                isDelivery == 1 ? (showAddressPicker = true) : (showShopPicker = true)
            } label: {
                Image(systemName: "pencil")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(dark)
                    .frame(width: 38, height: 38)
                    .background(pillGrayBg)
                    .cornerRadius(10)
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(borderColor, lineWidth: 1)
        )
        .cornerRadius(14)
    }

    /// Second, muted line of the address row: "Apartment 53, Entrance 2, Floor 9".
    private func addressDetailLine(_ a: Address) -> String {
        var parts: [String] = []
        if !a.apartment.isEmpty { parts.append("\(getLocalString(string: "apartment")) \(a.apartment)") }
        if !a.entrance.isEmpty  { parts.append("\(getLocalString(string: "entrance")) \(a.entrance)") }
        if !a.floor.isEmpty     { parts.append("\(getLocalString(string: "floor")) \(a.floor)") }
        return parts.joined(separator: ", ")
    }

    /// Keeps the order payload in sync with the chosen address, as Android's
    /// `chooseAddress` does — these values are sent even though they are not editable here.
    private func applyAddress(_ a: Address) {
        apartment = a.apartment
        doorPhone = a.domofon
        entrance  = a.entrance
        floor     = a.floor
        if comment.isEmpty { comment = a.comment }
    }

    private func conditionPill(topLabel: String,
                                bottomValue: String,
                                isSelected: Bool,
                                isLoading: Bool = false,
                                onTap: @escaping () -> Void) -> some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 3) {
                Text(topLabel)
                    .font(.Lato(size: 13))
                    .foregroundColor(dark.opacity(0.55))
                    .fixedSize(horizontal: false, vertical: true)
                if isLoading {
                    // The fee is unknown until `cart/checkout` answers — showing the old
                    // value here would briefly read "Free".
                    ProgressView()
                        .scaleEffect(0.7)
                        .frame(height: 20, alignment: .leading)
                } else {
                    Text(bottomValue)
                        .font(.LatoBold(size: 15))
                        .foregroundColor(dark)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            // Half the row each; `maxHeight` keeps both cards the same height when one wraps.
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            // Design marks the active choice with a filled grey card; the others stay outlined.
            .background(isSelected ? pillGrayBg : Color.white)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(borderColor.opacity(isSelected ? 0 : 1), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Delivery Time

    private var deliveryTimeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel(isDelivery == 1 ? "delivery_time" : "pick_up_time")

            HStack(spacing: 12) {
                // ASAP
                timePill(
                    topLabel: getLocalString(string: "asap"),
                    bottomValue: estimatedTimeText,
                    isSelected: isAsap == 1
                ) { isAsap = 1 }

                // Schedule later
                timePill(
                    topLabel: getLocalString(string: "schedule_later"),
                    bottomValue: deliveryDate.isEmpty
                        ? getLocalString(string: "select_time_label")
                        : "\(deliveryDateDisplay)  \(deliveryTime)",
                    isSelected: isAsap == 0
                ) { isAsap = 0 }
            }
            // Lets the row take the height of the taller card instead of stretching.
            .fixedSize(horizontal: false, vertical: true)

            // Day + Time inputs — shown only when "Schedule later" is selected
            if isAsap == 0 {
                HStack(alignment: .top, spacing: 16) {
                    pickerDisplayField(
                        label: getLocalString(string: "day_label"),
                        value: deliveryDateDisplay,
                        placeholder: getLocalString(string: "day_label"),
                        isOpen: showDatePicker
                    ) {
                        pickerDate = dateFromString(deliveryDate) ?? Date()
                        showDatePicker = true
                    }
                    pickerDisplayField(
                        label: getLocalString(string: "time_label"),
                        value: deliveryTime,
                        placeholder: getLocalString(string: "time_label"),
                        isOpen: showTimePicker
                    ) {
                        pickerTime = timeFromString(deliveryTime) ?? Date()
                        showTimePicker = true
                    }
                }
            }

            // Opening hours, straight from `min_time` / `max_time`.
            if !workingHoursText.isEmpty {
                Text(workingHoursText)
                    .font(.LatoBold(size: 15))
                    .foregroundColor(dark.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 4)
            }
        }
    }

    private func timePill(topLabel: String,
                           bottomValue: String,
                           isSelected: Bool,
                           onTap: @escaping () -> Void) -> some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 3) {
                Text(topLabel)
                    .font(.Lato(size: 13))
                    .foregroundColor(dark.opacity(0.55))
                    .fixedSize(horizontal: false, vertical: true)
                if !bottomValue.isEmpty {
                    Text(bottomValue)
                        .font(.LatoBold(size: 14))
                        .foregroundColor(dark)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            // Half the row each, matched heights — same rule as the delivery-terms pills.
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            // Design marks the active choice with a filled grey card; the others stay outlined.
            .background(isSelected ? pillGrayBg : Color.white)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(borderColor.opacity(isSelected ? 0 : 1), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Payment Method

    /// Logos bundled with the app, keyed by the API's `payment_method.key`.
    /// These win over `icon` because the backend does not ship artwork for every method.
    private static let bundledPaymentLogos: [String: String] = [
        "ameria":     "MyAmeria",
        "myameria":   "MyAmeria",
        "ameriabank": "MyAmeria"
    ]

    /// Bundled logo → API-supplied icon → generic card symbol.
    @ViewBuilder
    private func paymentIcon(for method: PaymentMethod) -> some View {
        if let asset = Self.bundledPaymentLogos[method.key.lowercased()] {
            Image(asset)
                .resizable()
                .scaledToFit()
        } else if !method.icon.isEmpty, let url = URL(string: method.icon) {
            WebImage(url: url)
                .resizable()
                .scaledToFit()
        } else {
            Image(systemName: "creditcard.fill")
                .font(.system(size: 18))
                .foregroundColor(dark)
        }
    }

    private func paymentSection(methods: [PaymentMethod]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("payment_method")

            if let method = selectedPaymentMethod {
                HStack(spacing: 14) {
                    paymentIcon(for: method)
                        .frame(width: 44, height: 28)

                    // Show the saved card number when one is selected, else the method name.
                    Text(selectedCard.map { maskedCard($0) } ?? method.name)
                        .font(.LatoBold(size: 15))
                        .foregroundColor(dark)

                    Spacer()

                    // Change button (only shown if multiple options exist)
                    if methods.count > 1 {
                        Button { showPaymentPicker = true } label: {
                            Text(getLocalString(string: "edit"))
                                .font(.Lato(size: 14))
                                .foregroundColor(dark)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 8)
                                .overlay(Capsule().stroke(borderColor, lineWidth: 1.5))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - Price Summary

    private var priceSummary: some View {
        VStack(spacing: 8) {
            HStack {
                Text(getLocalString(string: "items_in_order"))
                    .font(.Lato(size: 15))
                    .foregroundColor(dark.opacity(0.6))
                Spacer()
                CartAMDPrice(price: productsTotal, fontSize: 15, bold: true)
            }
            // Android only shows the delivery line when the order is being delivered.
            if isDelivery == 1 {
                HStack {
                    Text(getLocalString(string: "delivery_fee"))
                        .font(.Lato(size: 15))
                        .foregroundColor(dark.opacity(0.6))
                    Spacer()
                    if isPricing {
                        ProgressView().scaleEffect(0.7)
                    } else {
                        CartAMDPrice(price: shippingTotal, fontSize: 15, bold: true)
                    }
                }
            }
        }
    }

    // MARK: - Footer: totals + confirm button

    private var confirmButton: some View {
        VStack(spacing: 0) {
            Divider()
            priceSummary
                .padding(.horizontal, horizontalPadding)
                .padding(.top, 14)
            ButtonView(
                showLoading: $isPlacingOrder,
                isDisabled: .constant(false),
                title: getLocalString(string: "confirm"),
                showArrow: false,
                action: placeOrder
            )
            .padding(.horizontal, horizontalPadding)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .background(Color.white)
    }

    // MARK: - Section label helper

    private func sectionLabel(_ key: String) -> some View {
        Text(getLocalString(string: key))
            .font(.LatoBold(size: 16))
            .foregroundColor(Color(UIColor(named: "ColorDark")!).opacity(0.8))
    }

    // MARK: - Picker display field (looks like InputView but opens a picker on tap)

    private func pickerDisplayField(label: String,
                                     value: String,
                                     placeholder: String = "",
                                     isOpen: Bool,
                                     onTap: @escaping () -> Void) -> some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 4) {
                inputLabel(label: label)
                HStack(spacing: 8) {
                    Text(value.isEmpty ? placeholder : value)
                        .font(.Poppins(size: 16))
                        .foregroundColor(value.isEmpty ? Color(UIColor(named: "8C95AA")!) : .black)
                        .lineLimit(1)
                    Spacer()
                    // Points up while the picker is open, as in the design.
                    Image(systemName: isOpen ? "chevron.up" : "chevron.down")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(dark.opacity(0.4))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color(UIColor(named: "CustomGray")!), lineWidth: 1)
                )
                .background(Color.white)
                .cornerRadius(30)
                .padding(2)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Date Picker Sheet

    private var datePicker: some View {
        VStack(spacing: 0) {
            HStack {
                Button(getLocalString(string: "cancel_btn")) {
                    showDatePicker = false
                }
                .font(.Lato(size: 16))
                .foregroundColor(dark.opacity(0.5))
                Spacer()
                Text(getLocalString(string: "day_label"))
                    .font(.LatoBold(size: 17))
                    .foregroundColor(dark)
                Spacer()
                Button(getLocalString(string: "ok_btn")) {
                    let fmt = DateFormatter()
                    fmt.dateFormat = "yyyy-MM-dd"
                    deliveryDate = fmt.string(from: pickerDate)
                    showDatePicker = false
                }
                .font(.LatoBold(size: 16))
                .foregroundColor(dark)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)

            Divider()

            DatePicker(
                "",
                selection: $pickerDate,
                in: Date()...,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            .labelsHidden()
            .accentColor(dark)
            .environment(\.locale, Locale(identifier: settings.appLang))
            .padding(.horizontal, 8)

            Spacer()
        }
        .presentationDetents([.medium, .large])
        .presentationCornerRadius(24)
    }

    // MARK: - Time Picker Sheet

    private var timePicker: some View {
        VStack(spacing: 0) {
            HStack {
                Button(getLocalString(string: "cancel_btn")) {
                    showTimePicker = false
                }
                .font(.Lato(size: 16))
                .foregroundColor(dark.opacity(0.5))
                Spacer()
                Text(getLocalString(string: "time_label"))
                    .font(.LatoBold(size: 17))
                    .foregroundColor(dark)
                Spacer()
                Button(getLocalString(string: "ok_btn")) {
                    let fmt = DateFormatter()
                    fmt.dateFormat = "HH:mm"
                    deliveryTime = fmt.string(from: pickerTime)
                    showTimePicker = false
                }
                .font(.LatoBold(size: 16))
                .foregroundColor(dark)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)

            Divider()

            DatePicker(
                "",
                selection: $pickerTime,
                displayedComponents: [.hourAndMinute]
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .accentColor(dark)
            .environment(\.locale, Locale(identifier: settings.appLang))
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .padding(.top, 8)

            Spacer()
        }
        .presentationDetents([.height(320)])
        .presentationCornerRadius(24)
    }

    // MARK: - Date/Time string converters

    private func dateFromString(_ str: String) -> Date? {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt.date(from: str)
    }

    /// `deliveryDate` is stored in the API's `yyyy-MM-dd`; this is the form the user reads,
    /// e.g. "01 June, 2026" / "01 Հնս, 2026".
    private var deliveryDateDisplay: String {
        guard let date = dateFromString(deliveryDate) else { return deliveryDate }

        let language = getLang()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: language)
        // Armenian uses the abbreviated month followed by a period; the others spell it out.
        formatter.dateFormat = language == Lang.armenian.rawValue ? "dd MMM. yyyy" : "dd MMMM, yyyy"

        let text = formatter.string(from: date)
        // Locales return the month lower-cased; the design capitalises it.
        guard let firstLetter = text.firstIndex(where: { $0.isLetter }) else { return text }
        return text.replacingCharacters(in: firstLetter...firstLetter,
                                        with: text[firstLetter].uppercased())
    }

    private func timeFromString(_ str: String) -> Date? {
        let fmt = DateFormatter()
        fmt.dateFormat = "HH:mm"
        return fmt.date(from: str)
    }

    // MARK: - Address Picker Sheet

    private var addressPickerSheet: some View {
        // Same chooser as the account screen: "Add new address" row + the saved list,
        // and picking one makes it the default, exactly as Android does.
        AddressPickerSheet(isPresented: $showAddressPicker) { address in
            selectedAddress = address
            refreshData()
        }
        .environmentObject(appData)
    }

    private var shopPickerSheet: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(getLocalString(string: "choose_a_pick_up_location"))
                .font(.LatoBold(size: 18))
                .foregroundColor(dark)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 18)

            if let shops = checkoutData?.shops, !shops.isEmpty {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(shops) { shop in
                            Button {
                                guard !shop.disabled else { return }
                                selectedShop = shop
                                showShopPicker = false
                                refreshData()
                            } label: {
                                shopRow(shop)
                            }
                            .buttonStyle(.plain)
                            .disabled(shop.disabled)
                            .opacity(shop.disabled ? 0.45 : 1)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
            } else {
                Spacer()
                Text(getLocalString(string: "no_shops"))
                    .font(.Lato(size: 15))
                    .foregroundColor(dark.opacity(0.5))
                    .frame(maxWidth: .infinity)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.white)
    }

    /// Bookmark · name + address · chevron — mirrors Android's `adapter_shop_choose`.
    private func shopRow(_ shop: Shop) -> some View {
        HStack(spacing: 14) {
            Image(systemName: "bookmark")
                .font(.system(size: 17))
                .foregroundColor(dark)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 3) {
                Text(shop.name)
                    .font(.Lato(size: 15))
                    .foregroundColor(dark.opacity(0.75))
                    .fixedSize(horizontal: false, vertical: true)
                if !shop.address.isEmpty {
                    Text(shop.address)
                        .font(.Lato(size: 14))
                        .foregroundColor(Color(UIColor(named: "8C95AA")!))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "chevron.right")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(dark)
        }
        .padding(14)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(borderColor, lineWidth: 1)
        )
        .cornerRadius(14)
    }

    private var paymentPickerSheet: some View {
        NavigationView {
            List(checkoutData?.paymentMethods ?? [], id: \.key) { method in
                Button {
                    selectedPaymentKey = method.key
                    showPaymentPicker = false
                } label: {
                    HStack(spacing: 14) {
                        paymentIcon(for: method)
                            .frame(width: 40, height: 26)
                        Text(method.name)
                            .font(.Lato(size: 15))
                            .foregroundColor(dark)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        if selectedPaymentKey == method.key {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(dark)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .listStyle(.insetGrouped)
            .navigationTitle(getLocalString(string: "payment_method"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button(getLocalString(string: "close_btn")) {
                showPaymentPicker = false
            })
        }
    }

    // MARK: - Dialogs

    private var errorDialog: some View {
        CustomDialog(
            isActive: $showError,
            icone_type: 0,
            title: getLocalString(string: "wrond_command"),
            message: errorMessage,
            buttonTitle: "",
            padd: 50
        ) {}
    }

    /// Estimate line on the confirmation screen: the ASAP window, or the booked slot.
    private var confirmedEstimate: String {
        isAsap == 1 ? estimatedTimeText : "\(deliveryDateDisplay)  \(deliveryTime)"
    }

    /// Routes to the right payment experience once `order/add` succeeds.
    ///
    /// The checkout sheet closes first: the card WebView, the Idram hand-off and the
    /// confirmation screen all live at the tab-bar level, so they must not be stacked
    /// on top of this sheet. Nothing is treated as paid until `checkOrderStatus` has
    /// asked the server.
    private func startPayment(for response: Message) {
        settings.orderId           = response.order_id ?? 0
        settings.thankYouEstimate  = confirmedEstimate
        settings.thankYouIsDelivery = isDelivery == 1
        settings.thankYouMessage   = response.message ?? ""

        let url = response.url ?? ""
        onDismiss?()                                   // close the checkout sheet

        guard selectedPaymentKey != "cash", !url.isEmpty else {
            checkOrderStatus(settings)                 // cash, or nothing to pay through
            return
        }

        if selectedPaymentKey == "idram" {
            settings.selection = 0
            if !configureAndPay(using: url) {
                // Idram missing or the link was malformed — fall back to the bank page.
                settings.paymentUrl = url + "&from_app=ios"
                settings.showPayment = true
            }
        } else {
            settings.paymentUrl = url + "&from_app=ios"
            settings.showPayment = true
        }
    }

    // MARK: - Data loading

    private func loadData() {
        isLoading = true
        let req = FetchCardDataRequest(
            useBonusAmount: useBonusAmount,
            isDelivery: isDelivery,
            isAsap: isAsap,
            shopId: selectedShop?.id ?? "0",
            coupon: appliedCoupon,
            address: isDelivery == 1 ? selectedAddress : nil
        )
        FetchCartData(data: req) { response in
            DispatchQueue.main.async {
                isLoading = false
                checkoutData = response
                // Auto-select defaults
                if selectedAddress == nil {
                    selectedAddress = response?.addresses?.first(where: { $0.isDefault == 1 })
                        ?? response?.addresses?.first
                }
                if selectedShop == nil {
                    selectedShop = response?.shops?.first(where: { !$0.disabled })
                }
                if selectedPaymentKey.isEmpty {
                    selectedPaymentKey = response?.paymentMethods?.first?.key ?? ""
                }
                if deliveryDate.isEmpty { deliveryDate = response?.deliveryDefaultDate ?? "" }
                if deliveryTime.isEmpty { deliveryTime = response?.deliveryDefaultTime ?? "" }
                // Android falls back to today when the API sends no default date, and the
                // order is rejected without a slot — so never leave the date empty.
                if deliveryDate.isEmpty {
                    let fmt = DateFormatter()
                    fmt.dateFormat = "yyyy-MM-dd"
                    deliveryDate = fmt.string(from: Date())
                }
                // If delivery is disabled, force pickup
                if response?.disableDelivery == true { isDelivery = 0 }
            }
        }
    }

    private func refreshData() {
        let req = FetchCardDataRequest(
            useBonusAmount: useBonusAmount,
            isDelivery: isDelivery,
            isAsap: isAsap,
            shopId: selectedShop?.id ?? "0",
            coupon: appliedCoupon,
            address: isDelivery == 1 ? selectedAddress : nil
        )
        isPricing = true
        FetchCartData(data: req) { response in
            DispatchQueue.main.async {
                isPricing = false
                if let res = response { checkoutData = res }
            }
        }
    }

    // MARK: - Place Order

    private func placeOrder() {
        if isDelivery == 1 && selectedAddress == nil {
            errorMessage = getLocalString(string: "please_select_address")
            showError = true; return
        }
        if isDelivery == 0 && selectedShop == nil {
            errorMessage = getLocalString(string: "please_select_shop")
            showError = true; return
        }
        if selectedPaymentKey.isEmpty {
            errorMessage = getLocalString(string: "please_select_payment")
            showError = true; return
        }
        // A scheduled order needs both halves of the slot.
        if isAsap == 0 && (deliveryDate.isEmpty || deliveryTime.isEmpty) {
            errorMessage = getLocalString(string: "select_time_label")
            showError = true; return
        }

        isPlacingOrder = true

        let model = CheckoutRunModel(
            is_delivery:       isDelivery,
            is_asap:           isAsap,
            shop_id:           selectedShop?.id           ?? "",
            billing_address:   selectedAddress?.address   ?? "",
            billing_apartment: apartment,
            billing_building:  selectedAddress?.building  ?? "",
            billing_entrance:  entrance,
            billing_floor:     floor,
            billing_domofon:   doorPhone,
            // Sent for ASAP too: the API validates the slot regardless of `is_asap`,
            // and Android likewise always posts the defaults from `cart/checkout`.
            delivery_date:     deliveryDate,
            delivery_time:     deliveryTime,
            payment_method:    selectedPaymentKey,
            use_bonus_amount:  useBonusAmount,
            billing_name:      billingName,
            billing_lastname:  billingLastname,
            billing_email:     billingEmail,
            billing_phone:     fullPhone,
            billing_comment:   comment,
            billing_city:      selectedAddress?.city      ?? "",
            billing_state:     selectedAddress?.state     ?? "",
            billing_district:  selectedAddress?.district  ?? "",
            billing_latitude:  selectedAddress?.latitude  ?? "",
            billing_longitude: selectedAddress?.longitude ?? "",
            coupon:            appliedCoupon,
            save_card:         false,
            user_card_id:      selectedCardId
        )

        print("""
        🧾 order/add → is_delivery: \(model.is_delivery), is_asap: \(model.is_asap), \
        shop_id: '\(model.shop_id)', payment_method: '\(model.payment_method)'
           address: '\(model.billing_address)' bld:'\(model.billing_building)' \
        apt:'\(model.billing_apartment)' ent:'\(model.billing_entrance)' flr:'\(model.billing_floor)'
           city:'\(model.billing_city)' state:'\(model.billing_state)' \
        district:'\(model.billing_district)'
           lat:'\(model.billing_latitude)' lng:'\(model.billing_longitude)'
           date:'\(model.delivery_date)' time:'\(model.delivery_time)'
           name:'\(model.billing_name)' lastname:'\(model.billing_lastname)' \
        phone:'\(model.billing_phone)' email:'\(model.billing_email)'
        """)

        Checkout(data: model) { response in
            DispatchQueue.main.async {
                isPlacingOrder = false

                guard let res = response else {
                    print("🧾 order/add ← nil (network or decode failure — see the ❌ log above)")
                    errorMessage = getLocalString(string: "wrond_command")
                    showError = true
                    return
                }

                let e = res.errors
                print("""
                🧾 order/add ← status: \(res.status), order_id: \(res.order_id.map(String.init) ?? "-")
                   title: '\(res.title ?? "-")'  message: '\(res.message ?? "-")'
                   url: '\(res.url ?? "-")'  redirect_url: '\(res.redirect_url ?? "-")'
                   errors → payment_method:'\(e?.payment_method ?? "-")' shop_id:'\(e?.shop_id ?? "-")' \
                billing_address:'\(e?.billing_address ?? "-")' delivery_time:'\(e?.delivery_time ?? "-")'
                           name:'\(e?.name ?? "-")' lastname:'\(e?.lastname ?? "-")' \
                phone:'\(e?.phone ?? "-")' email:'\(e?.email ?? "-")'
                """)

                guard res.status == 200 else {
                    // `message` is often empty while the real reason sits in `errors`.
                    let fieldError = [
                        res.errors?.delivery_time,
                        res.errors?.billing_address,
                        res.errors?.shop_id,
                        res.errors?.payment_method,
                        res.errors?.phone,
                        res.errors?.name,
                        res.errors?.lastname,
                        res.errors?.email
                    ].compactMap { $0 }.first { !$0.isEmpty }

                    errorMessage = fieldError
                        ?? (res.message?.isEmpty == false ? res.message! : nil)
                        ?? getLocalString(string: "wrond_command")
                    showError = true
                    return
                }
                startPayment(for: res)
            }
        }
    }
}
