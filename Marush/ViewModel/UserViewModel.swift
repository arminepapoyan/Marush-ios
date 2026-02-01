//
//  UserViewModel.swift
//  Marush
//
//  Created by s2s s2s on 01.02.2026.
//

import Foundation
import Combine


class UserViewModel: ObservableObject{
    
    @Published var id : String = ""
    @Published var organization_id : String = ""
    @Published var uid: String = ""
    @Published var name : String = ""
    @Published var lastname : String = ""
    @Published var email : String = ""
    @Published var phone : String = ""
//    {
//       didSet {
//           self.qr_phone = removeSymbols(from: phone) // Update qr_phone whenever phone changes
//       }
//   }
    @Published var date_of_birth : String = ""
    @Published var password : String = ""
    @Published var image : String = ""
    @Published var gender : String = ""
//    @Published var order_count : Int = 0
//    @Published var bonus_total : Double = 0
//    @Published var qr_phone: String = ""
    @Published var email_notifications: String = ""
    @Published var push_notifications: String = ""
    
    init(){
        self.getUser { user in
            if let user = user {
                self.updateUserData(user)
            } else {
                print("Failed to retrieve user data")
            }
        }
    }
   
    // User Data
    func getUser(completion: @escaping (User?) -> Void) {
        let url = NetworkManager.shared.constructURL(endpoint: "user/get")
        let body: [String: Any] = [
            "token": getAccountToken(),
            "from_app": "ios"
        ]
        print("Account token is \(getAccountToken())")
        NetworkManager.shared.performRequest(url: url, body: body) { (result: User?) in
            print("User ger info is \(result)")
            completion(result)
        }
    }
    
    func updateUserData(_ user: User) {
        DispatchQueue.main.async {
            self.id = user.id
            self.organization_id = user.organization_id
            self.uid = user.uid ?? ""
            self.name = user.name
            self.lastname = user.lastname
            self.email = user.email
            self.phone = user.phone
            self.date_of_birth = user.date_of_birth ?? ""
            self.password = user.password
            self.image = user.image
            self.gender = user.gender ?? ""
//            self.order_count = user.order_count ?? 0
//            self.bonus_total = user.bonus_total
//            self.qr_phone = removeSymbols(from: user.phone) // Update qr_phone
            self.email_notifications = user.email_notifications ?? ""
            self.push_notifications = user.push_notifications ?? ""
        }
    }
}

func RemoveAccount(completion: @escaping (Message?) -> Void) {
//    let url = NetworkManager.shared.constructURL(endpoint: "test/error")
    let url = NetworkManager.shared.constructURL(endpoint: "user/delete")
    let body: [String: Any] = [
        "token": getAccountToken(),
        "device_id": getDeviceId(),
        "from_app": "ios"
    ]
    
    NetworkManager.shared.performRequest(url: url, body: body){ (result: Message?) in
        completion(result)
    }
}

func ChangeNotifications(data: Settings, completion: @escaping (Message?) -> Void) {
//    let url = NetworkManager.shared.constructURL(endpoint: "test/error")
    let url = NetworkManager.shared.constructURL(endpoint: "user/changeNotifications")
    let body: [String: Any] = [
        "token": getAccountToken(),
        "device_id": getDeviceId(),
        "email_notifications": data.emailNotification,
        "push_notifications": data.pushNotification,
        "lang": data.lang,
        "from_app": "ios"
    ]
    
    NetworkManager.shared.performRequest(url: url, body: body){ (result: Message?) in
        completion(result)
    }
}
//
//func uploadUserImage(image: Settings, completion: @escaping (Message?) -> Void){
//    let url = NetworkManager.shared.constructURL(endpoint: "user/editImage")
//    let body: [String: Any] = [
//        "token": getAccountToken(),
//        "device_id": getDeviceId(),
//        "from_app": "ios"
//    ]
//
//    NetworkManager.shared.performRequest(url: url, body: body){ (result: Message?) in
//        completion(result)
//    }
//}
//
enum ImageAction {
    case upload, delete
}

func updateUserImage(imageData: Data?, action: ImageAction, completion: @escaping (Message?) -> Void) {
    guard let url = NetworkManager.shared.constructURL(endpoint: "user/editImage") else {
        print("Invalid URL")
        completion(nil)
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"

    let boundary = UUID().uuidString
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

    var body = Data()
    let lineBreak = "\r\n"

    // Add token
    body.append("--\(boundary)\(lineBreak)")
    body.append("Content-Disposition: form-data; name=\"token\"\(lineBreak)\(lineBreak)")
    body.append("\(getAccountToken())\(lineBreak)")

    // Add device_id
    body.append("--\(boundary)\(lineBreak)")
    body.append("Content-Disposition: form-data; name=\"device_id\"\(lineBreak)\(lineBreak)")
    body.append("\(getDeviceId())\(lineBreak)")

    // Add from_app
    body.append("--\(boundary)\(lineBreak)")
    body.append("Content-Disposition: form-data; name=\"from_app\"\(lineBreak)\(lineBreak)")
    body.append("ios\(lineBreak)")

    // Handle image upload or deletion
    switch action {
    case .upload:
        guard let imageData = imageData else {
            print("No image data provided for upload")
            completion(nil)
            return
        }
        
        body.append("--\(boundary)\(lineBreak)")
        body.append("Content-Disposition: form-data; name=\"image[]\"; filename=\"profile.jpg\"\(lineBreak)")
        body.append("Content-Type: image/jpeg\(lineBreak)\(lineBreak)")
        body.append(imageData)
        body.append(lineBreak)

    case .delete:
        body.append("--\(boundary)\(lineBreak)")
        body.append("Content-Disposition: form-data; name=\"image[]\"; filename=\"\"\(lineBreak)")
        body.append("Content-Type: image/jpeg\(lineBreak)\(lineBreak)")
        body.append(Data())  // Empty data for deletion
        body.append(lineBreak)
    }

    // Close boundary
    body.append("--\(boundary)--\(lineBreak)")

    request.httpBody = body

    URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data, error == nil else {
            print("Upload error: \(error?.localizedDescription ?? "Unknown error")")
            completion(nil)
            return
        }

        do {
            let decoded = try JSONDecoder().decode(Message.self, from: data)
            completion(decoded)
        } catch {
            print("Decoding error: \(error)")
            completion(nil)
        }
    }.resume()
}

