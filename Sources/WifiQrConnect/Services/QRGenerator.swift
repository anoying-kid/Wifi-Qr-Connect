import AppKit
import CoreImage
import Foundation

public enum QRGenerator {
    /// Generates a sharp, scaled NSImage containing the QR code for a given string payload.
    public static func generate(from string: String, size: CGSize = CGSize(width: 300, height: 300)) -> NSImage? {
        guard let data = string.data(using: .utf8) else { return nil }

        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel") // Medium error correction

        guard let ciImage = filter.outputImage else { return nil }

        // Scale the image up crisply using a transformation
        let scaleX = size.width / ciImage.extent.size.width
        let scaleY = size.height / ciImage.extent.size.height
        let transformedImage = ciImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

        let context = CIContext()
        guard let cgImage = context.createCGImage(transformedImage, from: transformedImage.extent) else { return nil }

        return NSImage(cgImage: cgImage, size: size)
    }
}
