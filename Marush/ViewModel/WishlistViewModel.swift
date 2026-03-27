//
//  WishlistViewModel.swift
//  Marush
//
//  Created by s2s s2s on 04.03.2026.
//

import Foundation
import Combine

class WishlistViewModel: ObservableObject {
    
    @Published var products: [Product] = []
    
    init() {
        self.getData { data in
            if let data = data {
                self.updateData(data)
                print("App Data success")
            } else {
                print("Failed to retrieve app data")
            }
        }
    }
    
    // Fetch data from the API
    func getData(completion: @escaping (Wishlist?) -> Void) {
        let url = NetworkManager.shared.constructURL(endpoint: "wishlist/get")
        let body: [String: Any] = [
            "token": getAccountToken(),
            "from_app": "ios"
        ]
        
        NetworkManager.shared.performRequest(url: url, body: body) { (result: Wishlist?) in
            completion(result)
        }
    }
    
    private func updateData(_ data: Wishlist) {
        DispatchQueue.main.async {
            self.products = data.products ?? []
        }
    }
}



func AddToWishlist(productId: String, completion: @escaping (Message?) -> Void) {
        let url = NetworkManager.shared.constructURL(endpoint: "wishlist/change")
        let body: [String: Any] = [
            "token": getAccountToken(),
            "device_id": getDeviceId(),
            "product_id": productId,
            "from_app": "ios"
        ]
        
    NetworkManager.shared.performRequest(url: url, body: body){ (result: Message?) in
        completion(result)
    }
}
