//
//  BaseFunctions.swift
//  Marush
//
//  Created by S2S Company on 30.01.2025.
//

import SwiftUI
import Combine

func getLang() -> String {
    guard let lang = UserDefaults.standard.string(forKey: "lang") else { return Lang.armenian.rawValue}
    return lang;
}

func getIsFirebaseTokenSent() -> Bool {
    if UserDefaults.standard.bool(forKey: "isFirebaseTokenSent") == false{
        return false
    }else {
        return true;
    }
}
func getIsLogined() -> Bool {
    if UserDefaults.standard.bool(forKey: "isLogined") == false{
        return false
    }else {
        return true;
    }
}
func getDeviceId() -> String {
    guard let device_id = UserDefaults.standard.string(forKey: "device_id") else {
        let uid = UUID()
        UserDefaults.standard.set("\(uid)",forKey: "device_id")
        return "\(uid)"
    }
    return device_id;
}
func getAccountToken() -> String {
    guard let account_uid = UserDefaults.standard.string(forKey: "account_uid") else {
        return ""
    }
    return account_uid;
}


func getAccountId() -> String {
    guard let account_uid = UserDefaults.standard.string(forKey: "account_uid") else {
        return ""
    }
    return account_uid;
}

func getFavoriteShopId() -> Int {
    if (UserDefaults.standard.integer(forKey: "favorite_shop_id") != 0){
        return UserDefaults.standard.integer(forKey: "favorite_shop_id")
    } else {
        return 0;
    }
}

func getUserInfo() -> User? {
    if let data = UserDefaults.standard.object(forKey: "userInfo") as? Data,
       
       let userInfo = try? JSONDecoder().decode(User.self, from: data) {
        return userInfo ;
    } else {
        return nil
    }
}


func getApiUrl()-> String{
    let lang = getLang()
    var url = "https://marush-admin.s2s.am/"
    if(lang == "hy"){
        url += "am/"
    } else if(lang == "ru"){
        url += "ru/"
    } else{
        url += "en/"
    }
    return url+"api/";
}

func getBaseUrl()-> String{
    let lang = getLang()
    var url = "ttps://marush-admin.s2s.am/"
    if(lang == "hy"){
        url += "am/"
    } else if(lang == "ru"){
        url += "ru/"
    } else{
        url += "en/"
    }
    return url;
}

func getLangName()-> String{
    let lang = getLang()
    var lang_name = "English"
    if(lang == "hy"){
        lang_name = "Հայերեն"
    } else if(lang == "ru"){
        lang_name = "Русский"
    } else{
        lang_name = "English"
    }
    return lang_name;
}


// Helper to Handle Mixed Int/String in `features`
enum IntOrString: Codable {
    case intValue(Int)
    case stringValue(String)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int.self) {
            self = .intValue(intValue)
        } else if let stringValue = try? container.decode(String.self) {
            self = .stringValue(stringValue)
        } else {
            throw DecodingError.typeMismatch(IntOrString.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Value is not Int or String"))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .intValue(let value):
            try container.encode(value)
        case .stringValue(let value):
            try container.encode(value)
        }
    }
}
