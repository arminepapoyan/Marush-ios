//
//  GlobalFunctions.swift
//  Marush
//
//  Created by S2S Company on 30.01.2025.
//

import Foundation
import SwiftUI
//import IdramMerchantPayment

// Method to remove symbols from the phone number
 func removeSymbols(from phoneNumber: String) -> String {
     let allowedCharacters = phoneNumber.filter { $0.isNumber } // Keep only numeric characters
     return allowedCharacters
 }

//func getOrderData(_ settings: UserSettings, selection: Int = 3){
//    getOrder(data: settings.orderId){ res in
//        if let res = res, res.status == 200, let order = res.orders?.first {
//            handleGetOrder(order, settings: settings, selection: selection)
//        } else{
//            handlePaymentError(getLocalString(string: "wrond_command"), getLocalString(string: "there_was_problem_with_order_payment"), settings: settings)
//        }
//    }
//}
//
//func handleGetOrder(_ order: Order, settings: UserSettings, selection: Int = 3) {
//    if !order.payed && order.paymentMethod.key != "cash" {
//        print("Order is payed error")
//        handlePaymentError(getLocalString(string: "the_order_was_not_fulfilled"), getLocalString(string: "there_was_an_error_placing_the_order"), settings: settings)
//    } else if (order.paymentMethod.key == "cash") || (order.payed ) {
////        && order.paymentMethod.key == "idram"
//        print("Order is payed success")
//        handlePaymentSuccess(getLocalString(string: "order_is_placed"), String(format: NSLocalizedString("order_has_been_successfully_placed_message", comment: ""), "\(order.id)"), settings: settings)
//    }
//    if selection == 0{
//        NotificationCenter.default.post(name: .reloadHome, object: nil, userInfo: [:])
//    }
//    settings.selection = selection
//}

//func handlePaymentError(_ title: String, _ message: String, settings: UserSettings) {
//    settings.orderPaymentResult.getOrderAlertTitle = title
//    settings.orderPaymentResult.getOrderAlertMessage = message
//    settings.orderPaymentResult.iconType = 0
//    settings.orderPaymentResult.showPaymentDialog = true
//}
//
//func handlePaymentSuccess(_ title: String, _ message: String, settings: UserSettings) {
//    settings.orderPaymentResult.getOrderAlertTitle = title
//    settings.orderPaymentResult.getOrderAlertMessage = message
//    settings.orderPaymentResult.iconType = 1
//    settings.orderPaymentResult.showPaymentDialog = true
//}

func ShowCustomDialog(_ title: String, _ message: String, _ iconType: Int, settings: UserSettings) {
    settings.customDialog.title = title
    settings.customDialog.message = message
    settings.customDialog.iconType = iconType
    settings.customDialog.showDialog = true
}

func extractParameters(from urlString: String) -> [String: String]? {
    // Convert the string into a URL
    guard let url = URL(string: urlString),
          let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
          let queryItems = components.queryItems else { return nil }
    
    // Convert query items into a dictionary
    var parameters: [String: String] = [:]
    for item in queryItems {
        parameters[item.name] = item.value
    }
    return parameters
}

//func configureAndPay(using urlString: String) {
//    guard let parameters = extractParameters(from: urlString) else {
//        print("Failed to extract parameters.")
//        return
//    }
//    
//    // Extract individual parameters or provide a fallback
//    let receiverName = parameters["receiverName"] ?? "Unknown"
//    let receiverId = parameters["receiverId"] ?? ""
//    let title = parameters["title"] ?? ""
//    let amountString = parameters["amount"] ?? "0"
//    let amount = NSNumber(value: Double(amountString) ?? 0.0)
//    
//    // Pass the extracted parameters to IdramPaymentManager
//    IdramPaymentManager.pay(
//        withReceiverName: receiverName,
//        receiverId: receiverId,
//        title: title,
//        amount: amount,
//        hasTip: false,
////        callbackURLScheme: "gotcha://idramPayment"
//        callbackURLScheme: "gotcha://idramPayment"
//    )
//}

//func colorForOrderStatus(_ order: Order) -> Color {
//    if order.isCancelled == true {
//        return Color(UIColor(named: "CustomRed")!)
//    } else if order.isFinished == true {
//        return Color(UIColor(named: "0A7E56")!)
//    }else {
//        return .black
//    }
//}


func handleLogout(settings: UserSettings) {
    DispatchQueue.main.async {
        withAnimation{
            settings.isLogined = false
            settings.isFirebaseTokenSent = false
            settings.account_uid = ""
        }
    }
}
