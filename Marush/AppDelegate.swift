//
//  AppDelegate.swift
//  Marush
//
//  Created by s2s s2s on 30.01.2026.
//

import UIKit
//import Firebase
//import FirebaseMessaging
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
    let gcmMessageIDKey = "gcm.message_id"
    private var userSettings = UserSettings()

//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        // Configure Firebase
//        FirebaseApp.configure()
//
//        // Set the delegate for Firebase Messaging
//        Messaging.messaging().delegate = self
//
//        // Request notification permissions
//        UNUserNotificationCenter.current().delegate = self
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
//            if let error = error {
//                print("Notification authorization failed: \(error.localizedDescription)")
//            } else {
//                print("Notification authorization granted: \(granted)")
//                if granted {
//                    DispatchQueue.main.async {
//                        application.registerForRemoteNotifications()
//                    }
//                }
//            }
//        }
//
//        return true
//    }

//    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        // Pass device token to Firebase
//        Messaging.messaging().apnsToken = deviceToken
//        print("Device token registered: \(deviceToken.map { String(format: "%02.2hhx", $0) }.joined())")
//    }
//
//    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
//        print("Failed to register for remote notifications: \(error.localizedDescription)")
//    }
}

// MARK: - Firebase Messaging Delegate
//extension AppDelegate: MessagingDelegate {
//    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
//        guard let fcmToken = fcmToken else {
//            print("FCM token is not available")
//            return
//        }
//
////        print("FCM Registration Token: \(fcmToken)")
//        UIApplication.shared.applicationIconBadgeNumber = 0
////        print("Firebase token bool is \(userSettings.isFirebaseTokenSent ? "true" : "false")")
//        if userSettings.isLogined && !userSettings.isFirebaseTokenSent{
//            firebaseToken(data: "\(fcmToken ?? "")"){ res in
////                print("Firebase token sent")
//                self.userSettings.isFirebaseTokenSent = true
//            }
//        }
//    }
//}

// MARK: - UNUserNotificationCenter Delegate
//extension AppDelegate: UNUserNotificationCenterDelegate {
//    
//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
//        let userInfo = notification.request.content.userInfo
//        
//        if let action = userInfo["action"] as? String, action.contains("orderPayedAction") {
//            if let orderId = userInfo["orderId"] {
//                // Call your custom function here, for example:
//                NotificationCenter.default.post(name: .orderPayed, object: nil, userInfo: ["orderId": orderId])
//            }
//            
//        }
//
//        notification_count += 1
//        UIApplication.shared.applicationIconBadgeNumber += 1
//        return [.banner, .sound, .badge]
//    }
//
//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
//        // Handle actions when the user taps on the notification
////        print("Notification tapped: \(response.notification.request.content.userInfo)")
//        NotificationManager.shared.changeSelectedTab(3)
//    }
//}
