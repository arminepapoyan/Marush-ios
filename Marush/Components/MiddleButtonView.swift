//
//  MiddleButtonView.swift
//  Marush
//
//  Created by S2S Company on 30.01.2025.
//
import SwiftUI

//struct MiddleButtonView: View {
//    @EnvironmentObject var settings: UserSettings
////    var onTap: () -> Void  
//
//    var body: some View {
//        VStack {
//            Spacer()
//            HStack {
//                VStack {
//                    ZStack {
//                        Image("topIconBackgroundSVG")
//                            .frame(width: 85)
//                            .offset(y: -2)
//                        ZStack {
//                            Circle()
//                                .foregroundColor(Color(UIColor(named: "FCF3F6")!))
//                                .frame(width: 77, height: 77)
//
//                            VStack {
//                                Image(settings.selection == 2 ? "ic-order-fill" : "ic-order")
//                                Text("order")
//                                    .font(.Poppins(size: 10))
//                                    .foregroundColor(settings.selection == 2 ? .black : Color(UIColor(named: "0F182D")!))
//                                    .fontWeight(settings.selection == 2 ? .bold : .medium)
//                            }
//                        }
//                        .offset(y: -1)
//                    }
//                    .onTapGesture {
//                        settings.selection = 2
////                        onTap() // Call the closure
//                    }
//                }
//            }
//            .offset(y: UIDevice.current.localizedModel == "iPad" ? 3 : -15)
//        }
//    }
//}
