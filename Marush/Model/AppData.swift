//
//  AppData.swift
//  Marush
//
//  Created by s2s s2s on 31.01.2026.
//


import Foundation

struct AppData: Codable {
    let status: Int?
    let isLogin: Bool
    let categories: [Category]
    let productCategories: [ProductCategory]
    let productsBestseller: [Product]
    let productsNews: [Product]
    let cart: CartResponse?
    let phone: String?

    enum CodingKeys: String, CodingKey {
        case status
        case isLogin = "is_login"
        case categories
        case productCategories = "product_categories"
        case productsBestseller = "products_bestseller"
        case productsNews = "products_news"
        case cart
        case phone
    }
}

struct Category: Codable, Identifiable, Equatable {
    let id: String
    let parentId: String
    let name: String
    let desc: String?
    let url: String?
    let image: String?
    let bannerImage: String?
    let count: String?
    let appImage: String?
    let categories: [Category]?

    static func == (lhs: Category, rhs: Category) -> Bool {
        lhs.id == rhs.id
    }

    enum CodingKeys: String, CodingKey {
        case id
        case parentId = "parent_id"
        case name, desc, url, image
        case bannerImage = "banner_image"
        case count
        case appImage = "app_image"
        case categories
    }
}


//struct CartResponse: Codable {
//    let status: Int
//    let list: [CartItem]
//    let count: Int
//}
//struct CartItem: Codable {
//    let productId: String?
//    let count: Int?
//}

struct CartResponse: Codable {
    let status: Int
    let dbId: String?
    let list: [CartItem]
    let count: Int
    
    let productsTotal: Double
    let shippingTotal: Double
    let packagingTotal: Double
    let couponTotal: Double
    let total: Double
    
    let userBonusTotal: Double
    let usedBonusTotal: Double
    let bonusTotal: Double
    let bonusConverted: Double
    let bonusConvertedString: String?
    let bonusPercent: Double
    
    let checkoutUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case status
        case dbId = "db_id"
        case list
        case count
        case productsTotal = "products_total"
        case shippingTotal = "shipping_total"
        case packagingTotal = "packaging_total"
        case couponTotal = "coupon_total"
        case total
        case userBonusTotal = "user_bonus_total"
        case usedBonusTotal = "used_bonus_total"
        case bonusTotal = "bonus_total"
        case bonusConverted = "bonus_converted"
        case bonusConvertedString = "bonus_converted_string"
        case bonusPercent = "bonus_percent"
        case checkoutUrl = "checkout_url"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        status = try container.decode(Int.self, forKey: .status)
        dbId = try container.decodeIfPresent(String.self, forKey: .dbId)
        count = try container.decodeIfPresent(Int.self, forKey: .count) ?? 0
        
        // Safe decode for list: if it's not an array, fallback to empty
        if let listArray = try? container.decode([CartItem].self, forKey: .list) {
            list = listArray
        } else {
            list = []
        }
        
        productsTotal = try container.decodeIfPresent(Double.self, forKey: .productsTotal) ?? 0
        shippingTotal = try container.decodeIfPresent(Double.self, forKey: .shippingTotal) ?? 0
        packagingTotal = try container.decodeIfPresent(Double.self, forKey: .packagingTotal) ?? 0
        couponTotal = try container.decodeIfPresent(Double.self, forKey: .couponTotal) ?? 0
        total = try container.decodeIfPresent(Double.self, forKey: .total) ?? 0
        
        userBonusTotal = try container.decodeIfPresent(Double.self, forKey: .userBonusTotal) ?? 0
        usedBonusTotal = try container.decodeIfPresent(Double.self, forKey: .usedBonusTotal) ?? 0
        bonusTotal = try container.decodeIfPresent(Double.self, forKey: .bonusTotal) ?? 0
        bonusConverted = try container.decodeIfPresent(Double.self, forKey: .bonusConverted) ?? 0
        bonusConvertedString = try container.decodeIfPresent(String.self, forKey: .bonusConvertedString)
        bonusPercent = try container.decodeIfPresent(Double.self, forKey: .bonusPercent) ?? 0
        checkoutUrl = try container.decodeIfPresent(String.self, forKey: .checkoutUrl)
    }
}

struct CartItem: Codable, Identifiable {
    var id: String { cartId }
    let cartId: String
    let productId: String
    let count: Int
    let product: Product
    let realPrice: Double
    let price: Double
    let oldPrice: Double
    let outOfStock: Bool
    
    enum CodingKeys: String, CodingKey {
        case cartId = "cart_id"
        case productId = "product_id"
        case count
        case product
        case realPrice = "real_price"
        case price
        case oldPrice = "old_price"
        case outOfStock = "out_of_stock"
    }
}
