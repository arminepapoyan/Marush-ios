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
    /// Delivering to a different recipient — clears the recipient fields for manual entry.
    @State private var isForSomeoneElse = false

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
    @State private var showSuccess    = false
    @State private var successTitle   = ""
    @State private var successMsg     = ""

    /// Single inset used by both the header and the scrolling content, so the back
    /// arrow and every section below start on the same line.
    let horizontalPadding = GlobalSettings.shared.horizontalPadding

    // MARK: Computed helpers

    private var productsTotal: Double { checkoutData?.cart.productsTotal ?? initialTotal }
    private var shippingTotal: Double { checkoutData?.cart.shippingTotal ?? 0 }
    private var currentTotal:  Double { checkoutData?.cart.total ?? initialTotal }

    private var deliveryFeeText: String {
        shippingTotal > 0 ? "\(Int(shippingTotal)) AMD" : "0 AMD"
    }

    /// "25-35min · Confirm" when an ASAP estimate is known, otherwise just "Confirm".
    private var confirmButtonTitle: String {
        let confirm = getLocalString(string: "confirm")
        guard isAsap == 1, !estimatedTimeText.isEmpty else { return confirm }
        return "\(estimatedTimeText) · \(confirm)"
    }

    private var estimatedTimeText: String {
        let mn = checkoutData?.minTime ?? ""
        let mx = checkoutData?.maxTime ?? ""
        guard !mn.isEmpty else { return "" }
        return mn == mx ? "\(mn) min" : "\(mn)–\(mx) min"
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
                        deliveryConditionsSection
                        // For pickup there is no address block, so contact details live here.
                        if isDelivery == 0 { personalInfoSection }
                        deliveryTimeSection
                        if let methods = checkoutData?.paymentMethods, !methods.isEmpty {
                            paymentSection(methods: methods)
                        }
                        priceSummary
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
        .overlay(pickerOverlay)
        .overlay(showError   ? errorDialog   : nil)
        .overlay(showSuccess ? successDialog : nil)
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

            // Three options, scrolled horizontally as in the design.
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    conditionPill(
                        topLabel: getLocalString(string: "pickup"),
                        bottomValue: getLocalString(string: "free"),
                        isSelected: isDelivery == 0
                    ) { selectTerms(delivery: 0, someoneElse: false) }

                    conditionPill(
                        topLabel: getLocalString(string: "delivery"),
                        bottomValue: deliveryFeeText,
                        isSelected: isDelivery == 1 && !isForSomeoneElse
                    ) { selectTerms(delivery: 1, someoneElse: false) }

                    conditionPill(
                        topLabel: getLocalString(string: "delivery_for_someone_else"),
                        bottomValue: deliveryFeeText,
                        isSelected: isDelivery == 1 && isForSomeoneElse
                    ) { selectTerms(delivery: 1, someoneElse: true) }
                }
                .padding(.vertical, 2)
            }

            if isDelivery == 1 {
                addressSelectRow
                addressDetailFields
            } else {
                shopSelectRow
            }
        }
    }

    /// Applies a delivery-terms choice and re-prices the cart when the mode changes.
    private func selectTerms(delivery: Int, someoneElse: Bool) {
        if delivery == 1 && checkoutData?.disableDelivery == true { return }
        guard delivery != isDelivery || someoneElse != isForSomeoneElse else { return }

        let modeChanged = delivery != isDelivery
        isDelivery = delivery
        isForSomeoneElse = someoneElse

        // Ordering for someone else starts from blank recipient details.
        if someoneElse {
            billingName = ""
            billingPhone = ""
        } else {
            billingName = userData.name
            billingPhone = localPhone(userData.phone)
        }

        if modeChanged { refreshData() }
    }

    // MARK: - Address / shop selectors

    private var addressSelectRow: some View {
        selectRow(
            title: selectedAddress.map(addressTitle) ?? getLocalString(string: "select_delivery_address"),
            isPlaceholder: selectedAddress == nil
        ) { showAddressPicker = true }
    }

    private var shopSelectRow: some View {
        selectRow(
            title: selectedShop?.name ?? getLocalString(string: "select_shop"),
            isPlaceholder: selectedShop == nil
        ) { showShopPicker = true }
    }

    private func selectRow(title: String,
                           isPlaceholder: Bool,
                           onTap: @escaping () -> Void) -> some View {
        Button(action: onTap) {
            HStack {
                Text(title)
                    .font(.Poppins(size: 15))
                    .foregroundColor(isPlaceholder ? Color(UIColor(named: "8C95AA")!) : .black)
                    .lineLimit(1)
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(dark.opacity(0.4))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color(UIColor(named: "CustomGray")!), lineWidth: 1)
            )
            .cornerRadius(30)
        }
        .buttonStyle(.plain)
    }

    private func addressTitle(_ a: Address) -> String {
        let parts = [a.address, a.building].filter { !$0.isEmpty }
        return parts.isEmpty ? a.title : parts.joined(separator: ", ")
    }

    /// Seeds the editable detail fields whenever a different address is chosen.
    private func applyAddress(_ a: Address) {
        apartment = a.apartment
        doorPhone = a.domofon
        entrance  = a.entrance
        floor     = a.floor
        if comment.isEmpty { comment = a.comment }
    }

    // MARK: - Address detail fields

    private var addressDetailFields: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                plainField("apartment",  $apartment)
                plainField("door_phone", $doorPhone)
            }
            HStack(spacing: 12) {
                plainField("entrance", $entrance)
                plainField("floor",    $floor)
            }
            plainField("instructions_for_driver", $comment)
            plainField("recipient_name",          $billingName)
            plainField("recipient_phone",         $billingPhone)
        }
    }

    private func plainField(_ key: String, _ text: Binding<String>) -> some View {
        inputField(
            placeholder: getLocalString(string: key),
            text: text,
            showErrorImg: .constant(false),
            errorMess: .constant(""),
            isSecure: false,
            showLabel: false
        )
    }

    /// Baseline width shared by the delivery-terms and delivery-time pills;
    /// longer labels grow past it rather than wrapping.
    private let pillMinWidth: CGFloat = 152

    private func conditionPill(topLabel: String,
                                bottomValue: String,
                                isSelected: Bool,
                                onTap: @escaping () -> Void) -> some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 3) {
                Text(topLabel)
                    .font(.Lato(size: 13))
                    .foregroundColor(dark.opacity(0.55))
                    .lineLimit(1)
                Text(bottomValue)
                    .font(.LatoBold(size: 15))
                    .foregroundColor(dark)
                    .lineLimit(1)
            }
            // Each pill is exactly as wide as its longest line, so no label wraps.
            .fixedSize(horizontal: true, vertical: false)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            // …but never narrower than the baseline pill width.
            .frame(minWidth: pillMinWidth, alignment: .leading)
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

            // Scrolls horizontally when the labels are too long to fit side by side.
            ScrollView(.horizontal, showsIndicators: false) {
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
                .padding(.vertical, 2)
            }

            // Day + Time inputs — shown only when "Schedule later" is selected
            if isAsap == 0 {
                HStack(spacing: 12) {
                    pickerDisplayField(
                        label: getLocalString(string: "day_label") + "*",
                        value: deliveryDateDisplay
                    ) {
                        pickerDate = dateFromString(deliveryDate) ?? Date()
                        showDatePicker = true
                    }
                    pickerDisplayField(
                        label: getLocalString(string: "time_label") + "*",
                        value: deliveryTime
                    ) {
                        pickerTime = timeFromString(deliveryTime) ?? Date()
                        withAnimation(.easeInOut(duration: 0.2)) { showTimePicker.toggle() }
                    }
                }

            }
        }
    }

    /// Floating time picker: lives in an overlay above the page, so opening it never
    /// shifts the layout and it is not another modal stacked on this sheet.
    @ViewBuilder
    private var pickerOverlay: some View {
        if showTimePicker {
            ZStack {
                Color.black.opacity(0.25)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) { showTimePicker = false }
                    }

                DatePicker("", selection: $pickerTime, displayedComponents: .hourAndMinute)
                    .onChange(of: pickerTime) { newValue in
                        let fmt = DateFormatter()
                        fmt.dateFormat = "HH:mm"
                        deliveryTime = fmt.string(from: newValue)
                    }
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(maxWidth: .infinity)
                .frame(height: 190)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.15), radius: 20, y: 8)
                .padding(.horizontal, horizontalPadding)
            }
            .transition(.opacity)
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
                    .lineLimit(1)
                if !bottomValue.isEmpty {
                    Text(bottomValue)
                        .font(.LatoBold(size: 14))
                        .foregroundColor(dark)
                        .lineLimit(1)
                }
            }
            // Sized to its longest line, same as the delivery-terms pills.
            .fixedSize(horizontal: true, vertical: false)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(minWidth: pillMinWidth, alignment: .leading)
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

    private func paymentSection(methods: [PaymentMethod]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("payment_method")

            if let method = selectedPaymentMethod {
                HStack(spacing: 14) {
                    // Icon
                    Group {
                        if !method.icon.isEmpty, let url = URL(string: method.icon) {
                            WebImage(url: url)
                                .resizable()
                                .scaledToFit()
                        } else {
                            Image(systemName: "creditcard.fill")
                                .font(.system(size: 18))
                                .foregroundColor(dark)
                        }
                    }
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
            HStack {
                Text(getLocalString(string: "delivery_fee"))
                    .font(.Lato(size: 15))
                    .foregroundColor(dark.opacity(0.6))
                Spacer()
                CartAMDPrice(price: shippingTotal, fontSize: 15, bold: true)
            }
        }
    }

    // MARK: - Confirm button

    private var confirmButton: some View {
        VStack(spacing: 0) {
            Divider()
            ButtonView(
                showLoading: $isPlacingOrder,
                isDisabled: .constant(false),
                // Design prefixes the estimated time, e.g. "25-35min · Confirm".
                title: confirmButtonTitle,
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
                                     onTap: @escaping () -> Void) -> some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 4) {
                inputLabel(label: label)
                Text(value.isEmpty ? " " : value)
                    .font(.Poppins(size: 16))
                    .foregroundColor(value.isEmpty ? Color(UIColor(named: "8C95AA")!) : .black)
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
        NavigationView {
            Group {
                if let addresses = checkoutData?.addresses, !addresses.isEmpty {
                    List(addresses) { addr in
                        Button {
                            selectedAddress = addr
                            showAddressPicker = false
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(Color(UIColor(named: "ColorPrimary")!))
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(addr.title.isEmpty ? addr.address : addr.title)
                                        .font(.LatoBold(size: 15))
                                        .foregroundColor(dark)
                                    let detail = [addr.city, addr.address, addr.building]
                                        .filter { !$0.isEmpty }.joined(separator: ", ")
                                    if !detail.isEmpty {
                                        Text(detail)
                                            .font(.Lato(size: 13))
                                            .foregroundColor(dark.opacity(0.55))
                                            .lineLimit(2)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                if selectedAddress?.id == addr.id {
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
                } else {
                    VStack(spacing: 12) {
                        Spacer()
                        Image(systemName: "mappin.slash")
                            .font(.system(size: 44, weight: .light))
                            .foregroundColor(dark.opacity(0.2))
                        Text(getLocalString(string: "no_addresses"))
                            .font(.Lato(size: 15))
                            .foregroundColor(dark.opacity(0.5))
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle(getLocalString(string: "select_delivery_address"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button(getLocalString(string: "close_btn")) {
                showAddressPicker = false
            })
        }
    }

    // MARK: - Shop Picker Sheet

    private var shopPickerSheet: some View {
        NavigationView {
            Group {
                if let shops = checkoutData?.shops, !shops.isEmpty {
                    List(shops) { shop in
                        Button {
                            guard !shop.disabled else { return }
                            selectedShop = shop
                            showShopPicker = false
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: "building.2.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color(UIColor(named: "ColorPrimary")!))
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(shop.name)
                                        .font(.LatoBold(size: 15))
                                        .foregroundColor(dark)
                                    if !shop.address.isEmpty {
                                        Text(shop.address)
                                            .font(.Lato(size: 13))
                                            .foregroundColor(dark.opacity(0.55))
                                            .lineLimit(2)
                                    }
                                    if shop.disabled {
                                        Text(shop.disabledMessage)
                                            .font(.Lato(size: 12))
                                            .foregroundColor(.red.opacity(0.8))
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .opacity(shop.disabled ? 0.4 : 1)
                                if selectedShop?.id == shop.id {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(dark)
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .disabled(shop.disabled)
                    }
                    .listStyle(.insetGrouped)
                } else {
                    VStack(spacing: 12) {
                        Spacer()
                        Image(systemName: "building.2")
                            .font(.system(size: 44, weight: .light))
                            .foregroundColor(dark.opacity(0.2))
                        Text(getLocalString(string: "no_shops"))
                            .font(.Lato(size: 15))
                            .foregroundColor(dark.opacity(0.5))
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle(getLocalString(string: "select_shop"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button(getLocalString(string: "close_btn")) {
                showShopPicker = false
            })
        }
    }

    // MARK: - Payment Picker Sheet

    private var paymentPickerSheet: some View {
        NavigationView {
            List(checkoutData?.paymentMethods ?? [], id: \.key) { method in
                Button {
                    selectedPaymentKey = method.key
                    showPaymentPicker = false
                } label: {
                    HStack(spacing: 14) {
                        Group {
                            if !method.icon.isEmpty, let url = URL(string: method.icon) {
                                WebImage(url: url)
                                    .resizable()
                                    .scaledToFit()
                            } else {
                                Image(systemName: "creditcard.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(dark)
                            }
                        }
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

    private var successDialog: some View {
        CustomDialog(
            isActive: $showSuccess,
            icone_type: 1,
            title: successTitle,
            message: successMsg,
            buttonTitle: "OK",
            padd: 50
        ) {
            settings.selection = 1
            onDismiss?()
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
            coupon: appliedCoupon
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
            coupon: appliedCoupon
        )
        FetchCartData(data: req) { response in
            DispatchQueue.main.async {
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
            delivery_date:     isAsap == 1 ? "" : deliveryDate,
            delivery_time:     isAsap == 1 ? "" : deliveryTime,
            payment_method:    selectedPaymentKey,
            use_bonus_amount:  useBonusAmount,
            billing_name:      billingName,
            billing_lastname:  billingLastname,
            billing_email:     billingEmail,
            billing_phone:     fullPhone,
            billing_comment:   comment,
            billing_city:      selectedAddress?.city ?? "",
            coupon:            appliedCoupon,
            save_card:         false,
            user_card_id:      selectedCardId
        )

        Checkout(data: model) { response in
            DispatchQueue.main.async {
                isPlacingOrder = false
                if let res = response, res.status == 200 {
                    successTitle = res.title ?? getLocalString(string: "order_placed")
                    successMsg   = res.message ?? ""
                    showSuccess  = true
                    CartManager.shared.clearAll()
                    settings.cart_count = 0
                } else {
                    errorMessage = response?.message ?? getLocalString(string: "wrond_command")
                    showError = true
                }
            }
        }
    }
}
