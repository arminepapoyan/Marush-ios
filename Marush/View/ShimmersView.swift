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
struct productsSliderItemShimmer: View{
    var body: some View{
        VStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(UIColor(named: "ColorShimmer")!))
                .frame(height: 120)
                .frame(maxWidth: .infinity)
            
            // Product Name
            Rectangle()
                .fill(Color(UIColor(named: "ColorShimmer")!))
                .frame(width: 100, height: 10)
            
            // Product Price
            Rectangle()
                .fill(Color(UIColor(named: "ColorShimmer")!))
                .frame(width: 50, height: 10)
        }
//        .frame(width: 120)
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
        .padding(10)
        .background(.white)
        .cornerRadius(11)
        .padding(1)
        .background(RoundedRectangle(cornerRadius: 11).stroke(Color(UIColor(named: "ColorDark")!).opacity(0.3), lineWidth: 1))
        .redacted(reason: .placeholder)
        .shimmering()
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
