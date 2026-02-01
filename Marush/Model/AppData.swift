//
//  AppData.swift
//  Marush
//
//  Created by s2s s2s on 31.01.2026.
//


import Foundation

struct AppData: Codable {
    let isLogin: Bool
    let categories: [Category]
    let productCategories: [ProductCategory]
    let productsBestseller: [Product]
    let productsNews: [Product]
    let cart: CartResponse?
    let phone: String?

    enum CodingKeys: String, CodingKey {
        case isLogin = "is_login"
        case categories
        case productCategories = "product_categories"
        case productsBestseller = "products_bestseller"
        case productsNews = "products_news"
        case cart
        case phone
    }
}

struct Category: Codable, Identifiable {
    let id: String
    let parentId: String
    let name: String
    let display: String?
    let position: String?
    let desc: String?
    let url: String?
    let image: String?
    let bannerImage: String?
    let count: String?
    let metaTitle: String?
    let metaDescription: String?
    let appImage: String?
    let categories: [Category]?

    enum CodingKeys: String, CodingKey {
        case id
        case parentId = "parent_id"
        case name, display, position, desc, url, image
        case bannerImage = "banner_image"
        case count
        case metaTitle = "meta_title"
        case metaDescription = "meta_description"
        case appImage = "app_image"
        case categories
    }
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
    let desc: String?
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
    let cartId: Int
    let cartCount: Int
    let inWishlist: Bool
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

struct CartResponse: Codable {
    let status: Int
    let list: [CartItem]
    let count: Int
}
struct CartItem: Codable {
    let productId: String
    let count: Int
}

