//
//  Message.swift
//  Marush
//
//  Created by s2s s2s on 30.01.2026.
//


import Foundation

struct Message:Codable {
    var status : Int
    var errors: Errors?
    var token: String?
    var message: String?
    var title: String?
    var uid:String?
    var pin:String?
    var order_id:Int?
    var url:String?
    var redirect_url:String?
    var bin : Int?
    var image : String?
    var user_id : Int?
    var added : Bool?
    var user:User?
    var categories: [Category]?
    var orders: [Order]?
    var products: [Product]?
    var cart_count: Int?
}

struct Errors:Codable{
    var password: String?
    var email: String?
    var name: String?
    var lastname: String?
    var phone: String?
    var repeatpassword: String?
    var date_of_birth: String?
    var code: String?
    var current_password: String?
    var new_password: String?
    var repeat_password: String?
    var payment_method: String?
    var shop_id: String?
    var billing_address: String?
    var delivery_time: String?
}

struct Message_Add:Codable {
    var status : Int
    var message: String
}
