import Testing
@testable import WifiQrConnect

struct QRParserTests {
    @Test func standardWPANetwork() {
        let qr = "WIFI:T:WPA;S:MyNetwork;P:myPassword;;"
        let details = QRParser.parse(qrString: qr)
        #expect(details != nil)
        #expect(details?.ssid == "MyNetwork")
        #expect(details?.password == "myPassword")
        #expect(details?.security == "WPA")
        #expect(details?.hidden == false)
    }

    @Test func openNetwork() {
        let qr = "WIFI:T:nopass;S:FreeWiFi;;"
        let details = QRParser.parse(qrString: qr)
        #expect(details != nil)
        #expect(details?.ssid == "FreeWiFi")
        #expect(details?.password == "")
        #expect(details?.security == "nopass")
        #expect(details?.hidden == false)
    }

    @Test func escapedCharacters() {
        let qr = "WIFI:T:WPA;S:My\\;Semicolon\\:Colon;P:pass\\\\word;;"
        let details = QRParser.parse(qrString: qr)
        #expect(details != nil)
        #expect(details?.ssid == "My;Semicolon:Colon")
        #expect(details?.password == "pass\\word")
    }

    @Test func hiddenNetwork() {
        let qr = "WIFI:T:WPA;S:SecretNet;P:secretPass;H:true;;"
        let details = QRParser.parse(qrString: qr)
        #expect(details != nil)
        #expect(details?.ssid == "SecretNet")
        #expect(details?.hidden == true)
    }

    @Test func invalidFormat() {
        #expect(QRParser.parse(qrString: "NOT_WIFI:SSID;") == nil)
        #expect(QRParser.parse(qrString: "WIFI:T:WPA;;") == nil) // no S: key
    }
}
