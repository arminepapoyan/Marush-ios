import SwiftUI
import Combine

class DateSettings: ObservableObject {
    static let shared = DateSettings() // Singleton instance
    // Define min and max date strings
    private let minDateString = "1940-01-01"
    
    var maxDateFormatted: String {
        let calendar = Calendar.current
        let today = Date()
        if let dateTenYearsAgo = calendar.date(byAdding: .year, value: -10, to: today) {
            return Utils.dayFormatter.string(from: dateTenYearsAgo)
        } else {
            return Utils.dayFormatter.string(from: today)
        }
    }
    
    var minDate: Date {
        return Utils.dayFormatter.date(from: minDateString) ?? Date()
    }
    
    var today: Date {
        return Date()
    }
    
      // Convert the formatted maxDate string back to a Date object
    var maxDate: Date {
        return Utils.dayFormatter.date(from: maxDateFormatted) ?? Date()
    }
}
