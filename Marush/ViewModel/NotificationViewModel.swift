//
//  NotificationViewModel.swift
//  Marush
//
//  Created by s2s s2s on 30.01.2026.
//

import Foundation
import Combine

class NotificationViewModel: ObservableObject {

    @Published var list: [NotificationItem] = []
    @Published var isLoading: Bool = true

    var unseenCount: Int {
        list.filter { !$0.seen }.count
    }

    func getData(completion: (() -> Void)? = nil) {
        let url = NetworkManager.shared.constructURL(endpoint: "user/notifications")
        let body: [String: Any] = [
            "token": getAccountToken(),
            "device_id": getDeviceId(),
            "from_app": "ios"
        ]
        NetworkManager.shared.performRequest(url: url, body: body) { [weak self] (result: [NotificationItem]?) in
            DispatchQueue.main.async {
                if let items = result {
                    self?.list = items
                    // Sync unseen badge count globally
                    UserSettings.shared.noti_count = items.filter { !$0.seen }.count
                }
                self?.isLoading = false
                completion?()
            }
        }
    }

    func markAllSeen() {
        // Mark all as seen locally immediately for instant UI feedback
        list = list.map { item in
            var copy = item
            copy.seen = true
            return copy
        }
        UserSettings.shared.noti_count = 0

        // TODO: call server when API endpoint is provided
        // markSeenOnServer(id: nil)
    }

    func markSeen(id: Int) {
        if let idx = list.firstIndex(where: { $0.id == id }) {
            list[idx].seen = true
        }
        UserSettings.shared.noti_count = unseenCount

        // TODO: call server when API endpoint is provided
        // markSeenOnServer(id: id)
    }
}

func firebaseToken(data: String, completion: @escaping (Message?) -> Void) {
    let device_id = getDeviceId()
    let body: [String: Any] = [
        "token": getAccountToken(),
        "device_id": device_id,
        "from_app": "ios",
        "firebase_token": data
    ]
    let url = NetworkManager.shared.constructURL(endpoint: "user/firebaseToken")
    NetworkManager.shared.performRequest(url: url, body: body) { (result: Message?) in
        print("Notification result is \(String(describing: result))")
        completion(result)
    }
}
