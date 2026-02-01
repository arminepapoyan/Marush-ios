//
//  Lang.swift
//  Marush
//
//  Created by s2s s2s on 30.01.2026.
//

import SwiftUI


enum Lang: String, CaseIterable {
    case armenian = "hy"
    case english = "en"
    case russian = "ru"
    
    
    var identifier: String {
        switch self {
        case .english:
            return "en"
        case .armenian:
            return "hy"
        case .russian:
            return "ru"
            
        }
    }
    
    var lang_name: String {
        switch self {
        case .english:
            return "English"
        case .armenian:
            return "Հայերեն"
        case .russian:
            return "Русский"
            
        }
    }
    
//    var image: Image {
//        switch self {
//        case .english:
//            return Image("en_lang")
//        case .armenian:
//            return Image("hy_lang")
//        case .russian:
//            return Image("ru_lang")
//        }
//    }
    
}


