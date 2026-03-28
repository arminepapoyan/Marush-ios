
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
        self.getData(data: SearchProductRequest(search: nil, category_id: nil)) { data in
            if let data = data {
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

        if let search = data.search, !search.isEmpty {
            body["search"] = search
        }
        if let categoryId = data.category_id {
            body["category_id"] = categoryId
        }
        if let orderBy = data.order_by {
            body["order_by"] = orderBy
        }

        NetworkManager.shared.performRequest(url: url, body: body) { (result: SearchProduct?) in
            completion(result)
        }
    }

    // Used by SearchView (text search, no category)
    func loadData(search: String, completion: (() -> Void)? = nil) {
        getData(data: SearchProductRequest(search: search.isEmpty ? nil : search)) { data in
            if let data = data { self.updateData(data) }
            completion?()
        }
    }

    // Used by CategoryDetailView (category + optional sort)
    func loadData(categoryId: String?, orderBy: String? = nil, completion: (() -> Void)? = nil) {
        getData(data: SearchProductRequest(category_id: categoryId, order_by: orderBy)) { data in
            if let data = data { self.updateData(data) }
            completion?()
        }
    }

    func updateData(_ data: SearchProduct) {
        DispatchQueue.main.async {
            self.products = data.products ?? []
        }
    }
}
