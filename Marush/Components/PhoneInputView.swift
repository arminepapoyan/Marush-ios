import SwiftUI
import Combine

struct PhoneInputView: View {
    @State var presentSheet = false
    @Binding var countryCode: String
    @Binding var mobPhoneNumber: String
    @State var countryFlag: String = "🇺🇸"
    @State var countryPattern: String = "### ### ####"
    @State var countryLimit: Int = 17
    
    @State private var searchCountry: String = ""
    @Environment(\.colorScheme) var colorScheme
    @FocusState private var keyIsFocused: Bool
    
    let countries: [CountryCodes] = Bundle.main.decode("CountryNumbers.json")
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    presentSheet = true
                    keyIsFocused = false
                } label: {
                    Text("\(countryFlag) \(countryCode)")
                        .frame(height: 44)
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                        .background(backgroundColor, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
                        .foregroundColor(foregroundColor)
                }
                
                TextField("", text: $mobPhoneNumber)
                    .font(.Poppins(size: mobPhoneNumber.isEmpty ? 16: 13))
                    .placeholder(when: mobPhoneNumber.isEmpty) {
                        Text("Phone number")
                            .foregroundColor(.secondary)
                    }
                    .focused($keyIsFocused)
                    .keyboardType(.numbersAndPunctuation)
                    .onReceive(Just(mobPhoneNumber)) { _ in
                        applyPatternOnNumbers(&mobPhoneNumber, pattern: countryPattern, replacementCharacter: "#")
                    }
                    .onAppear{
                        if mobPhoneNumber != ""{
                            parsePhoneNumber(mobPhoneNumber)
                        }
                    }
            }
            .animation(.easeInOut(duration: 0.6), value: keyIsFocused)
          
        }
        .onTapGesture {
            hideKeyboard()
        }
        .sheet(isPresented: $presentSheet) {
            NavigationView {
                List(filteredCountries) { country in
                    HStack {
                        Text(country.flag)
                        Text(country.name)
                            .font(.headline)
                        Spacer()
                        Text(country.dial_code)
                            .foregroundColor(.secondary)
                    }
                    .onTapGesture {
                        self.countryFlag = country.flag
                        self.countryCode = country.dial_code
                        self.countryPattern = country.pattern
                        self.countryLimit = country.limit
                        presentSheet = false
                        searchCountry = ""
                    }
                }
                .listStyle(.plain)
                .searchable(text: $searchCountry, prompt: "Your country")
            }
            .presentationDetents([.medium, .large])
        }
    }
    
    // Filter countries based on search query
    var filteredCountries: [CountryCodes] {
        if searchCountry.isEmpty {
            return countries
        } else {
            return countries.filter { $0.name.localizedCaseInsensitiveContains(searchCountry) }
        }
    }
    
    // Get foreground color based on theme
    var foregroundColor: Color {
        colorScheme == .dark ? .white : .black
    }
    
    // Get background color based on theme
    var backgroundColor: Color {
        colorScheme == .dark ? Color(.clear) : Color(.clear)
    }
    
    // Apply pattern to format phone number as per the country's pattern
    func applyPatternOnNumbers(_ stringvar: inout String, pattern: String, replacementCharacter: Character) {
        var pureNumber = stringvar.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        for index in 0 ..< pattern.count {
            guard index < pureNumber.count else {
                stringvar = pureNumber
                return
            }
            let stringIndex = pattern.index(pattern.startIndex, offsetBy: index)
            let patternCharacter = pattern[stringIndex]
            guard patternCharacter != replacementCharacter else { continue }
            pureNumber.insert(patternCharacter, at: pureNumber.index(pureNumber.startIndex, offsetBy: index))
        }
        stringvar = pureNumber
    }
    
    func parsePhoneNumber(_ fullPhoneNumber: String) {
        // Extract only numbers from the input
        let digitsOnly = fullPhoneNumber.replacingOccurrences(of: "[^0-9+]", with: "", options: .regularExpression)
        
        // Check for matching country codes
        if let country = countries.first(where: { digitsOnly.starts(with: $0.dial_code) }) {
            // Update country details
            countryFlag = country.flag
            countryCode = country.dial_code
            countryPattern = country.pattern
            countryLimit = country.limit
            
            // Remove country code from the phone number
            let startIndex = digitsOnly.index(digitsOnly.startIndex, offsetBy: country.dial_code.count)
            let numberWithoutCode = String(digitsOnly[startIndex...])
            
            // Update phone number
            mobPhoneNumber = numberWithoutCode
            // Apply pattern to the phone number
            applyPatternOnNumbers(&mobPhoneNumber, pattern: countryPattern, replacementCharacter: "#")
        }
    }
}

//#Preview {
//    PhoneInputView(presentSheet: false, countryCode: "+374", countryFlag: "🇦🇲", countryPattern: "## ######", countryLimit: 300)
//}
