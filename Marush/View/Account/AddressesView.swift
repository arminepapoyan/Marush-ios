//
//  AddressesView.swift
//  Marush
//

import SwiftUI

// MARK: - AddressesView (content-only, fills AccountView card)

struct AddressesView: View {

    @StateObject private var addressVM = AddressesViewModel()

    @State private var showForm      = false
    @State private var selectedAddress: Address = .empty
    @State private var isLoading     = true
    @State private var showAlert     = false
    @State private var errorMess     = ""
    @State private var showRemoveAlert = false
    @State private var addressToRemove: Address? = nil

    var body: some View {
        VStack(spacing: 0) {
            HeaderView(title: getLocalString(string: "my_addresses"), showArrow: true)
                .padding(.horizontal)

            ScrollView(.vertical, showsIndicators: false) {
                if isLoading {
                    VStack(spacing: 12) {
                        ForEach(0..<6, id: \.self) { _ in ShopItemShimmer() }
                    }
                    .padding(.horizontal)
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(addressVM.data) { item in
                            AddressItem(
                                arr: $addressVM.data,
                                showAddSheet: $showForm,
                                address: item,
                                onEdit: {
                                    selectedAddress = item
                                    showForm = true
                                },
                                onRemove: { triggerRemove(item) }
                            )
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 16)
                }
                bottomShadowIgnore(count: 4)
            }

            // ── Add New Address button pinned at bottom ──────────────────────
            ButtonView(
                showLoading: .constant(false),
                isDisabled: .constant(false),
                title: getLocalString(string: "add_new_address")
            ) {
                selectedAddress = .empty
                showForm = true
            }
            .padding(.horizontal, GlobalSettings.shared.horizontalPadding)
            .padding(.vertical, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor(named: "F9F9F9")!))
        .overlay(showAlert ? errorOverlay : nil)
        .alert(isPresented: $showRemoveAlert, content: removeAlert)
        .onReceive(addressVM.$data) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { isLoading = false }
        }
        .sheet(isPresented: $showForm) {
            AddressFormView(
                addressVM: addressVM,
                selectedAddress: $selectedAddress,
                showForm: $showForm,
                showAlert: $showAlert,
                errorMess: $errorMess
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Helpers

    private func triggerRemove(_ address: Address) {
        addressToRemove = address
        showRemoveAlert = true
    }

    private var errorOverlay: some View {
        CustomDialog(isActive: $showAlert, icone_type: 0,
                     title: getLocalString(string: "wrond_command"),
                     message: errorMess, buttonTitle: "", padd: 50) { }
    }

    private func removeAlert() -> Alert {
        guard let addr = addressToRemove else {
            return Alert(title: Text("Error"), dismissButton: .default(Text("OK")))
        }
        return Alert(
            title: Text(getLocalString(string: "remove")),
            message: Text(addr.address),
            primaryButton: .destructive(Text(getLocalString(string: "remove"))) {
                handleRemove(addr)
            },
            secondaryButton: .cancel()
        )
    }

    private func handleRemove(_ addr: Address) {
        RemoveAddress(data: addr) { response in
            if response?.status == 200 {
                withAnimation {
                    addressVM.data.removeAll { $0.id == addr.id }
                }
            } else {
                errorMess = response?.message ?? getLocalString(string: "wrond_command")
                showAlert = true
            }
        }
    }
}

// MARK: - AddressFormView

struct AddressFormView: View {
    @ObservedObject var addressVM: AddressesViewModel
    @Binding var selectedAddress: Address
    @Binding var showForm: Bool
    @Binding var showAlert: Bool
    @Binding var errorMess: String
    var onSaved: (() -> Void)? = nil

    @State private var id                  = ""
    @State private var address             = ""
    @State private var building            = ""
    @State private var apartment           = ""
    @State private var entrance            = ""
    @State private var floor               = ""
    @State private var doorCode            = ""
    @State private var driverInstructions  = ""
    @State private var isDefault: Int      = 0
    @State private var btnLoading          = false

    @State private var wrongAddress        = false
    @State private var wrongAddressMessage = ""

    // Yandex lookup — the API only accepts addresses it can geocode.
    @State private var latitude   = ""
    @State private var longitude  = ""
    @State private var city       = ""
    @State private var state      = ""
    @State private var district   = ""
    @State private var suggestions: [SearchAddress] = []
    @State private var suggestWork: DispatchWorkItem?
    /// Address value written by us (initial load or a tapped suggestion). The matching
    /// `onChange` is skipped so it neither re-queries nor clears the coordinates.
    @State private var suppressSuggestFor: String? = nil

    @FocusState private var focused: FocusFields?

    private var isEditing: Bool { !selectedAddress.id.isEmpty }

    var body: some View {
        VStack(spacing: 0) {
            // Sheet title
            Text(getLocalString(string: isEditing ? "edit_address" : "add_new_address"))
                .font(.LatoBold(size: 18))
                .foregroundColor(Color(UIColor(named: "ColorDark")!))
                .padding(.top, 20)
                .padding(.bottom, 5)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {

                    // Հասցե — full width, with the suggestions hanging below it
                    VStack(spacing: 0) {
                        inputField(
                            placeholder: getLocalString(string: "address"),
                            text: $address,
                            showErrorImg: $wrongAddress,
                            errorMess: $wrongAddressMessage,
                            isSecure: false,
                            showLabel: true
                        )
                        .focused($focused, equals: .address)
                        .submitLabel(.next)
                        .onSubmit { focused = .building }
                        .onChange(of: address) { _ in scheduleSuggest() }

                        // Zero-height host directly beneath the field: the dropdown
                        // overflows downward out of it, so it always starts below the
                        // field and still takes no layout space.
                        ZStack(alignment: .top) {
                            if !suggestions.isEmpty {
                                suggestionsDropdown
                                    .padding(.top, 4)
                            }
                        }
                        .frame(height: 0, alignment: .top)
                    }
                    .zIndex(1)

                    // Շենք / Տուն  |  Բնակարան
                    HStack(spacing: 12) {
                        inputField(
                            placeholder: getLocalString(string: "building_house"),
                            text: $building,
                            showErrorImg: .constant(false),
                            errorMess: .constant(""),
                            isSecure: false,
                            showLabel: true
                        )
                        .focused($focused, equals: .building)
                        .submitLabel(.next)
                        .onSubmit { focused = .apartment }
                        .frame(maxWidth: .infinity)

                        inputField(
                            placeholder: getLocalString(string: "appartment"),
                            text: $apartment,
                            showErrorImg: .constant(false),
                            errorMess: .constant(""),
                            isSecure: false,
                            showLabel: true
                        )
                        .focused($focused, equals: .apartment)
                        .submitLabel(.next)
                        .onSubmit { focused = .entrance }
                        .frame(maxWidth: .infinity)
                    }

                    // Մուտք  |  Հարկ
                    HStack(spacing: 12) {
                        inputField(
                            placeholder: getLocalString(string: "entrance"),
                            text: $entrance,
                            showErrorImg: .constant(false),
                            errorMess: .constant(""),
                            isSecure: false,
                            showLabel: true
                        )
                        .focused($focused, equals: .entrance)
                        .submitLabel(.next)
                        .onSubmit { focused = .floor }
                        .frame(maxWidth: .infinity)

                        inputField(
                            placeholder: getLocalString(string: "floor"),
                            text: $floor,
                            showErrorImg: .constant(false),
                            errorMess: .constant(""),
                            isSecure: false,
                            showLabel: true
                        )
                        .focused($focused, equals: .floor)
                        .submitLabel(.next)
                        .onSubmit { focused = nil }
                        .frame(maxWidth: .infinity)
                    }

                    // Դռան կոդ — full width
                    inputField(
                        placeholder: getLocalString(string: "door_code"),
                        text: $doorCode,
                        showErrorImg: .constant(false),
                        errorMess: .constant(""),
                        isSecure: false,
                        showLabel: true
                    )
                    .submitLabel(.next)
                    .onSubmit { focused = nil }

                    // Վարորդի համար ցուցումներ — full width
                    inputField(
                        placeholder: getLocalString(string: "driver_instructions"),
                        text: $driverInstructions,
                        showErrorImg: .constant(false),
                        errorMess: .constant(""),
                        isSecure: false,
                        showLabel: true
                    )
                    .submitLabel(.done)
                    .onSubmit { focused = nil }

                    // Checkbox — Սահմանել որպես հիմնական
                    Button {
                        isDefault = isDefault == 1 ? 0 : 1
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: isDefault == 1 ? "checkmark.square.fill" : "square")
                                .font(.system(size: 20))
                                .foregroundColor(isDefault == 1
                                    ? Color(UIColor(named: "ColorDark")!)
                                    : Color.gray.opacity(0.6))
                            Text(getLocalString(string: "set_as_default"))
                                .font(.Lato(size: 15))
                                .foregroundColor(Color(UIColor(named: "ColorDark")!))
                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)

                    // Save button (dark)
                    ButtonView(
                        showLoading: $btnLoading,
                        isDisabled: .constant(false),
                        title: getLocalString(string: "save_data")
                    ) {
                        handleSave()
                    }

                    // Cancel button (outlined)
                    ButtonView(
                        showLoading: $btnLoading,
                        isDisabled: .constant(false),
                        title: getLocalString(string: "cancel"),
                        style: .outline
                    ) {
                        showForm = false
                    }

                    bottomShadowIgnore(count: 2)
                }
                .padding(.horizontal)
                .padding(.vertical, 16)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor(named: "F9F9F9")!))
        .onAppear { loadValues() }
        .onTapGesture { hideKeyboard() }
    }

    // MARK: - Suggestions dropdown

    private var suggestionsDropdown: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                ForEach(suggestions) { suggestion in
                    Button { apply(suggestion) } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(suggestion.title)
                                .font(.LatoBold(size: 14))
                                .foregroundColor(Color(UIColor(named: "ColorDark")!))
                                .multilineTextAlignment(.leading)
                            Text(suggestion.address)
                                .font(.Lato(size: 13))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    if suggestion.id != suggestions.last?.id {
                        Divider().padding(.leading, 16)
                    }
                }
            }
        }
        // Explicit height: an overlay proposes the field's size, which would otherwise
        // squash the scroll view. Capped so a long result set cannot fill the form.
        .frame(height: min(CGFloat(suggestions.count) * 56, 240))
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(UIColor(named: "CustomGray")!), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.12), radius: 10, y: 4)
    }

    // MARK: - Load existing address values

    private func loadValues() {
        id                 = selectedAddress.id
        // Some records are stored with HTML markup — never show it raw in a field.
        address            = selectedAddress.address.strippingHTML
        // Editing starts from a saved address: keep its pin instead of re-querying.
        suppressSuggestFor = address
        building           = selectedAddress.building.strippingHTML
        apartment          = selectedAddress.apartment.strippingHTML
        entrance           = selectedAddress.entrance.strippingHTML
        floor              = selectedAddress.floor.strippingHTML
        isDefault          = selectedAddress.isDefault
        doorCode           = selectedAddress.domofon.strippingHTML
        driverInstructions = selectedAddress.comment.strippingHTML
        latitude           = selectedAddress.latitude
        longitude          = selectedAddress.longitude
        city               = selectedAddress.city
        state              = selectedAddress.state
        district           = selectedAddress.district
    }

    // MARK: - Yandex lookup

    /// Debounces typing into one `yandex/autosuggest` call.
    private func scheduleSuggest() {
        // Our own write — keep the coordinates that came with it.
        if let suppressed = suppressSuggestFor, suppressed == address {
            suppressSuggestFor = nil
            return
        }

        // Typing again invalidates a previously resolved pin.
        latitude = ""; longitude = ""; city = ""; state = ""; district = ""

        suggestWork?.cancel()
        let query = address.trimmingCharacters(in: .whitespaces)
        guard query.count >= 3 else {
            suggestions = []
            return
        }

        let work = DispatchWorkItem {
            SearchAddressSuggestions(search: query) { result in
                DispatchQueue.main.async {
                    guard let result, result.status != 500 else {
                        suggestions = []
                        return
                    }
                    // Yandex highlights the matched part with <b> tags — clean them here
                    // so neither the list, the field, nor the geocode query sees markup.
                    suggestions = result.address.map {
                        SearchAddress(title: $0.title.strippingHTML,
                                      address: $0.address.strippingHTML)
                    }
                }
            }
        }
        suggestWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: work)
    }

    /// Resolves the tapped suggestion into coordinates via `yandex/geocode`.
    private func apply(_ suggestion: SearchAddress) {
        suggestWork?.cancel()
        suppressSuggestFor = suggestion.address
        address = suggestion.address
        suggestions = []
        hideKeyboard()

        GeocodeAddressLookup(search: suggestion.address) { result in
            DispatchQueue.main.async {
                guard let geo = result?.address, result?.status != 500,
                      !geo.latitude.isEmpty, !geo.longitude.isEmpty,
                      !geo.city.isEmpty, !geo.state.isEmpty else {
                    wrongAddress = true
                    wrongAddressMessage = getLocalString(string: "sorry_we_dont_deliver_to")
                        + " " + suggestion.address
                    return
                }

                wrongAddress = false
                latitude  = geo.latitude
                longitude = geo.longitude
                city      = geo.city
                state     = geo.state
                district  = geo.district

                // Yandex often knows the house number already.
                if !geo.building.isEmpty {
                    building = geo.building
                    focused = .apartment
                } else {
                    focused = .building
                }
            }
        }
    }

    // MARK: - Save

    private func handleSave() {
        guard !address.isEmpty else {
            wrongAddress = true
            wrongAddressMessage = getLocalString(string: "please_fill_address")
            btnLoading = false
            return
        }
        // No coordinates means the address was typed, not picked — the API would reject it.
        guard !latitude.isEmpty, !longitude.isEmpty, latitude != "0", longitude != "0" else {
            wrongAddress = true
            wrongAddressMessage = getLocalString(string: "choose_address_from_the_suggested_list")
            btnLoading = false
            return
        }
        wrongAddress = false
        btnLoading = true

        AddAddress(
            data: Address(id: id, title: "", city: city, address: address, building: building, apartment: apartment, entrance: entrance, floor: floor, domofon: doorCode, isDefault: isDefault, comment: driverInstructions, latitude: latitude, longitude: longitude, state: state, district: district)
        ) { response in
            btnLoading = false
            if response?.status == 200 {
                addressVM.getData { addresses in
                    if let addresses = addresses {
                        DispatchQueue.main.async { addressVM.data = addresses }
                    }
                }
                onSaved?()
                withAnimation(.easeInOut(duration: 0.28)) { showForm = false }
            } else if let msg = response?.message, !msg.isEmpty {
                errorMess = msg
                showAlert = true
            }
        }
    }
}

// MARK: - Address convenience

extension Address {
    static let empty = Address(id: "", title: "", city: "", address: "", building: "", apartment: "", entrance: "", floor: "", domofon: "", isDefault: 0, comment: "")
}

// MARK: - NewAddressButton

struct NewAddressButton: View {
    var body: some View {
        HStack {
            Spacer()
            HStack(alignment: .center, spacing: 10) {
                Image(systemName: "plus")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.white)
                    .padding(11)
                    .background(Circle().fill(Color(UIColor(named: "ColorDark")!)))

                Text(getLocalString(string: "add_new_address"))
                    .font(.LatoBold(size: 16))
                    .foregroundColor(Color(UIColor(named: "ColorDark")!))
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

// MARK: - AddressItem

struct AddressItem: View {
    @Binding var arr: [Address]
    @Binding var showAddSheet: Bool
    var address: Address

    var onEdit: (() -> Void)?
    var onRemove: (() -> Void)?

    @State private var offset: CGFloat = 0
    @State private var isSwiped = false
    let maxSwipeOffset: CGFloat = -80
    let swipeThreshold: CGFloat = 40

    // "entrance 1, floor 7, apt. 34" — only non-empty parts
    private var subtitle: String {
        var parts: [String] = []
        if !address.entrance.isEmpty  { parts.append("\(getLocalString(string: "entrance")) \(address.entrance)") }
        if !address.floor.isEmpty     { parts.append("\(getLocalString(string: "floor")) \(address.floor)") }
        if !address.apartment.isEmpty { parts.append("apt. \(address.apartment)") }
        return parts.joined(separator: ", ")
    }

    var body: some View {
        ZStack(alignment: .trailing) {

            // ── Red delete button (revealed on swipe) ────────────────────────
            Button {
                onRemove?()
                closeSwipe()
            } label: {
                Image("ic-trash")
                    .foregroundColor(.white)
                    .frame(width: maxSwipeOffset * -1)
                    .frame(maxHeight: .infinity)
                    .background(Color(UIColor(named: "ColorPrimary")!))
                    .cornerRadius(12)
            }
            .opacity(isSwiped ? 1 : 0)

            // ── Main card row ────────────────────────────────────────────────
            HStack(alignment: .center, spacing: 14) {

                // Left address icon — swipe gesture lives here
                // Default address gets the solid bookmark, the rest the outline one —
                // the base asset is stroke-only, so tinting alone cannot fill it.
                Image(address.isDefault == 1 ? "ic-address-list-filled" : "ic-address-list")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 26)
                    .foregroundColor(address.isDefault == 1
                                     ? Color(UIColor(named: "ColorPrimary")!)
                                     : Color.gray.opacity(0.45))
                    .overlay(swipeGesture)

                // Address text — swipe gesture lives here too
                VStack(alignment: .leading, spacing: 3) {
                    Text(address.address.strippingHTML)
                        .font(.LatoBold(size: 15))
                        .foregroundColor(Color(UIColor(named: "ColorDark")!))
                        .lineLimit(1)
                    if !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.Lato(size: 13))
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlay(swipeGesture)

                // Edit button — no swipe gesture so it stays tappable
                Button { onEdit?() } label: {
                    Image("ic-edit-pen")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 14, height: 14)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.1))
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
            .offset(x: offset)
        }
    }

    // MARK: - Swipe (mirrors CartView exactly)

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

    private func openSwipe() {
        withAnimation(.easeInOut(duration: 0.25)) { offset = maxSwipeOffset; isSwiped = true }
    }
    private func closeSwipe() {
        withAnimation(.easeInOut(duration: 0.25)) { offset = 0; isSwiped = false }
    }
}

// MARK: - AddressPickerSheet

struct AddressPickerSheet: View {
    @EnvironmentObject var appData: AppDataViewModel
    @Binding var isPresented: Bool
    /// Called with the chosen address once it has been made default on the server.
    var onSelect: ((Address) -> Void)? = nil

    @StateObject private var addressVM = AddressesViewModel()
    @State private var showAddForm      = false
    @State private var newAddress: Address = .empty
    @State private var isSettingDefault = false
    @State private var isLoading        = true

    var body: some View {
        VStack(spacing: 0) {

            // ── Header ───────────────────────────────────────────────────────
            HStack {
                Text(getLocalString(string: "delivery_addresses"))
                    .font(.LatoBold(size: 18))
                    .foregroundColor(Color(UIColor(named: "ColorDark")!))
                Spacer()
                Button { isPresented = false } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.gray)
                        .padding(8)
                        .background(Circle().fill(Color.gray.opacity(0.1)))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)

            // ── Add New Address button ────────────────────────────────────────
            Button {
                newAddress = .empty
                showAddForm = true
            } label: {
                HStack(spacing: 10) {
//                    Image(systemName: "plus.circle.fill")
//                        .font(.system(size: 18))
//                        .foregroundColor(Color(UIColor(named: "ColorDark")!))
                    Text(getLocalString(string: "add_new_address"))
                        .font(.LatoBold(size: 15))
                        .foregroundColor(Color(UIColor(named: "ColorDark")!))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color.gray.opacity(0.5))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
                .background(Color(UIColor(named: "CEF0F7")!))
                .cornerRadius(8)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)
            .padding(.bottom, 12)

            // ── Addresses list ────────────────────────────────────────────────
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    if isLoading {
                        ForEach(0..<5, id: \.self) { _ in
                            AddressPickerRowShimmer()
                        }
                    } else {
                        ForEach(appData.addresses) { addr in
                            Button { selectAddress(addr) } label: {
                                pickerRow(addr)
                            }
                            .buttonStyle(.plain)
                            .disabled(isSettingDefault)
                        }
                    }
                }
                bottomShadowIgnore(count: 3)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .onAppear {
            isLoading = true
            refreshAddresses()
        }
        .sheet(isPresented: $showAddForm) {
            AddressFormView(
                addressVM: addressVM,
                selectedAddress: $newAddress,
                showForm: $showAddForm,
                showAlert: .constant(false),
                errorMess: .constant(""),
                onSaved: { refreshAddresses() }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Helpers

    private func refreshAddresses() {
        addressVM.getData { addresses in
            DispatchQueue.main.async {
                if let addresses = addresses {
                    appData.addresses = addresses
                }
                isLoading = false
            }
        }
    }

    private func selectAddress(_ address: Address) {
        guard !isSettingDefault else { return }
        isSettingDefault = true
        MakeDefaultAddress(id: address.id) { response in
            DispatchQueue.main.async {
                isSettingDefault = false
                if response?.status == 200 {
                    appData.addresses = appData.addresses.map { a in
                        var copy = a
                        copy.isDefault = (a.id == address.id) ? 1 : 0
                        return copy
                    }
                    onSelect?(address)
                    isPresented = false
                }
            }
        }
    }

    private func pickerRow(_ address: Address) -> some View {
        let subtitle = buildSubtitle(address)
        return HStack(spacing: 14) {
            Image(address.isDefault == 1 ? "ic-address-list-filled" : "ic-address-list")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 22)
                .foregroundColor(address.isDefault == 1
                    ? Color(UIColor(named: "ColorPrimary")!)
                    : Color.gray.opacity(0.45))

            VStack(alignment: .leading, spacing: 3) {
                Text(address.address)
                    .font(.LatoBold(size: 15))
                    .foregroundColor(Color(UIColor(named: "ColorDark")!))
                    .lineLimit(1)
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.Lato(size: 13))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if address.isDefault == 1 {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color(UIColor(named: "ColorPrimary")!))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.white)
//        .cornerRadius(12)
        .overlay(
               VStack {
                   Spacer()
                   Rectangle()
                       .fill(Color(UIColor(named: "CEF0F7")!)) // border color
                       .frame(height: 1)
               }
           )
//        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
//        .overlay(
//            RoundedRectangle(cornerRadius: 12)
//                .stroke(Color.clear, lineWidth: 1.5)
//        )
    }

    private func buildSubtitle(_ address: Address) -> String {
        var parts: [String] = []
        if !address.entrance.isEmpty  { parts.append("\(getLocalString(string: "entrance")) \(address.entrance)") }
        if !address.floor.isEmpty     { parts.append("\(getLocalString(string: "floor")) \(address.floor)") }
        if !address.apartment.isEmpty { parts.append("apt. \(address.apartment)") }
        return parts.joined(separator: ", ")
    }
}
