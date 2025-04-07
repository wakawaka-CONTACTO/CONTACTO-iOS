import Foundation
import Alamofire

enum AlarmTarget {
    case updateDeviceToken(_ bodyDTO: DeviceTokenRequestDTO)
}

extension AlarmTarget: TargetType {
    var authorization: Authorization {
        switch self {
        case .updateDeviceToken:
            return .authorization
        }
    }
    
    var headerType: HTTPHeaderType {
        switch self {
        case .updateDeviceToken:
            return .hasToken
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .updateDeviceToken:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .updateDeviceToken:
            return "/v1/alarm/device/update"
        }
    }
    
    var parameters: RequestParams {
        switch self {
        case .updateDeviceToken(let bodyDTO):
            return .requestWithBody(bodyDTO)
        }
    }
} 