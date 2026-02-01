//
//  User.swift
//  Marush
//
//  Created by S2S Company on 30.01.2026.
//

struct User:Codable {
    var id : String
    var organization_id : String
    var uid: String?
    var name : String
    var lastname : String
    var email : String
    var phone : String
    var date_of_birth : String
    var password : String
    var image : String
    var gender : String?
    var order_count : Int?
    var email_notifications: String?
    var push_notifications: String?
    var notification_count: Int?
    var bonus_total: Double // Change to Int to match the JSON data type
   
   // Computed property to get qr_phone without storing it
    var qr_phone: String {
        return removeSymbols(from: phone)
    }
    
    // Custom initializer
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        organization_id = try container.decode(String.self, forKey: .organization_id)
        uid = try container.decode(String.self, forKey: .uid)
        name = try container.decode(String.self, forKey: .name)
        lastname = try container.decode(String.self, forKey: .lastname)
        email = try container.decode(String.self, forKey: .email)
        phone = try container.decode(String.self, forKey: .phone)
        date_of_birth = try container.decode(String.self, forKey: .date_of_birth)
        password = try container.decode(String.self, forKey: .password)
        image = try container.decode(String.self, forKey: .image)
        gender = try? container.decode(String.self, forKey: .gender) // Optional
        order_count = try? container.decode(Int.self, forKey: .order_count) // Optional
        
        // Handling bonus_total which might be a String or Int
        if let bonusString = try? container.decode(String.self, forKey: .bonus_total) {
            bonus_total = Double(bonusString) ?? 0 // Convert String to Int, defaulting to 0 if conversion fails
        } else {
            bonus_total = try container.decode(Double.self, forKey: .bonus_total) // Directly decode as Int
        }
    }
}

struct UpdateUser:Codable {
    var name: String?
    var lastname: String?
    var email: String?
    var date_of_birth: String?
    var gender: String?
//    var old_password:String?
//    var password:String?
//    var repeat_password:String?
}

struct UpdateUserPassword:Codable {
    var current_password:String?
    var new_password:String?
    var repeat_password:String?
}

struct Settings{
    var emailNotification: Int
    var pushNotification: Int
    var lang: String
}
