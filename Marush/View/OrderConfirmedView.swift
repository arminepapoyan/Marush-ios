//
//  OrderConfirmedView.swift
//  Marush
//

import SwiftUI

// MARK: - OrderConfirmedView

/// Shown once an order has been accepted (after the payment confirmation step).
struct OrderConfirmedView: View {
    /// Human-readable delivery/pickup estimate, e.g. "01 Հնս. 2026  14:30" or "50-60 min".
    var estimate: String = ""
    /// `true` for delivery, `false` for pickup — only changes the wording.
    var isDelivery: Bool = true
    /// Message returned by the API; falls back to the localized copy when empty.
    var serverMessage: String = ""

    var onTrackOrder: (() -> Void)?
    var onClose: (() -> Void)?

    @EnvironmentObject var userData: UserViewModel
    @EnvironmentObject var settings: UserSettings
    @EnvironmentObject var appData: AppDataViewModel

    @State private var isLoading = false

    private let horizontalPadding = GlobalSettings.shared.horizontalPadding
    private var dark: Color { Color(UIColor(named: "ColorDark")!) }

    // MARK: Body

    var body: some View {
        VStack(spacing: 0) {

            // ── Cream strip with address, call and notifications ───────────
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

            // ── White content card ─────────────────────────────────────────
            VStack(spacing: 0) {
                header

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        subtitle
                        thankYouImage
                        estimateAndTracking
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, horizontalPadding)
                }

                supportNote
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(UIColor(named: "F9F9F9")!))
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .padding(.top, -30)
        }
        .background(Color(UIColor(named: "F3E6B1")!).ignoresSafeArea())
    }

    // MARK: Header

    private var header: some View {
        ZStack {
            HStack {
                Button { onClose?() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(dark)
                        // Leading-aligned so the glyph sits on the padding line.
                        .frame(width: 36, height: 36, alignment: .leading)
                }
                Spacer()
            }
            Text(getLocalString(string: "order_confirmed"))
                .font(.LatoBold(size: 20))
                .foregroundColor(dark)
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.top, 24)
        .padding(.bottom, 8)
    }

    // MARK: Sections

    private var subtitle: some View {
        Text(serverMessage.isEmpty
             ? getLocalString(string: "order_placed_successfully")
             : serverMessage)
            .font(.Lato(size: 16))
            .foregroundColor(dark.opacity(0.55))
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 24)
            .padding(.top, 16)
    }

    private var thankYouImage: some View {
        Image("ThankYou")
            .resizable()
            .scaledToFit()
            .frame(maxWidth: 200)
            .padding(.top, 32)
            .padding(.bottom, 32)
    }

    @ViewBuilder
    private var estimateAndTracking: some View {
        VStack(spacing: 18) {
            if !estimate.isEmpty {
                Text(String(format: getLocalString(string: isDelivery ? "will_be_delivered_by"
                                                                      : "will_be_ready_by"),
                            estimate))
                    .font(.Lato(size: 15))
                    .foregroundColor(dark.opacity(0.55))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Button { onTrackOrder?() } label: {
                Text(getLocalString(string: "track_my_order"))
                    .font(.LatoBold(size: 17))
                    .foregroundColor(dark)
            }
            .buttonStyle(.plain)
        }
        .padding(.bottom, 24)
    }

    private var supportNote: some View {
        Text(getLocalString(string: "support_note"))
            .font(.Lato(size: 13))
            .foregroundColor(dark.opacity(0.45))
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 28)
            .padding(.bottom, 28)
    }
}
