//
//  IdramPayment.swift
//  Marush
//

import Foundation
import UIKit

/// Hands a payment off to the Idram app.
///
/// This is a Swift port of the `IdramMerchantPayment` CocoaPod used in Gotcha —
/// the pod is only a URL builder, so vendoring it would mean adding CocoaPods to a
/// project that is otherwise pure SPM.
enum IdramPaymentManager {

    /// Custom scheme Idram sends the user back to once payment finishes.
    static let callbackURLScheme = "marush://idramPayment"

    /// Builds `idramapp://payment?...` and opens the Idram app.
    /// - Returns: `false` when a required field is missing or Idram cannot be opened.
    @discardableResult
    static func pay(receiverName: String,
                    receiverId: String,
                    title: String,
                    amount: Double,
                    hasTip: Bool = false,
                    callbackURLScheme: String = IdramPaymentManager.callbackURLScheme) -> Bool {

        guard !receiverName.isEmpty, !receiverId.isEmpty, !title.isEmpty, amount > 0 else {
            print("IdramPaymentManager: missing receiverName/receiverId/title/amount")
            return false
        }

        var components = URLComponents()
        components.scheme = "idramapp"
        components.host   = "payment"
        components.queryItems = [
            URLQueryItem(name: "receiverName", value: receiverName),
            URLQueryItem(name: "receiverId",   value: receiverId),
            URLQueryItem(name: "title",        value: title),
            URLQueryItem(name: "amount",       value: formatted(amount))
        ]
        if hasTip {
            components.queryItems?.append(URLQueryItem(name: "tip", value: "0"))
        }
        if !callbackURLScheme.isEmpty {
            components.queryItems?.append(
                URLQueryItem(name: "callbackUrlScheme", value: callbackURLScheme)
            )
        }

        guard let url = components.url else {
            print("IdramPaymentManager: could not build the payment URL")
            return false
        }

        guard UIApplication.shared.canOpenURL(url) else {
            print("IdramPaymentManager: Idram is not installed")
            return false
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        return true
    }

    /// Drops the decimal part for whole amounts so the URL carries `1500`, not `1500.0`.
    private static func formatted(_ amount: Double) -> String {
        amount == amount.rounded() ? String(Int(amount)) : String(amount)
    }
}
