import Foundation

protocol AlarmServiceProtocol {
    func updateDeviceToken(bodyDTO: DeviceTokenRequestDTO, completion: @escaping (NetworkResult<EmptyResponse>) -> Void)
}

final class AlarmService: APIRequestLoader<AlarmTarget>, AlarmServiceProtocol, AlarmAmplitudeSender {
    func updateDeviceToken(bodyDTO: DeviceTokenRequestDTO, completion: @escaping (NetworkResult<EmptyResponse>) -> Void) {
        fetchData(target: .updateDeviceToken(bodyDTO), responseData: EmptyResponse.self, completion: completion)
        self.sendAmpliLog(eventName: EventName.UPDATE_DEVICE_TOKEN)
    }
} 
