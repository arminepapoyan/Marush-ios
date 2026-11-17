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


// MARK: - Payment result

/// Asks the server whether the tracked order was actually paid, and reacts accordingly.
///
/// Every return path — closing the card WebView, coming back from Idram, or a push —
/// funnels through here, so the client never decides payment success on its own.
func checkOrderStatus(_ settings: UserSettings, selection: Int = 1) {
    guard settings.orderId != 0 else { return }

    getOrder(data: settings.orderId) { response in
        DispatchQueue.main.async {
            guard let response, response.status == 200,
                  let order = response.orders?.first else {
                handlePaymentError(settings)
                return
            }
            handleOrderResult(order, settings: settings, selection: selection)
        }
    }
}

private func handleOrderResult(_ order: Order, settings: UserSettings, selection: Int) {
    let isCash = order.paymentMethod.key == "cash"

    if !order.payed && !isCash {
        handlePaymentError(settings)
        settings.selection = 2          // back to the cart so the user can retry
        return
    }

    // Paid, or cash on delivery — the order stands.
    settings.cart_count = 0
    CartManager.shared.clearAll()
    NotificationCenter.default.post(name: .reloadHome, object: nil, userInfo: [:])

    settings.selection = selection
    settings.showThankYou = true
}

private func handlePaymentError(_ settings: UserSettings) {
    ShowCustomDialog(
        getLocalString(string: "payment_not_processed"),
        getLocalString(string: "there_was_problem_with_order_payment"),
        0,
        settings: settings
    )
}

/// Re-packs the Idram URL returned by `order/add` so it carries our callback scheme.
/// The backend hands back an `idramapp://` link without one, and iOS — unlike Android,
/// which uses `onActivityResult` — needs it to get the user back into the app.
@discardableResult
func configureAndPay(using urlString: String) -> Bool {
    guard let parameters = extractParameters(from: urlString) else {
        print("Idram: could not read parameters from \(urlString)")
        return false
    }

    return IdramPaymentManager.pay(
        receiverName: parameters["receiverName"] ?? "",
        receiverId:   parameters["receiverId"]   ?? "",
        title:        parameters["title"]        ?? "",
        amount:       Double(parameters["amount"] ?? "0") ?? 0
    )
}

func handleLogout(settings: UserSettings) {
    DispatchQueue.main.async {
        withAnimation{
            settings.isLogined = false
            settings.isFirebaseTokenSent = false
            settings.account_uid = ""
        }
    }
}
