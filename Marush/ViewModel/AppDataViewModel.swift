//
//  AppDataViewModel.swift
//  Marush
//
//  Created by s2s s2s on 30.01.2026.
//

import Foundation
import Combine

class AppDataViewModel: ObservableObject {
    
    @Published var status: Int = 200
    @Published var isLogin: Bool = true
    @Published var productCategories: [ProductCategory] = []
    @Published var productsBestseller: [Product] = []
    @Published var productsNews: [Product] = []
    @Published var categories: [Category] = []
    @Published var cart: CartResponse?
    @Published var phone: String? = ""
    @Published var addresses: [Address] = []
    
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
    func getData(completion: @escaping (AppData?) -> Void) {
        let url = NetworkManager.shared.constructURL(endpoint: "app/data")
        let body: [String: Any] = [
            "token": getAccountToken(),
            "from_app": "ios"
        ]
        
        NetworkManager.shared.performRequest(url: url, body: body) { (result: AppData?) in
            completion(result)
        }
    }
    
    func updateData(_ data: AppData) {
        print("Data received")
        DispatchQueue.main.async {
            self.status = data.status ?? 200
            self.isLogin = data.isLogin ?? false
            self.productCategories = data.productCategories ?? []
            self.productsBestseller = data.productsBestseller ?? []
            self.productsNews = data.productsNews ?? []
            self.categories = data.categories ?? []
            self.cart = data.cart
            self.phone = data.phone ?? ""
            self.addresses = data.addresses ?? []
            CartManager.shared.load(from: data.cart)
        }
    }
}

