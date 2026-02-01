//
//  TabBarItem.swift
//  Marush
//
//  Created by s2s s2s on 01.02.2026.
//

import SwiftUI

struct TabBarItem<Content: View>: View {
    let tag: Int
    let selection: Int
    let title: String
    let icon: String
    let content: Content

    init(
        tag: Int,
        selection: Int,
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) {
        self.tag = tag
        self.selection = selection
        self.title = title
        self.icon = icon
        self.content = content()
    }

    private var isSelected: Bool {
        selection == tag
    }

    private var currentIcon: String {
        isSelected ? "\(icon)-fill" : icon
    }

    private var textColor: Color {
        isSelected
            ? Color(UIColor(named: "ColorDark")!)
            : Color(UIColor(named: "ColorDark")!).opacity(0.6)
    }

    private var textFont: Font {
        isSelected
            ? .PoppinsBold(size: 12)
            : .PoppinsMedium(size: 12)
    }

    var body: some View {
        content
            .tabItem {
                Image(currentIcon)
                Text(title)
                    .font(textFont)
                    .foregroundColor(textColor)
            }
           
            .tag(tag)
    }
}
