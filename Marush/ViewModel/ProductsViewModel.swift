
//
//  ProductsViewModel.swift
//  Marush
//
//  Created by s2s s2s on 27.03.2026.
//

import Foundation
import Combine

class ProductsViewModel: ObservableObject {
    @Published var products: [Product] = []
    
    init() {
        self.getData(data: SearchProductRequest(search: "")) { data in
            if let data = data {
//                print("App data received: \(data)")
                self.updateData(data)
                print("ProductsViewModel data success")
            } else {
                print("Failed to retrieve shop data")
            }
        }
    }
    
    // Fetch data from the API
    func getData(data: SearchProductRequest, completion: @escaping (SearchProduct?) -> Void) {
        let url = NetworkManager.shared.constructURL(endpoint: "products")
        var body: [String: Any] = [
            "token": getAccountToken(),
            "from_app": "ios"
        ]
        
        if !data.search.isEmpty {
            body["search"] = data.search
        }
        
        NetworkManager.shared.performRequest(url: url, body: body) { (result: SearchProduct?) in
            completion(result)
        }
    }
    
    func updateData(_ data: SearchProduct) {
        DispatchQueue.main.async {
            self.products = data.products ?? []
        }
    }
}
