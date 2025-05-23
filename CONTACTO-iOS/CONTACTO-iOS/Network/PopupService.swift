import Foundation

final class PopupService: APIRequestLoader<PopupTarget> {
    init() {
        super.init(apiLogger: APIEventLogger())
    }
    func getPopups(completion: @escaping (NetworkResult<[PopupResponseDTO]?>) -> Void) {
        fetchData(target: .getPopups, responseData: [PopupResponseDTO]?.self, completion: completion)
    }
} 