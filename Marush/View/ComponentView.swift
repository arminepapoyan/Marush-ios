//
//  ComponentView.swift
//  Marush
//
//  Created by s2s s2s on 04.03.2026.
//
import SwiftUI
import SDWebImageSwiftUI

struct AllCategoriesSheet: View {
    
    let categories: [Category]
    var onSelect: (Category) -> Void
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("all_categories")
                .font(.Lato(size: 22))
                .padding(.horizontal)
            ScrollView {
                LazyVGrid(columns: columns, spacing: 25) {
                    ForEach(categories) { category in
                        VStack(spacing: 10) {
                            
                            WebImage(url: URL(string: category.appImage ?? ""))
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .padding(10)
                                .background(
                                    Circle()
                                        .fill(Color(UIColor(named: "F9F9F9")!))
                                )
                            
                            Text(category.name)
                                .font(.Lato(size: 14))
                                .multilineTextAlignment(.center)
                                .lineLimit(1)
                        }
                        .onTapGesture {
                            onSelect(category)
                        }
                    }
                }
                .padding(.horizontal, GlobalSettings.shared.horizontalPadding)
                .padding(.top, 10)
            }
        }
        .padding(.top, 25)
    }
}

struct PageHeaderView: View {
    var title: String
    
    var showBack: Bool = true
    var showRightButton: Bool = false
    
    var rightIcon: String = "trash"
    var onBack: (() -> Void)? = nil
    var onRightTap: (() -> Void)? = nil
    
    var body: some View {
        HStack {
            
            // LEFT
            if showBack {
                Button(action: {
                    onBack?()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color(UIColor(named: "1E1E1E")!))
                }
            }
            
            // TITLE
            if showBack {
                Spacer()
            }
            
            Text(title)
                .font(.LatoBold(size: 20))
                .foregroundColor(Color(UIColor(named: "ColorDark")!))
                .frame(maxWidth: showBack ? .infinity : nil, alignment: showBack ? .center : .leading)
            
            Spacer()
            
            // RIGHT
            if showRightButton {
                Button(action: {
                    onRightTap?()
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(UIColor(named: "1E1E1E")!).opacity(0.15))
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: rightIcon)
                            .foregroundColor(Color(UIColor(named: "ColorDark")!).opacity(0.8))
                    }
                }
            }
        }
    }
}
