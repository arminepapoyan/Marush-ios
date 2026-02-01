//
//  CustomDialog.swift
//  Marush
//
//  Created by s2s s2s on 31.01.2026.
//

import SwiftUI

struct CustomDialog: View {
    @Binding var isActive: Bool
    
    let icone_type: Int
    let title: String
    let message: String
    let buttonTitle: String
    let padd: CGFloat
    let action: () -> ()
    @State private var offset: CGFloat = 100
    var closeOutside: Bool = true
    var body: some View {
        ZStack {
            Color(.black)
                .opacity(0.5)
                .onTapGesture {
                    if closeOutside{
                        close()
                    }
                }
            
            VStack(alignment: .center, spacing: 15) {
                
//                VStack(spacing: 20){
                    Image(icone_type == 1 ? "ic-success" : "ic-error")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 25)
                    if !title.isEmpty {
                        Text(title)
                            .font(.PoppinsBold(size: 15))
                    }
//                }
                htmlToText(htmlString: "\(message)", fontSize: 16)
                    .font(.Poppins(size: 14))
                    .multilineTextAlignment(.center)
                
                ButtonView(showLoading: .constant(false), isDisabled: .constant(false), title: "OK"){
                    close()
                    action()
                }
                .frame(maxWidth: 150)
            }
            .frame(minWidth: UIScreen.main.bounds.width / 1.5)
            .fixedSize(horizontal: false, vertical: true)
            .padding(20)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
//            .overlay(alignment: .topTrailing) {
//                Button {
//                    close()
//                } label: {
//                    Image(systemName: "xmark")
//                        .font(.title2)
//                        .fontWeight(.medium)
//                        .padding(.bottom,2)
//                }
//                .tint(.black)
//                .padding()
//            }
            .shadow(radius: 20)
            .padding(.horizontal,padd)
            .offset(x: 0, y: offset)
            .onAppear {
                withAnimation(.spring()) {
                    offset = 0
                }
            }
        }
        .ignoresSafeArea(.all)
    }
    
    func close() {
        withAnimation(.spring()) {
            offset = 1000
            isActive = false
        }
    }
}


struct CustomComfirmDialog: View {
    @Binding var isActive: Bool
    
    let title: String
    let message: String
//    let buttonTitle: String
    let padd: CGFloat
//    let action: () -> ()
    @State private var offset: CGFloat = 100
    
    var body: some View {
        ZStack {
            Color(.black)
                .opacity(0.5)
                .onTapGesture {
                    close()
                }
            
            VStack {
                
                
                Image("done")
                    .resizable()
                    .frame(width: 60,height: 60)
                    .padding(.vertical,5)
                
                HStack{
                    Spacer()
                    Text(title)
                        .font(.system(size: 20))
                        .bold()
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                
                
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(20)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            
            .shadow(radius: 20)
            .padding(.horizontal,padd)
            .offset(x: 0, y: offset)
            .onAppear {
                withAnimation(.spring()) {
                    offset = 0
                }
            }
        }
        .ignoresSafeArea(.all)
    }
    
    func close() {
        withAnimation(.spring()) {
            offset = 1000
            isActive = false
        }
    }
}

struct CustomDialog_Previews: PreviewProvider {
    static var previews: some View {
        CustomDialog(isActive: .constant(true), icone_type: 0, title: "Access photos?", message: "This lets you choose which photos you want to add to this project.", buttonTitle: "Give Access",padd: 30, action: {})
    }
}
