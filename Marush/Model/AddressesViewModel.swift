//
//  AddressesViewModel.swift
//  Marush
//
//  Created by s2s s2s on 04.04.2026.
//

import Foundation
import Combine

class AddressesViewModel: ObservableObject {
    
    @Published var data: [Address] = []
    
    init() {
        self.getData { data in
            if let data = data {
                self.updateData(data)
                print("App Data success")
            } else {
                print("Failed to retrieve app data")
            }
        }
    }
    
    // Fetch data from the API
    func getData(completion: @escaping ([Address]?) -> Void) {
        let url = NetworkManager.shared.constructURL(endpoint: "address/get")
        let body: [String: Any] = [
            "token": getAccountToken(),
            "from_app": "ios"
        ]
        
        NetworkManager.shared.performRequest(url: url, body: body) { (result: [Address]?) in
            completion(result)
        }
    }
    
    private func updateData(_ data: [Address]) {
        DispatchQueue.main.async {
            self.data = data
        }
    }
}


func RemoveAddress(data: Address, completion: @escaping (Message?) -> Void) {
//    let url = NetworkManager.shared.constructURL(endpoint: "test/error")
    let url = NetworkManager.shared.constructURL(endpoint: "address/remove")
    let body: [String: Any] = [
        "token": getAccountToken(),
        "device_id": getDeviceId(),
        "from_app": "ios",
        "id": data.id
    ]
    
    NetworkManager.shared.performRequest(url: url, body: body){ (result: Message?) in
        completion(result)
    }
}


func MakeDefaultAddress(id: String, completion: @escaping (Message?) -> Void) {
    let url = NetworkManager.shared.constructURL(endpoint: "address/makeDefault")
    let body: [String: Any] = [
        "token": getAccountToken(),
        "device_id": getDeviceId(),
        "from_app": "ios",
        "id": id
    ]
    NetworkManager.shared.performRequest(url: url, body: body) { (result: Message?) in
        completion(result)
    }
}


func AddAddress(data: Address, completion: @escaping (Message?) -> Void) {
//    let url = NetworkManager.shared.constructURL(endpoint: "test/error")
    var url_endpoint: String = "address/add"
    if !data.id.isEmpty{
        url_endpoint = "address/edit"
    }
    let url = NetworkManager.shared.constructURL(endpoint: url_endpoint)
    let body: [String: Any] = [
        "token": getAccountToken(),
        "device_id": getDeviceId(),
        "from_app": "ios",
        "id": data.id,
        "address": data.address,
        "apartment": data.apartment,
        "building": data.building,
        "default": data.isDefault,
        "entrance": data.entrance,
        "floor": data.floor,
        "city": data.city,
        "domofon": data.domofon,
        "comment": data.comment,
        
    ]
    
    NetworkManager.shared.performRequest(url: url, body: body){ (result: Message?) in
        completion(result)
    }
}

