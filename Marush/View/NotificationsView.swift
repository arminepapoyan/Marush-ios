//
//  NotificationsView.swift
//  Marush
//

import SwiftUI
import SDWebImageSwiftUI
import Shimmer

struct NotificationsView: View {

    @Binding var isPresented: Bool
    @StateObject private var vm = NotificationViewModel()

    var body: some View {
        VStack(spacing: 0) {

            // ── Header ───────────────────────────────────────────────────────
            ZStack {
                Text(getLocalString(string: "notifications"))
                    .font(.LatoBold(size: 20))
                    .foregroundColor(Color(UIColor(named: "ColorDark")!))

                HStack {
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(Color(UIColor(named: "ColorDark")!))
                            .frame(width: 36, height: 36)
                    }
                    .buttonStyle(.plain)
                    Spacer()
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 12)

            Divider()
                .foregroundColor(Color.gray.opacity(0.15))

            // ── Content ───────────────────────────────────────────────────────
            if vm.isLoading {
                shimmerList
            } else if vm.list.isEmpty {
                emptyState
            } else {
                notificationList
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor(named: "F9F9F9")!))
        .onAppear {
            vm.getData {
                // Mark all as seen once the list is loaded
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    vm.markAllSeen()
                }
            }
        }
    }

    // MARK: - Notification List

    private var notificationList: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                ForEach(vm.list) { item in
                    NotificationRow(item: item)
                    if item.id != vm.list.last?.id {
                        Divider()
                            .padding(.leading, 60)
                    }
                }
            }
            .background(Color.white)
            .cornerRadius(16)
            .padding(.horizontal, 16)
            .padding(.vertical, 16)

            bottomShadowIgnore(count: 3)
        }
    }

    // MARK: - Shimmer

    private var shimmerList: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                ForEach(0..<10, id: \.self) { i in
                    NotificationRowShimmer()
                    if i < 9 {
                        Divider().padding(.leading, 60)
                    }
                }
            }
            .background(Color.white)
            .cornerRadius(16)
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "bell.slash")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(Color(UIColor(named: "ColorDark")!).opacity(0.25))
            Text(getLocalString(string: "no_notifications"))
                .font(.LatoBold(size: 17))
                .foregroundColor(Color(UIColor(named: "ColorDark")!).opacity(0.45))
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - NotificationRow

private struct NotificationRow: View {
    let item: NotificationItem

    var body: some View {
        HStack(alignment: .center, spacing: 14) {

            // Icon / image
            Group {
                if let urlStr = item.url, !urlStr.isEmpty, let url = URL(string: urlStr) {
                    WebImage(url: url)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: defaultIcon)
                        .resizable()
                        .scaledToFit()
                        .padding(6)
                        .foregroundColor(Color(UIColor(named: "ColorDark")!).opacity(0.6))
                }
            }
            .frame(width: 40, height: 40)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(UIColor(named: "F3E6B1")!).opacity(0.6))
            )

            // Text
            Text(item.text)
                .font(.Lato(size: 15))
                .foregroundColor(Color(UIColor(named: "ColorDark")!))
                .lineLimit(3)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Unseen red dot
            Circle()
                .fill(Color(UIColor(named: "ColorPrimary")!))
                .frame(width: 9, height: 9)
                .opacity(item.seen ? 0 : 1)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(item.seen ? Color.white : Color(UIColor(named: "F9F9F9")!).opacity(0.5))
    }

    private var defaultIcon: String {
        switch item.type {
        case "order":   return "bag.fill"
        case "promo":   return "tag.fill"
        case "product": return "cart.fill"
        default:        return "bell.fill"
        }
    }
}

// MARK: - NotificationRowShimmer

private struct NotificationRowShimmer: View {
    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(UIColor(named: "ColorShimmer")!))
                .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 6) {
                Rectangle()
                    .fill(Color(UIColor(named: "ColorShimmer")!))
                    .frame(maxWidth: .infinity)
                    .frame(height: 12)
                Rectangle()
                    .fill(Color(UIColor(named: "ColorShimmer")!))
                    .frame(width: 160, height: 10)
            }
            .frame(maxWidth: .infinity)

            Circle()
                .fill(Color(UIColor(named: "ColorShimmer")!))
                .frame(width: 9, height: 9)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .redacted(reason: .placeholder)
        .shimmering()
    }
}
