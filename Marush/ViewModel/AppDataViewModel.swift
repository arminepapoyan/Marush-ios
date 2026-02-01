//
//  AppDataViewModel.swift
//  Marush
//
//  Created by s2s s2s on 30.01.2026.
//

import Foundation
import Combine

class AppDataViewModel: ObservableObject {
    
//    @Published var status: Int = 200
//    @Published var title: String = ""
//    @Published var text: String = ""
//    @Published var greetingTitle: String = ""
//    @Published var bannerImages: [HomeBannerImages] = [] // Update to array of dictionaries
//    @Published var productsBestseller: [Product] = []
//    @Published var newForYouImages: [NewForYou] = []
//    @Published var getStartedSlider: [StartImageSlider] = []
//    @Published var ongoingOrder: [Order]? = []
//    @Published var doneOrder: Order?
//    @Published var cart: CartResponse?
//    @Published var bonusInfo: [BonusInfo]?
    
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
    func getData(completion: @escaping (AppData?) -> Void) {
        let url = NetworkManager.shared.constructURL(endpoint: "app/data")
        let body: [String: Any] = [
            "token": getAccountToken(),
            "from_app": "ios"
        ]
        
        NetworkManager.shared.performRequest(url: url, body: body) { (result: AppData?) in
            completion(result)
        }
    }
    
    func updateData(_ data: AppData) {
        print("Data received")
        //        DispatchQueue.main.async {
        //            self.status = data.status ?? 200
        //            self.title = data.title ?? ""
        //            self.text = data.text ?? ""
        //            self.greetingTitle = data.greetingTitle ?? ""
        //            self.bannerImages = data.bannerImages ?? [] // Update for array type
        //            self.productsBestseller = data.productsBestseller ?? []
        //            self.newForYouImages = data.newForYouImages ?? []
        //            self.getStartedSlider = data.getStartedSlider ?? []
        //            self.doneOrder = data.doneOrder
        //            // Check if ongoingOrder is not nil and update accordingly
        //              if let ongoingOrder = data.ongoingOrder {
        //                  self.ongoingOrder = [ongoingOrder] // Wrap the single `Order` in an array
        //              } else {
        //                  self.ongoingOrder = [] // Set to an empty array if nil
        //              }
        //            self.cart = data.cart
        //            self.bonusInfo = data.bonusInfo ?? []
        //        }
    }
}

