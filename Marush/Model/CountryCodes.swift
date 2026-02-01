//
//  CountryCodes.swift
//  Marush
//
//  Created by s2s s2s on 30.01.2026.
//

import Foundation

struct CountryCodes: Codable, Identifiable {
    let id: String
    let name: String
    let flag: String
    let code: String
    let dial_code: String
    let pattern: String
    let limit: Int
    
    static let allCountry: [CountryCodes] = Bundle.main.decode("CountryNumbers.json")
    static let example = allCountry[0]
}
