//
//  Notification.swift
//  Marush
//
//  Created by s2s s2s on 30.01.2026.
//
import Foundation


struct NotificationItem:Identifiable,Codable {
    var id: Int
    var title: String
    var date: String
    var order_id: Int
    var seen: String
    var offset : CGFloat = 0
//    var order : Order?
//    var product : Product?
    var url : String?
}
