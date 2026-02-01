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
    @Published var show_loading: Bool = true
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
        print("Notification result is \(result)")
        completion(result)
    }
}
