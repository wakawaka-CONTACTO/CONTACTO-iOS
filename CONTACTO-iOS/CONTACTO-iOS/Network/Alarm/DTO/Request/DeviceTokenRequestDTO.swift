import Foundation

struct DeviceTokenRequestDTO: Codable {
    let deviceId: String
    let deviceType: String
    let firebaseToken: String
} 