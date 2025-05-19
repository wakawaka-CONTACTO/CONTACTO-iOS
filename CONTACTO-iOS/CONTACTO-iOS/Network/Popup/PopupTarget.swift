import Foundation
import Alamofire

enum PopupTarget {
    case getPopups
}

extension PopupTarget: TargetType {
    var authorization: Authorization {
        return .unauthorization
    }
    var headerType: HTTPHeaderType {
        return .plain
    }
    var method: HTTPMethod {
        return .get
    }
    var path: String {
        switch self {
        case .getPopups:
            return "/v1/popups"
        }
    }
    var parameters: RequestParams {
        return .requestPlain
    }
} 