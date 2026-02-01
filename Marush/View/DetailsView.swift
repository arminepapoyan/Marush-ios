//
//  DetailsView.swift
//  Marush
//
//  Created by s2s s2s on 30.01.2026.
//


import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}


let characterEntities : [String: Character] = [
    
    // XML predefined entities:
    "&quot;"     : "\"",
    "&amp;"      : "&",
    "&apos;"     : "'",
    "&lt;"       : "<",
    "&gt;"       : ">",
    
    // HTML character entity references:
    "&nbsp;"     : "\u{00A0}",
    "&iexcl;"    : "\u{00A1}"
]

extension String {
    func replacingCharacterEntities() -> String {
        func unicodeScalar(for numericCharacterEntity: String) -> Unicode.Scalar? {
            var unicodeString = ""
            for character in numericCharacterEntity {
                if "0123456789".contains(character) {
                    unicodeString.append(character)
                }
            }
            if let scalarInt = Int(unicodeString),
               let unicodeScalar = Unicode.Scalar(scalarInt) {
                return unicodeScalar
            }
            return nil
        }
        
        var result = ""
        var position = self.startIndex
        
        let range = NSRange(self.startIndex..<self.endIndex, in: self)
        let pattern = #"(&\S*?;)"#
        let unicodeScalarPattern = #"&#(\d*?);"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return self }
        regex.enumerateMatches(in: self, options: [], range: range) { matches, flags, stop in
            if let matches = matches {
                if let range = Range(matches.range(at: 0), in:self) {
                    let rangePreceedingMatch = position..<range.lowerBound
                    result.append(contentsOf: self[rangePreceedingMatch])
                    let characterEntity = String(self[range])
                    if let replacement = characterEntities[characterEntity] {
                        result.append(replacement)
                    } else if let _ = characterEntity.range(of: unicodeScalarPattern, options: .regularExpression),
                              let unicodeScalar = unicodeScalar(for: characterEntity) {
                        result.append(String(unicodeScalar))
                    }
                    position = self.index(range.lowerBound, offsetBy: characterEntity.count )
                }
            }
        }
        if position != self.endIndex {
            result.append(contentsOf: self[position..<self.endIndex])
        }
        return result
    }
}


//
//struct EmptyView: View {
//
//    @Binding var title : String
//    var body: some View {
//        VStack{
//            Text("\(title)")
//                .font(.title3)
//                .padding(.top,30)
//                .multilineTextAlignment(.center)
//        }
//    }
//}


extension View {
    func hideKeyboard() {
        let resign = #selector(UIResponder.resignFirstResponder)
        UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
    }
}

struct LoadingView: View {
    var body: some View{
        ZStack{
            Color(.systemBackground)
                .ignoresSafeArea()
                .opacity(0.8)
            
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color(UIColor(named: "GotchaPink")!)))
                .scaleEffect(3)
        }
    }
}

func htmlToText(htmlString: String, fontSize: CGFloat) -> Text {
    guard let attributedString = htmlToAttributedString(htmlString: htmlString, fontSize: fontSize) else {
        return Text("")
    }
    return Text(attributedString.string)
        .font(.Poppins(size: fontSize))
        .foregroundColor(.black)
}

func htmlToAttributedString(htmlString: String, fontSize: CGFloat) -> NSAttributedString? {
    var html = htmlString.replacingOccurrences(of: "<br />", with: "")
    html = html.replacingOccurrences(of: "<br>", with: "")
    let htmlData = Data(html.utf8)
    do {
        let attributedString =  try? NSAttributedString(data: htmlData, options: [:], documentAttributes: nil)
        let font = UIFont.systemFont(ofSize: fontSize)
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let range = NSRange(location: 0, length: attributedString!.length)
        let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString!)
        mutableAttributedString.addAttributes(attributes, range: range)
        return mutableAttributedString
    } catch {
        print("Error\(error.localizedDescription)")
        return nil
    }
}
