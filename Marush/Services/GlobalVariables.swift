//
//  GlovalVariables.swift
//  Marush
//
//  Created by S2S Company on 30.01.2025.
//


import SwiftUI
import Combine

final class GlobalSettings: ObservableObject {
    static let shared = GlobalSettings()

    private init() {}

    @Published var horizontalPadding: CGFloat = 12
    @Published var reorderDeeplinking: String = "marush://reorder"
}
