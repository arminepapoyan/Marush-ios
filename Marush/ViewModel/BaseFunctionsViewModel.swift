//
//  BaseFunctionsViewModel.swift
//  Marush
//
//  Created by s2s s2s on 18.02.2026.
//
import Foundation

func AddToCart(data: ProductAddToCart, completion: @escaping (Message?) -> Void) {
//        let url = NetworkManager.shared.constructURL(endpoint: "test/error")
//    print("ProductAddToCart is \(data.productID) AND \(data.count) AND \(data.selectedFeatures)")
        let url = NetworkManager.shared.constructURL(endpoint: "cart/add")
        let body: [String: Any] = [
            "token": getAccountToken(),
            "device_id": getDeviceId(),
            "product_id": data.productID,
            "count": data.count,
            "from_app": "ios"
        ]
        
    NetworkManager.shared.performRequest(url: url, body: body){ (result: Message?) in
        completion(result)
    }
}
