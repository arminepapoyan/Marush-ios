//
//  Authorization.swift
//  Marush
//
//  Created by s2s s2s on 31.01.2026.
//


import Foundation

struct Registration:Codable {
    var name: String
    var lastname: String
    var email: String
    var phone: String
    var date_of_birth: String?
    var code_type: String
    var gender: String?
    var code: String?
    var password:String?
    var repeat_password:String?
}

struct ForgotPassword: Codable{
    var email: String
    var code: String?
    var password: String?
    var password_repeat: String?
}

