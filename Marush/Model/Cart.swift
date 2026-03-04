
//
//  Cart.swift
//  Marush
//
//  Created by s2s s2s on 18.02.2026.
//

import Foundation

//struct CheckoutResponse: Codable {
//    let cart: CartResponse
//    let bonusInfo: [BonusInfo]?
//    let relatedProducts: [Product]?
//    let addresses: [Address]?
//    let shops: [Shop]?
//    let paymentMethods: [PaymentMethod]?
//    let bonusNumbers: [Int]?
//    let deliveryDefaultDate: String?
//    let deliveryDefaultTime: String?
//    let minTime: String?
//    let maxTime: String?
//    let disableDelivery: Bool?
//    let cardsList: [CardsList]?
//    
//    enum CodingKeys: String, CodingKey {
//        case cart
//        case bonusInfo = "bonus_info"
//        case relatedProducts = "related_products"
//        case addresses, shops
//        case paymentMethods = "payment_methods"
//        case bonusNumbers = "bonus_numbers"
//        case deliveryDefaultDate = "delivery_default_date"
//        case deliveryDefaultTime = "delivery_default_time"
//        case minTime = "min_time"
//        case maxTime = "max_time"
//        case disableDelivery = "disable_delivery"
//        case cardsList = "cards"
//    }
//}
//
//
//// Root Model
//struct CartResponse: Codable {
//    let status: Int
//    let dbID: String?
//    var list: [CartItem]
//    let count: Int?
//    let noDelivery: Bool?
//    let productsTotal, shippingTotal, total: Int?
//    let userBonusTotal: String?
//    let usedBonusTotal, bonusTotal, bonusConverted: Int?
//    let bonusConvertedString, checkoutURL: String?
//    let couponTotal: Double?
//
//    // Custom Coding Keys
//    enum CodingKeys: String, CodingKey {
//        case status
//        case dbID = "db_id"
//        case list
//        case count
//        case noDelivery = "no_delivery"
//        case productsTotal = "products_total"
//        case shippingTotal = "shipping_total"
//        case total
//        case userBonusTotal = "user_bonus_total"
//        case usedBonusTotal = "used_bonus_total"
//        case bonusTotal = "bonus_total"
//        case bonusConverted = "bonus_converted"
//        case bonusConvertedString = "bonus_converted_string"
//        case checkoutURL = "checkout_url"
//        case couponTotal = "coupon_total"
//    }
//}
//
//// Cart Item Model
//struct CartItem: Codable, Identifiable {
//    let id = UUID()
//    let cartID: String
//    let productID: IntOrString
//    let count: Int
//    let features: [String: IntOrString] // Mixed Int/String values
//    let product: Product
//    let realPrice, price, oldPrice: Int
//    let outOfStock: Bool
//    let bonusPrice, bonusRealPrice: Int
//    let selectedFeatures: [SelectedFeature]?
//
//    // Custom Coding Keys
//    enum CodingKeys: String, CodingKey {
//        case id
//        case cartID = "cart_id"
//        case productID = "product_id"
//        case count
//        case features
//        case product
//        case realPrice = "real_price"
//        case price
//        case oldPrice = "old_price"
//        case outOfStock = "out_of_stock"
//        case bonusPrice = "bonus_price"
//        case bonusRealPrice = "bonus_real_price"
//        case selectedFeatures = "selected_features"
//    }
//    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        cartID = try container.decode(String.self, forKey: .cartID)
//        productID = try container.decode(IntOrString.self, forKey: .productID)
//        count = try container.decode(Int.self, forKey: .count)
//        features = (try? container.decode([String: IntOrString].self, forKey: .features)) ?? [:]
//        product = try container.decode(Product.self, forKey: .product)
//        realPrice = try container.decode(Int.self, forKey: .realPrice)
//        price = try container.decode(Int.self, forKey: .price)
//        oldPrice = try container.decode(Int.self, forKey: .oldPrice)
//        outOfStock = try container.decode(Bool.self, forKey: .outOfStock)
//        bonusPrice = try container.decode(Int.self, forKey: .bonusPrice)
//        bonusRealPrice = try container.decode(Int.self, forKey: .bonusRealPrice)
//        selectedFeatures = (try? container.decode([SelectedFeature].self, forKey: .selectedFeatures)) ?? nil
//    }
//}

struct CartUpdate: Codable{
    let cart_id: String
    let count: Int
    let use_bonus_amount: Int?
}

struct RemoveCartData: Codable{
    let cart_id: String
    let use_bonus_amount: Int?
}

struct ProductAddToCart: Codable{
    let productID: String
    let count: Int
}

//struct Shop: Codable, Identifiable, Hashable{
//    let id: String
//    let name: String
//    let address: String
//    let image: String
//    let hours: String
//    let coordinates: [String]
//    let startTime: String
//    let endTime: String
//    let disabled: Bool
//    let disabledMessage: String
//
//    enum CodingKeys: String, CodingKey {
//        case id
//        case name
//        case address
//        case image
//        case hours
//        case coordinates
//        case startTime = "start_time"
//        case endTime = "end_time"
//        case disabled
//        case disabledMessage = "disabled_message"
//    }
//    
//    static func == (lhs: Shop, rhs: Shop) -> Bool {
//        return lhs.id == rhs.id
//    }
//
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(id)
//    }
//}
//
//
//struct Address: Identifiable, Codable, Hashable {
//    var id: String
//    var title: String
//    var address: String
//    var building: String
//    var apartment: String
//    var entrance: String
//    var floor: String
//    var isDefault: Int
//
//    enum CodingKeys: String, CodingKey {
//        case id
//        case title
//        case address
//        case building
//        case apartment
//        case entrance
//        case floor
//        case isDefault = "default"
//    }
//    
//    static func == (lhs: Address, rhs: Address) -> Bool {
//        return lhs.id == rhs.id
//    }
//
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(id)
//    }
//}
//
//struct PaymentMethod: Identifiable, Codable {
//    let id = UUID() // Unique identifier for SwiftUI usage
//    let key: String
//    let name: String
//    let icon: String
//    
//    // Custom initializer to decode JSON and map "show_title" to `showTitle`
//    private enum CodingKeys: String, CodingKey {
//        case key
//        case name
//        case icon
//    }
//}
//
//struct CheckoutRunModel{
//    var is_delivery: Int = 0
//    var is_asap: Int = 1
//    var shop_id: String = ""
//    var billing_address: String = ""
//    var billing_apartment: String = ""
//    var billing_building: String = ""
//    var billing_entrance: String = ""
//    var billing_floor: String = ""
//    var delivery_time: String = ""
//    var payment_method: String = ""
//    var use_bonus_amount: Int = 0
//    
//    var billing_name: String = ""
//    var billing_lastname: String = ""
//    var billing_email: String = ""
//    var billing_phone: String = ""
//    var billing_comment: String = ""
//    
//    var coupon: String = ""
//    var save_card: Bool = true
//    var user_card_id: Int = 0
//}
//
//struct ValidateCheckout{
//    var wrongname: Bool = false
//    var wronglastname: Bool = false
//    var wrongemail: Bool = false
//    var wrongphone: Bool = false
//}
//
//
//struct Order: Codable, Identifiable{
//    let id: Int
//    let billingName: String
//    let billingLastname: String
//    let billingPhone: String
//    let billingEmail: String
//    let billingAddress: String?
//    let billingAddressFull: String?
//    let billingBuilding: String?
//    let billingApartment: String?
//    let billingFloor: String?
//    let billingEntrance: String?
//    let statusName: String
//    let isDelivery: Bool
//    let deliveryDate: String?
//    let deliveryTime: String?
//    let comment: String
//    let paymentMethod: PaymentMethod
//    let productsTotal: Double
//    let shippingTotal: Double
//    let bonusTotal: Double
//    let bonusGotTotal: Double
//    let total: Double
//    let payed: Bool
//    let coupon: String?
//    let products: [OrderedProduct]
//    let shop: Shop?
//    let statusId: Int?
//    let statusDesc: String?
//    let statusImage: String?
//    let stepCount: Int?
//    let stepNow: Int?
//    let isFinished: Bool?
//    let isCancelled: Bool?
//    let waitingTime: String?
//    let couponTotal: Double?
//    
//    private enum CodingKeys: String, CodingKey {
//        case id
//        case billingName = "billing_name"
//        case billingLastname = "billing_lastname"
//        case billingPhone = "billing_phone"
//        case billingEmail = "billing_email"
//        case billingAddress = "billing_address"
//        case billingAddressFull = "billing_address_full"
//        case billingBuilding = "billing_building"
//        case billingApartment = "billing_apartment"
//        case billingFloor = "billing_floor"
//        case billingEntrance = "billing_entrance"
//        case statusName = "status_name"
//        case isDelivery = "is_delivery"
//        case deliveryDate = "delivery_date"
//        case deliveryTime = "delivery_time"
//        case comment
//        case paymentMethod = "payment_method"
//        case productsTotal = "products_total"
//        case shippingTotal = "shipping_total"
//        case bonusTotal = "bonus_total"
//        case bonusGotTotal = "bonus_got_total"
//        case total,payed, coupon
//        case products, shop
//        case statusId = "status_id"
//        case statusDesc = "status_desc"
//        case statusImage = "status_image"
//        case stepCount = "step_count"
//        case stepNow = "step_now"
//        case isFinished = "is_finished"
//        case isCancelled = "is_cancelled"
//        case waitingTime = "waiting_time"
//        case couponTotal = "coupon_total"
//    }
//  
//}
//
//struct OrderedProduct: Codable, Identifiable{
//    let id = UUID()
//    let price: String
//    let count: String?
//    let total: String?
//    let bonusTotal: String?
//    let product: Product?
//    let selectedFeatures: [SelectedFeatures]?
//    
//    private enum CodingKeys: String, CodingKey {
//        case id
//        case price, count, total
//        case bonusTotal = "bonus_total"
//        case product
//        case selectedFeatures = "selected_features"
//    }
//}
//
//struct OrderPaymentResult {
//    var showPaymentDialog: Bool = false
//    var getOrderAlertTitle: String = ""
//    var getOrderAlertMessage: String = ""
//    var iconType: Int = 0
//}
//struct ReorderDefaultData {
//    var shopId: String = ""
//    var shopName: String = ""
//    var isAsap: Bool = true
//    var paymentMethod: String = ""
//}
//
//struct CustomAlert {
//    var showDialog: Bool = false
//    var title: String = ""
//    var message: String = ""
//    var iconType: Int = 0
//}
//
//
//struct OngoingResult: Codable{
//    let order: Order?
//    
//    private enum CodingKeys: String, CodingKey {
//        case order
//    }
//}
//
//
//struct FetchCardDataRequest{
//    var useBonusAmount: Int?
//    var isDelivery: Int?
//    var isAsap: Int?
//    var shopId: String?
//    var coupon: String?
//    
//    
//    init(
//        useBonusAmount: Int? = 0,
//        isDelivery: Int? = 0,
//        isAsap: Int? = 1,
//        shopId: String? = "0",
//        coupon: String? = ""
//    ) {
//        self.useBonusAmount = useBonusAmount
//        self.isDelivery = isDelivery
//        self.isAsap = isAsap
//        self.shopId = shopId
//        self.coupon = coupon
//    }
//}
//
//struct CardsList: Codable, Identifiable{
//    let id: Int
//    let cardCode: String
//    let cardName: String
//    let expDate: String
//    let isDefault: Bool
//    let userName: String?
//    
//    
//    private enum CodingKeys: String, CodingKey {
//        case id
//        case cardCode = "card_code"
//        case cardName = "card_name"
//        case expDate = "exp_date"
//        case isDefault = "default"
//        case userName = "user_name"
//    }
//}
