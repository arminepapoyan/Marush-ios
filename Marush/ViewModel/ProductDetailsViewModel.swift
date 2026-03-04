//
//  ProductDetailsViewModel.swift
//  Gotcha
//
//  Created by s2s s2s on 04.11.2024.
//

//import Foundation
//import Combine
//
//class ProductDetailsViewModel: ObservableObject {
//    @Published var productData: Product?  // Product data from API response
//    @Published var errorMessage: String?
//    
//    init(productId: String) {
//        self.getData(productId: productId) { data in
//            if let data = data {
//                self.updateData(data)
//                print("Prouct data success")
//            } else {
//                print("Failed to retrieve product data")
//            }
//        }
//    }
//    
//    func getData(productId: String, completion: @escaping (ProductResponse?) -> Void) {
//        let url = NetworkManager.shared.constructURL(endpoint: "products/get")
//        let body: [String: Any] = [
//            "token": getAccountToken(),
//            "from_app": "ios",
//            "id": productId
//        ]
//        
//        NetworkManager.shared.performRequest(url: url, body: body) { (result: ProductResponse?) in
//            completion(result)
//        }
//    }
//    
//    private func updateData(_ data: ProductResponse) {
//        DispatchQueue.main.async {
//            self.productData = data.product
//        }
//    }
//}
//
//
//func GetProductPrice(data: ProductPriceInfo, completion: @escaping (ProductPriceResponse?) -> Void) {
////    let url = NetworkManager.shared.constructURL(endpoint: "test/error")
//    let url = NetworkManager.shared.constructURL(endpoint: "products/getPrice")
//    let body: [String: Any] = [
//        "token": getAccountToken(),
//        "device_id": getDeviceId(),
//        "features": data.selectedFeatures.mapKeys { String($0) },
//        "product_id": data.productID,
//        "from_app": "ios"
//    ]
//    
//    NetworkManager.shared.performRequest(url: url, body: body){ (result: ProductPriceResponse?) in
//        completion(result)
//    }
//}

//
//  ProductViewModel.swift
//  Marush
//
//  Created by s2s s2s on 18.02.2026.
//

