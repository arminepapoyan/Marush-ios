//
//  AuthorizationViewModel.swift
//  Marush
//
//  Created by s2s s2s on 31.01.2026.
//

import Foundation

// MARK: - API Functions
// Login user
/// Signs in with either identifier. Only the one in use is sent, matching the
/// `errors.phone` / `errors.email` keys the API answers with.
func login(phone: String, email: String = "", password: String, completion: @escaping (Message?) -> Void) {
    let url = NetworkManager.shared.constructURL(endpoint: "login/run")
    var body: [String: Any] = [
        "device_id": getDeviceId(),
        "password": password,
        "from_app": "ios"
    ]
    if email.isEmpty {
        body["phone"] = phone
    } else {
        body["email"] = email
    }
    
    NetworkManager.shared.performRequest(url: url, body: body){ (result: Message?) in
        completion(result)
    }
}
// Send registration code
func sendRegisterCode(data: Registration, completion: @escaping (Message?) -> Void) {
    let url = NetworkManager.shared.constructURL(endpoint: "user/add")
    let body: [String: Any] = [
        "device_id": getDeviceId(),
        "name": data.name,
        "lastname": data.lastname,
        "email": data.email,
        "phone": data.phone,
//        "date_of_birth": data.date_of_birth,
        "password": data.password,
        "repeat_password": data.repeat_password,
        "code" : data.code,
        "code_type": data.code_type,
//        "gender": data.gender,
        "from_app": "ios"
    ]
    
    NetworkManager.shared.performRequest(url: url, body: body){ (result: Message?) in
        completion(result)
    }
}

func updateUserData(data: UpdateUser, completion: @escaping (Message?) -> Void) {
    let url = NetworkManager.shared.constructURL(endpoint: "user/edit")
    let body: [String: Any] = [
        "token": getAccountToken(),
        "device_id": getDeviceId(),
        "name": data.name ?? "",
        "lastname": data.lastname ?? "",
        "phone": data.phone ?? "",
        "email": data.email ?? "",
        "date_of_birth": data.date_of_birth ?? "",
        "from_app": "ios"
    ]
    
    NetworkManager.shared.performRequest(url: url, body: body){ (result: Message?) in
        completion(result)
    }
}

func updateUserPassword(data: UpdateUserPassword, completion: @escaping (Message?) -> Void) {
    let url = NetworkManager.shared.constructURL(endpoint: "user/editPassword")
    let body: [String: Any] = [
        "token": getAccountToken(),
        "device_id": getDeviceId(),
        "current_password": data.current_password,
        "new_password": data.new_password,
        "repeat_password": data.repeat_password,
        "from_app": "ios"
    ]
    
    NetworkManager.shared.performRequest(url: url, body: body){ (result: Message?) in
        completion(result)
    }
}

func forgetPassword(data: ForgotPassword, completion: @escaping (Message?) -> Void) {
    let url = NetworkManager.shared.constructURL(endpoint: "user/forgetPassword")
    let body: [String: Any] = [
        "device_id": getDeviceId(),
        "email": data.email,
        "code": data.code,
        "password": data.password,
        "repeat_password": data.password_repeat,
        "from_app": "ios"
    ]
    
    NetworkManager.shared.performRequest(url: url, body: body){ (result: Message?) in
        completion(result)
    }
}

