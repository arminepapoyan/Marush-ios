import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRCodeView: View {
    let info: String
    let width: Int = 200
    let height: Int = 200
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()

    var body: some View {
        VStack {
            if let qrCodeImage = generateQRCode(from: info) {
                Image(uiImage: qrCodeImage)
                    .interpolation(.none) // to prevent blurring
                    .resizable()
                    .frame(width: 250, height: 250) // set the size of the QR code
                    .background(Color(UIColor(named: "LightGray")!))
            } else {
                Text("Failed to generate QR Code")
            }
        }
        .padding()
    }

    // Generate a UIImage QR code from the phone number
    func generateQRCode(from string: String) -> UIImage? {
        let data = Data(string.utf8) // Convert the string to Data
        filter.setValue(data, forKey: "inputMessage")

        if let outputImage = filter.outputImage {
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        return nil
    }
}
