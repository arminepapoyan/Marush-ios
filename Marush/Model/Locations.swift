//
//  Locations.swift
//  Marush
//
//  Created by s2s s2s on 07.04.2026.
//


struct Location: Identifiable, Codable {
    let id: String
    let name: String
    let address: String?
    let image: String?
    let hours: String?
    let coordinates: [String]?
    let startTime: String?
    let endTime: String?
    let status: String?
    
    // Status Enum (Optional)
//    var isOpen: Bool {
//        status?.lowercased() == "open"
//    }
}
