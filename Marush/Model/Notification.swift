//
//  Notification.swift
//  Marush
//
//  Created by s2s s2s on 30.01.2026.
//
import Foundation

struct NotificationItem: Identifiable, Codable {
    var id: Int
    var text: String
    var date: String
    var order_id: Int
    var seen: Bool
    var is_product: Bool
    var type: String
    var url: String?

    // UI-only — not part of the API response
    var offset: CGFloat = 0

    enum CodingKeys: String, CodingKey {
        case id, text, date, order_id, seen, is_product, type, url
    }
}
