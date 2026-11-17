//
//  ShimmersView.swift
//  Marush
//
//  Created by s2s s2s on 11.02.2026.
//


import SwiftUI
import Shimmer

struct LocationCardShimmer: View{
    var body: some View{
        VStack(alignment: .leading, spacing: 12){
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(UIColor(named: "ColorShimmer")!))
                .frame(height: 125)
                .frame(maxWidth: .infinity)
            Rectangle()
                .fill(Color(UIColor(named: "ColorShimmer")!))
                .frame(width: 180, height: 10)
            Rectangle()
                .fill(Color(UIColor(named: "ColorShimmer")!))
                .frame(width: 150, height: 10)
        }
        .padding(.horizontal)
        .redacted(reason: .placeholder)
        .shimmering()
    }
}


struct OrderCardShimmer: View{
    var body: some View{
        VStack(alignment: .leading, spacing: 12){
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(UIColor(named: "ColorShimmer")!))
                .frame(height: 125)
                .frame(maxWidth: .infinity)
            Rectangle()
                .fill(Color(UIColor(named: "ColorShimmer")!))
                .frame(width: 180, height: 10)
            Rectangle()
                .fill(Color(UIColor(named: "ColorShimmer")!))
                .frame(width: 150, height: 10)
        }
        .padding(.horizontal)
        .redacted(reason: .placeholder)
        .shimmering()
    }
}

struct ShopItemShimmer: View{
    var body: some View{
        VStack(alignment: .leading, spacing: 12){
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(UIColor(named: "ColorShimmer")!))
                .frame(height: 60)
                .frame(maxWidth: .infinity)
        }
        .redacted(reason: .placeholder)
        .shimmering()
    }
}

struct greetingGotchaImg: View{
    var body: some View{
        VStack(alignment: .leading, spacing: 12){
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(UIColor(named: "LightPink")!))
                .frame(width: 34, height: 60)
                .padding(.trailing,40)
        }
        .redacted(reason: .placeholder)
        .shimmering()
    }
}

struct bonusAmountShimmer: View{
    var body: some View{
        VStack{
            ProgressView()
                .foregroundColor(.gray.opacity(0.3))
                .frame(height: 50)
        }
    }
}

struct homeOrderProgressShimmer: View{
    var body: some View{
        VStack(alignment: .leading, spacing: 12){
            VStack(alignment: .center, spacing: 12){
                Rectangle()
                    .fill(Color(UIColor(named: "ColorShimmer")!))
                    .frame(width: 180, height: 10)
                Rectangle()
                    .fill(Color(UIColor(named: "ColorShimmer")!))
                    .frame(width: 150, height: 10)
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(UIColor(named: "ColorShimmer")!))
                    .frame(height: 190)
                    .frame(maxWidth: .infinity)
            }
            .padding()
        }
        .background(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color(UIColor(named: "ABABAB")!), lineWidth: 1)
        )
        .padding()
        .redacted(reason: .placeholder)
        .shimmering()
    }
}

struct homeSliderShimmer: View{
    var body: some View{
        VStack(alignment: .leading, spacing: 12){
            VStack(alignment: .center, spacing: 12){
                RoundedRectangle(cornerRadius: 0)
                    .fill(Color(UIColor(named: "ColorShimmer")!))
                    .frame(height: UIDevice.current.localizedModel == "iPad" ? 470 : 270)
                    .frame(maxWidth: .infinity)
            }
        }
        .redacted(reason: .placeholder)
        .shimmering()
    }
}
/// Placeholder shaped exactly like `ProductCard`: 200pt image, price line, name line,
/// same corner radius and outline — so nothing shifts once the real data lands.
struct productsSliderItemShimmer: View{
    var width: CGFloat? = nil

    private var shimmerColor: Color { Color(UIColor(named: "ColorShimmer")!) }

    var body: some View{
        VStack(alignment: .leading, spacing: 8) {
            Rectangle()
                .fill(shimmerColor)
                .frame(height: 200)
                .frame(maxWidth: .infinity)

            VStack(alignment: .leading, spacing: 5) {
                Rectangle()
                    .fill(shimmerColor)
                    .frame(width: 60, height: 14)
                Rectangle()
                    .fill(shimmerColor)
                    .frame(height: 14)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 15)
        }
        .frame(width: width)
        .background(.white)
        .cornerRadius(10)
        .padding(1)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(UIColor(named: "ColorDark")!).opacity(0.1), lineWidth: 1)
        )
        .redacted(reason: .placeholder)
        .shimmering()
    }
}

/// One home-page category block while loading: section title + a row of card placeholders.
struct CategoryBlockShimmer: View {
    private var cardWidth: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let horizontalPadding = GlobalSettings.shared.horizontalPadding * 2
        let spacing: CGFloat = 16
        return (screenWidth - horizontalPadding - spacing) / 2
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Rectangle()
                .fill(Color(UIColor(named: "ColorShimmer")!))
                .frame(width: 150, height: 18)
                .cornerRadius(4)
                .redacted(reason: .placeholder)
                .shimmering()

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 16) {
                    ForEach(0..<3, id: \.self) { _ in
                        productsSliderItemShimmer(width: cardWidth)
                    }
                }
            }
            .disabled(true)
        }
        .padding(.vertical)
    }
}

struct AddressPickerRowShimmer: View {
    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(UIColor(named: "ColorShimmer")!))
                .frame(width: 22, height: 26)

            VStack(alignment: .leading, spacing: 6) {
                Rectangle()
                    .fill(Color(UIColor(named: "ColorShimmer")!))
                    .frame(height: 13)
                    .frame(maxWidth: .infinity)
                Rectangle()
                    .fill(Color(UIColor(named: "ColorShimmer")!))
                    .frame(width: 140, height: 11)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.white)
        .overlay(
            VStack {
                Spacer()
                Rectangle()
                    .fill(Color(UIColor(named: "CEF0F7")!))
                    .frame(height: 1)
            }
        )
        .redacted(reason: .placeholder)
        .shimmering()
    }
}

struct productDetailImageShimmer: View{
    var body: some View{
        VStack{
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(UIColor(named: "ColorShimmer")!))
                .frame(height: 360)
                .frame(maxWidth: .infinity)
        }
        .shimmering()
    }
}

struct gifSliderItemShimmer: View{
    var body: some View{
        VStack{
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(UIColor(named: "ColorShimmer")!))
                .frame(height: 250)
                .frame(maxWidth: .infinity)
        }
        .padding()
        .redacted(reason: .placeholder)
        .shimmering()
    }
}

struct QrShimmer: View{
    var body: some View{
        VStack{
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(UIColor(named: "ABABAB")!))
                .frame(width: 250, height: 250)
        }
        .redacted(reason: .placeholder)
        .shimmering()
    }
}

struct RewardsInfoItemShimmer: View{
    var body: some View{
        VStack(alignment: .center, spacing: 12){
            Rectangle()
                .fill(Color(UIColor(named: "ColorShimmer")!))
                .frame(maxWidth: .infinity)
                .frame(height: 8)
            Rectangle()
                .fill(Color(UIColor(named: "ColorShimmer")!))
                .frame(maxWidth: .infinity)
                .frame(height: 8)
            Rectangle()
                .fill(Color(UIColor(named: "ColorShimmer")!))
                .frame(width: 100, height: 8)
        }
        .padding(.horizontal)
        .redacted(reason: .placeholder)
        .shimmering()
    }
}

struct OrderHistoryShimmer: View{
    var body: some View{
        VStack(alignment: .leading, spacing: 12){
            VStack(alignment: .center, spacing: 12){
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(UIColor(named: "ColorShimmer")!))
                    .frame(height: 190)
                    .frame(maxWidth: .infinity)
                Rectangle()
                    .fill(Color(UIColor(named: "ColorShimmer")!))
                    .frame(width: 180, height: 10)
                Rectangle()
                    .fill(Color(UIColor(named: "ColorShimmer")!))
                    .frame(width: 150, height: 10)
            }
            .padding()
        }
        .background(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color(UIColor(named: "F9F9F9")!), lineWidth: 1)
        )
        .redacted(reason: .placeholder)
        .shimmering()
    }
}
