//
//  Product.swift
//  Marush
//
//  Created by s2s s2s on 04.03.2026.
//

import Foundation

struct ProductResponse: Codable {
    let status: Int
    let message: String
    let product: Product
}

struct ProductCategory: Codable, Identifiable {
    let id: String
    let parentId: String
    let name: String
    let position: String?
    let appImage: String?
    let active: Bool
    let products: [Product]

    enum CodingKeys: String, CodingKey {
        case id
        case parentId = "parent_id"
        case name
        case position
        case appImage = "app_image"
        case active
        case products
    }
}
struct Product: Codable, Identifiable {
    let id: String
    let name: String
    let desc: String
    let url: String?
    let categoryId: String?
    let categoryName: String?
    let categories: [Category]?
    let uid: String?
    let sku: String?
    let categoryUrl: String?
    let image: String?
    let appImage: String?
    let otherImages: [String]
    let price: Double
    let oldPrice: Double
    let hasDiscount: Int
    let cartStep: Int
    let cartMin: Int
    let cartId: IntOrString
    let cartCount: Int
    var inWishlist: Bool
    let outOfStock: Bool
    let groupName: String?
    let groupColor: String?
    let groups: [ProductGroup]

    enum CodingKeys: String, CodingKey {
        case id, name, desc, url
        case categoryId = "category_id"
        case categoryName = "category_name"
        case categories
        case uid, sku
        case categoryUrl = "category_url"
        case image
        case appImage = "app_image"
        case otherImages = "other_images"
        case price
        case oldPrice = "old_price"
        case hasDiscount = "has_discount"
        case cartStep = "cart_step"
        case cartMin = "cart_min"
        case cartId = "cart_id"
        case cartCount = "cart_count"
        case inWishlist = "in_wishlist"
        case outOfStock = "out_of_stock"
        case groupName = "group_name"
        case groupColor = "group_color"
        case groups
    }
}

struct ProductGroup: Codable, Identifiable {
    let id: String
    let name: String
    let badgeName: String?
    let color: String?
    let showBadge: Bool

    enum CodingKeys: String, CodingKey {
        case id, name
        case badgeName = "badge_name"
        case color
        case showBadge = "show_badge"
    }
}
struct ProductPriceInfo: Codable {
    let productID: String
    let selectedFeatures: [Int: String]
}

struct ProductPriceResponse: Codable {
    let status: Int
    let price: Int
    let oldPrice: Int?
    let bonusPrice: Int?
    
    enum CodingKeys: String, CodingKey {
        case status
        case price
        case oldPrice = "old_price"
        case bonusPrice = "bonus_price"
    }
}

struct Wishlist: Identifiable, Codable {
    let id = UUID()
    let count: Int
    let products: [Product]
}

struct SearchProduct: Codable {
    let products: [Product]
    let totalCount: Int

    // Custom Coding Keys
    enum CodingKeys: String, CodingKey {
        case products
        case totalCount = "total_count"
    }
}

struct SearchProductRequest{
    let search: String
}
