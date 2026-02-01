//
//  HelperFunctions.swift
//  Marush
//
//  Created by S2S Company on 30.01.2025.
//

import SwiftUI
import Combine

func roundNumber(_ number: Double?) -> String {
    guard let number = number else {
        return "0" // Handle nil case
    }
    
    // Check if the number is effectively a whole number
    if number.truncatingRemainder(dividingBy: 1) == 0 {
        return String(Int(number)) // Return as integer
    } else {
        // Format the number with up to 2 decimal places
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.decimalSeparator = "."
        
        // Format the number and return
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}

func isTimeBetween(start: String, end: String, checkTime: String) -> Bool {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm"

    guard let startDate = dateFormatter.date(from: start),
          let endDate = dateFormatter.date(from: end),
          let checkDate = dateFormatter.date(from: checkTime) else {
        return false // Return false if date conversion fails
    }

    return checkDate >= startDate && checkDate <= endDate
}
