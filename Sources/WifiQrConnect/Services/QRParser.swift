import Foundation

public struct WiFiDetails: Equatable, Sendable {
    public let ssid: String
    public let password: String
    public let security: String // WPA, WEP, nopass
    public let hidden: Bool

    public init(ssid: String, password: String, security: String, hidden: Bool = false) {
        self.ssid = ssid
        self.password = password
        self.security = security
        self.hidden = hidden
    }
}

public struct QRParser {
    public static func parse(qrString: String) -> WiFiDetails? {
        guard qrString.hasPrefix("WIFI:") else { return nil }
        
        let payload = String(qrString.dropFirst(5))
        var fields: [String: String] = [:]
        
        var currentKey: String? = nil
        var currentValue = ""
        var isEscaped = false
        
        var index = payload.startIndex
        while index < payload.endIndex {
            let char = payload[index]
            
            if isEscaped {
                currentValue.append(char)
                isEscaped = false
                index = payload.index(after: index)
                continue
            }
            
            if char == "\\" {
                isEscaped = true
                index = payload.index(after: index)
                continue
            }
            
            if currentKey == nil {
                if char == ":" {
                    let keyCandidate = currentValue.trimmingCharacters(in: .whitespacesAndNewlines)
                    if keyCandidate.count == 1 {
                        currentKey = keyCandidate
                        currentValue = ""
                    } else {
                        currentValue.append(char)
                    }
                } else {
                    currentValue.append(char)
                }
            } else {
                if char == ";" {
                    if let key = currentKey {
                        fields[key] = currentValue
                    }
                    currentKey = nil
                    currentValue = ""
                } else {
                    currentValue.append(char)
                }
            }
            
            index = payload.index(after: index)
        }
        
        guard let ssid = fields["S"], !ssid.isEmpty else { return nil }
        
        let security = fields["T"] ?? "nopass"
        let password = fields["P"] ?? ""
        let hidden = (fields["H"] == "true" || fields["H"] == "y")
        
        return WiFiDetails(ssid: ssid, password: password, security: security, hidden: hidden)
    }
}
