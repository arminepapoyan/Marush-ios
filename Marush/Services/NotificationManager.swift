//
//  NotificationManager.swift
//  Marush
//
//  Created by S2S Company on 30.01.2025.
//

import Combine
import Foundation

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()  // Singleton instance
    @Published var selectedTab: Int = 0
    
    
    func changeSelectedTab(_ newValue : Int) {
        self.selectedTab = newValue
        self.objectWillChange.send()
    }
}
