//
//  OrdersViewModel.swift
//  Marush
//
//  Created by s2s s2s on 11.04.2026.
//

import Foundation
import Combine

class OrdersViewModel: ObservableObject {
    
    @Published var data: [Order] = []
    
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
    func getData(completion: @escaping (Message?) -> Void) {
        let url = NetworkManager.shared.constructURL(endpoint: "order/get")
        let body: [String: Any] = [
            "token": getAccountToken(),
            "from_app": "ios"
        ]
        
        NetworkManager.shared.performRequest(url: url, body: body) { (result: Message?) in
            completion(result)
        }
    }
    
    func updateData(_ data: Message) {
        DispatchQueue.main.async {
            self.data = data.orders ?? []
        }
    }
}

func getOrder(data: Int, completion: @escaping (Message?) -> Void) {
//    let url = NetworkManager.shared.constructURL(endpoint: "test/error")
    var url_endpoint: String = "order/get"
    let url = NetworkManager.shared.constructURL(endpoint: url_endpoint)
    let body: [String: Any] = [
        "token": getAccountToken(),
        "device_id": getDeviceId(),
        "from_app": "ios",
        "order_id": data
    ]
    
    NetworkManager.shared.performRequest(url: url, body: body){ (result: Message?) in
        completion(result)
    }
}

func Reorder(data: Int, completion: @escaping (Message?) -> Void) {
//    let url = NetworkManager.shared.constructURL(endpoint: "test/error")
    var url_endpoint: String = "order/repeat"
    let url = NetworkManager.shared.constructURL(endpoint: url_endpoint)
    let body: [String: Any] = [
        "token": getAccountToken(),
        "device_id": getDeviceId(),
        "from_app": "ios",
        "order_id": data
    ]
    
    NetworkManager.shared.performRequest(url: url, body: body){ (result: Message?) in
        print("Reorder response \(result)")
        completion(result)
    }
}


func addOrderReview(order_id: Int, review_star: Int, review: String, completion: @escaping (Message?) -> Void){
    var url_endpoint: String = "order/review"
    let url = NetworkManager.shared.constructURL(endpoint: url_endpoint)
    let body: [String: Any] = [
        "order_id": order_id,
        "review_star": review_star,
        "review": review,
        "token": getAccountToken(),
        "device_id": getDeviceId(),
        "from_app": "ios"
    ]
    
    NetworkManager.shared.performRequest(url: url, body: body){ (result: Message?) in
        print("addOrderReview response \(result)")
        completion(result)
    }
}
