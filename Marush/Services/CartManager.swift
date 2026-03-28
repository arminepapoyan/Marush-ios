//
//  CartManager.swift
//  Marush
//
//  Created by s2s s2s on 28.03.2026.
//

import Foundation
import Combine

class CartManager: ObservableObject {
    static let shared = CartManager()
    private init() {}

    @Published var items: [String: Int] = [:]

    func setCount(_ count: Int, for productId: String) {
        DispatchQueue.main.async {
            if count <= 0 {
                self.items.removeValue(forKey: productId)
            } else {
                self.items[productId] = count
            }
        }
    }

    func count(for productId: String) -> Int {
        items[productId] ?? 0
    }

    func load(from cart: CartResponse?) {
        guard let cart = cart else { return }
        var newItems: [String: Int] = [:]
        for item in cart.list {
            newItems[item.productId] = item.count
        }
        DispatchQueue.main.async {
            self.items = newItems
        }
    }
}
