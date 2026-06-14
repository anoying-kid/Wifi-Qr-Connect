import AppKit
import Foundation
import Testing
@testable import WifiQrConnect

struct QRGeneratorTests {
    @Test func qRGeneratorSuccess() {
        let payload = "WIFI:T:WPA;S:TestingNet;P:password;;"
        let image = QRGenerator.generate(from: payload, size: CGSize(width: 250, height: 250))
        #expect(image != nil)
        #expect(image?.size.width == 250)
        #expect(image?.size.height == 250)
    }
}
