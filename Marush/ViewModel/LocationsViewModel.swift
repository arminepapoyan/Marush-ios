//
//  LocationsViewModel.swift
//  Marush
//
//  Created by s2s s2s on 07.04.2026.
//

import Foundation
import Combine

class LocationsViewModel: ObservableObject {
    
    @Published var data: [Location] = []
    
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
    func getData(completion: @escaping ([Location]?) -> Void) {
        let url = NetworkManager.shared.constructURL(endpoint: "shops/get")
        let body: [String: Any] = [
            "token": getAccountToken(),
            "from_app": "ios"
        ]
        
        NetworkManager.shared.performRequest(url: url, body: body) { (result: [Location]?) in
            completion(result)
        }
    }
    
   func updateData(_ data: [Location]) {
        DispatchQueue.main.async {
            self.data = data ?? []
        }
    }
}

