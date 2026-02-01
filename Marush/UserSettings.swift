//
//  UserSettings.swift
//  Marush
//
//  Created by S2S Company on 30.01.2026.
//

import Foundation
import Combine

class UserSettings: ObservableObject{
    static let shared = UserSettings()
    
    @Published var isLogined: Bool{
        didSet{
            UserDefaults.standard.set(isLogined,forKey: "isLogined")
        }
    }
    @Published var isFirebaseTokenSent: Bool{
        didSet{
            UserDefaults.standard.set(isFirebaseTokenSent,forKey: "isFirebaseTokenSent")
        }
    }
    @Published var appLang: String{
        didSet{
            UserDefaults.standard.set(appLang,forKey: "lang")
        }
    }
    @Published var isLang: String{
        didSet{
            UserDefaults.standard.set(isLang,forKey: "lang")
        }
    }
    @Published var account_uid: String{
        didSet{
            UserDefaults.standard.set(account_uid,forKey: "account_uid")
        }
    }
    
    @Published var device_id: String{
        didSet{
            UserDefaults.standard.set(device_id,forKey: "device_id")
        }
    }
    
    @Published var favorite_shop_id: Int {
        didSet{
            UserDefaults.standard.set(favorite_shop_id,forKey: "favorite_shop_id")
        }
    }
    
    @Published var userInfo: User? = nil {
        didSet{
            if let encoded = try? JSONEncoder().encode(userInfo) {
                UserDefaults.standard.set(encoded,forKey: "userInfo")
            } else {
                UserDefaults.standard.set(nil,forKey: "userInfo")
            }
            
        }
    }
    
    
    
    @Published var resetNavigationID = UUID()
    
//    @Published var cart_count = 0
    private var _cart_count: Int = 0
    var cart_count: Int {
        get { _cart_count }
        set {
            _cart_count = newValue
            UserSettings.shared._cart_count = newValue
            objectWillChange.send()
        }
    }
    
    
    @Published var wish_count = 0
    @Published var noti_count = 0
    
    @Published var showAlert: Bool = false
    @Published var alertType = ""
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    @Published var alertData = ""
    @Published var alertDataId = 0
    @Published var alertSuccess = 0
    @Published var alertCartId = 0
    @Published var allertuid = UUID()
    @Published var cartUid = UUID()
    @Published var showLoading: Bool = false
    @Published var showMiniAlert: Bool = false
    @Published var paymentStatus: Bool = false
    @Published var showPayment: Bool = false
    @Published var paymentUrl: String = ""
    @Published var showOrderAlert: Bool = false
    @Published var orderNav: Bool = false
    @Published var discount_image:String = ""
    @Published var show_home_message:Bool = false
    @Published var showProductDialog = false
    @Published var showCartDialog = false
    @Published var dialogProducId: String = ""
    @Published var orderId: Int = 0
    
//    Added
    @Published var show_version:Bool = false
    @Published var show_version_message:String = ""
    @Published var selection: Int = 0
    
//    @Published var orderPaymentResult: OrderPaymentResult = OrderPaymentResult()
    @Published var customDialog: CustomAlert = CustomAlert()
//    @Published var reorderDefaultData: ReorderDefaultData = ReorderDefaultData()
    
    @Published var wishlistProducts: [String] = []
    init(){
        self.isLogined = getIsLogined()
        self.isFirebaseTokenSent = getIsFirebaseTokenSent()
        self.appLang = getLang()
        self.isLang = UserDefaults.standard.string(forKey: "lang") ?? ""
        self.account_uid = getAccountToken()
        self.device_id = getDeviceId()
        self.favorite_shop_id = getFavoriteShopId()
        self.userInfo = getUserInfo()
        
    }
}


func getLocalString(string : String) -> String {
    let language = getLang()
    let path = Bundle.main.path(forResource: language, ofType: "lproj")
    let bundle = Bundle(path: path!)
    let translate_string = bundle!.localizedString(forKey: string, value: nil, table: nil)
    return translate_string;
}
