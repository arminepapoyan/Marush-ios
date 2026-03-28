//
//  CartViewModel.swift
//  Marush
//
//  Created by s2s s2s on 29.03.2026.
//

import Foundation
import Combine

class CartViewModel: ObservableObject {
    @Published var checkoutData: CheckoutResponse? = nil
    @Published var data: CartResponse?
    @Published var relatedProducts: [Product]?
    @Published var bonusNumbers: [Int]?
//    @Published var bonusInfo: [BonusInfo]?
    @Published var errorMessage: String?
    
    init() {
        self.getData { [weak self] data in
            DispatchQueue.main.async {
                if let data = data {
                    self?.updateData(data)
                    print("Cart Response Success:")
                } else {
                    self?.errorMessage = "Failed to retrieve cart data"
                    print("Failed to retrieve cart data")
                }
            }
        }
    }
    
    /// Fetches cart data from the server
    /// - Parameter completion: A closure that returns an optional `CheckoutResponse`
    func getData(completion: @escaping (CheckoutResponse?) -> Void) {
//        guard let url = NetworkManager.shared.constructURL(endpoint: "cart/get") else {
        guard let url = NetworkManager.shared.constructURL(endpoint: "cart/checkout") else {
            print("Failed to construct URL")
            DispatchQueue.main.async {
                self.errorMessage = "Invalid URL"
            }
            completion(nil)
            return
        }
        
        let body: [String: Any] = [
            "token": getAccountToken(),
            "from_app": "ios"
        ]
        
        NetworkManager.shared.performRequest(url: url, body: body) { (result: CheckoutResponse?) in
            completion(result)
        }
    }
    
    /// Updates the cart data
    /// - Parameter data: A `CheckoutResponse` object containing the updated cart data
    private func updateData(_ data: CheckoutResponse) {
        DispatchQueue.main.async {
            self.checkoutData = data
            self.data = data.cart
            self.relatedProducts = data.relatedProducts
            self.bonusNumbers = data.bonusNumbers
//            self.bonusInfo = data.bonusInfo
        }
    }
}


func UpdateCart(data: CartUpdate, completion: @escaping (CartResponse?) -> Void) {
//    let url = NetworkManager.shared.constructURL(endpoint: "test/error")
    let url = NetworkManager.shared.constructURL(endpoint: "cart/update")
    let body: [String: Any] = [
        "token": getAccountToken(),
        "device_id": getDeviceId(),
        "cart_id": data.cart_id,
        "count": data.count,
        "use_bonus_amount": data.use_bonus_amount ?? 0,
        "from_app": "ios"
    ]
    
    NetworkManager.shared.performRequest(url: url, body: body){ (result: CartResponse?) in
        completion(result)
    }
}

func RemoveFromCart(data: RemoveCartData, completion: @escaping (CheckoutResponse?) -> Void) {
//    let url = NetworkManager.shared.constructURL(endpoint: "test/error")
    let url = NetworkManager.shared.constructURL(endpoint: "cart/remove")
    let body: [String: Any] = [
        "token": getAccountToken(),
        "device_id": getDeviceId(),
        "cart_id": data.cart_id,
        "use_bonus_amount": data.use_bonus_amount ?? 0,
        "from_app": "ios"
    ]
    
    NetworkManager.shared.performRequest(url: url, body: body){ (result: CheckoutResponse?) in
        completion(result)
    }
}


func FetchCartData(data: FetchCardDataRequest, completion: @escaping (CheckoutResponse?) -> Void) {
//    let url = NetworkManager.shared.constructURL(endpoint: "test/error")
    let url = NetworkManager.shared.constructURL(endpoint: "cart/checkout")
    let body: [String: Any] = [
        "token": getAccountToken(),
        "device_id": getDeviceId(),
        "use_bonus_amount": data.useBonusAmount ?? 0,
        "shop_id": data.shopId ?? "0",
        "is_delivery": data.isDelivery ?? 0,
        "is_asap": data.isAsap ?? 1,
        "coupon": data.coupon ?? "",
        "from_app": "ios"
    ]
    
    NetworkManager.shared.performRequest(url: url, body: body){ (result: CheckoutResponse?) in
        completion(result)
    }
}
//func FetchCartData(data: Int, shopId: String = "", completion: @escaping (CheckoutResponse?) -> Void) {
////    let url = NetworkManager.shared.constructURL(endpoint: "test/error")
//    let url = NetworkManager.shared.constructURL(endpoint: "cart/checkout")
//    let body: [String: Any] = [
//        "token": getAccountToken(),
//        "device_id": getDeviceId(),
//        "use_bonus_amount": data,
//        "shop_id": shopId,
//        "from_app": "ios"
//    ]
//
//    NetworkManager.shared.performRequest(url: url, body: body){ (result: CheckoutResponse?) in
//        completion(result)
//    }
//}

func Checkout(data: CheckoutRunModel, completion: @escaping (Message?) -> Void) {
    let url = NetworkManager.shared.constructURL(endpoint: "order/add")
    let body: [String: Any] = [
        "token": getAccountToken(),
        "from_app": "ios",
        "is_delivery": data.is_delivery,
        "is_asap": data.is_asap,
        "shop_id": data.shop_id,
        "billing_address": data.billing_address,
        "billing_apartment": data.billing_apartment,
        "billing_building": data.billing_building,
        "billing_entrance": data.billing_entrance,
        "billing_floor": data.billing_floor,
        "delivery_time": data.delivery_time,
        "payment_method": data.payment_method,
        "use_bonus_amount": data.use_bonus_amount,
        "billing_name": data.billing_name,
        "billing_lastname": data.billing_lastname,
        "billing_email": data.billing_email,
        "billing_phone": data.billing_phone,
        "billing_comment": data.billing_comment,
        "comment": data.billing_comment,
        "coupon": data.coupon,
        "save_card": data.save_card ? 1 : 0,
        "user_card_id": data.user_card_id
    ]
    
    NetworkManager.shared.performRequest(url: url, body: body) { (result: Message?) in
        completion(result)
    }
}
