import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRCodeGenerator {

    static let context = CIContext()
    static let filter = CIFilter.qrCodeGenerator()

    static func generate(from string: String) -> UIImage {

        filter.setValue(Data(string.utf8), forKey: "inputMessage")

        guard let outputImage = filter.outputImage else {
            return UIImage()
        }

        let transform = CGAffineTransform(scaleX: 12, y: 12)
        let scaled = outputImage.transformed(by: transform)

        guard let cgImage = context.createCGImage(scaled, from: scaled.extent) else {
            return UIImage()
        }

        return UIImage(cgImage: cgImage)
    }
}
