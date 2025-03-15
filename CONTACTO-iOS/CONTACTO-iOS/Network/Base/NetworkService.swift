//
//  NetworkService.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/9/24.
//

import Foundation

final class NetworkService {
    static let shared = NetworkService()

    private init() {}

    let onboardingService: OnboardingServiceProtocol = OnboardingService(apiLogger: APIEventLogger())
    let homeService: HomeServiceProtocol = HomeService(apiLogger: APIEventLogger())
    let chatService: ChatServiceProtocol = ChatService(apiLogger: APIEventLogger())
    let editService: EditServiceProtocol = EditService(apiLogger: APIEventLogger())
    let infoService: InfoServiceProtocol = InfoService(apiLogger: APIEventLogger())
}
