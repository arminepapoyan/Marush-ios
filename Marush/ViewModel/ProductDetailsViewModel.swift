//
//  ProductDetailsViewModel.swift
//  Marush
//
//  Created by s2s s2s on 04.03.2026.
//


import Foundation
import Combine

class ProductDetailsViewModel: ObservableObject {
    @Published var productData: Product? // Product data from API response
    @Published var errorMessage: String?
    
    init(productId: String) {
        self.getData(productId: productId) { data in
            if let data = data {
                self.updateData(data)
                print("Prouct data success")
            } else {
                print("Failed to retrieve product data")
            }
        }
    }
    
    func getData(productId: String, completion: @escaping (ProductResponse?) -> Void) {
        let url = NetworkManager.shared.constructURL(endpoint: "products/get")
        let body: [String: Any] = [
            "token": getAccountToken(),
            "from_app": "ios",
            "id": productId
        ]
        
        NetworkManager.shared.performRequest(url: url, body: body) { (result: ProductResponse?) in
            completion(result)
        }
    }
    
    private func updateData(_ data: ProductResponse) {
        DispatchQueue.main.async {
            self.productData = data.product
        }
    }
}
