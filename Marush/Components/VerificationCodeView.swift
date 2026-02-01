//
//  VerificationCodeView.swift
//  Marush
//
//  Created by s2s s2s on 01.02.2026.
//
import SwiftUI

struct VerificationCodeView: View {

    let length: Int = 6
    @Binding var code: String
    @Binding var hasError: Bool

    @State private var rawText: String = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack {
            // REAL INPUT
            TextField("", text: $rawText)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($isFocused)
                .foregroundColor(.clear)
                .tint(.clear)
                .frame(width: 1, height: 1)
                .onChange(of: rawText) { newValue in
                    let filtered = newValue.filter { $0.isNumber }
                    let limited = String(filtered.prefix(length))

                    // 🔥 SYNC BOTH
                    code = limited
                    rawText = limited
                }

            // UI BOXES
            HStack(spacing: 10) {
                ForEach(0..<length, id: \.self) { index in
                    codeBox(at: index)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isFocused = true
        }
        .onAppear {
            rawText = code
            isFocused = true
        }
    }

    private func codeBox(at index: Int) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            hasError
                            ? Color(UIColor(named: "CustomRed")!)
                            : (index == code.count && isFocused
                                ? Color(UIColor(named: "ColorDark")!)
                                : .clear),
                            lineWidth: 1
                        )
                )

            Text(character(at: index))
                .font(.PoppinsMedium(size: 20))
                .foregroundColor(Color(UIColor(named: "ColorDark")!))
        }
        .frame(width: 48, height: 56)
    }

    private func character(at index: Int) -> String {
        guard index < code.count else { return "" }
        return String(code[code.index(code.startIndex, offsetBy: index)])
    }
}

