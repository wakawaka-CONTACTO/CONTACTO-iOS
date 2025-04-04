//
//  TargetType.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/9/24.
//

import Foundation

import Alamofire

protocol TargetType: URLRequestConvertible {
    var baseURL: String { get }
    var method: HTTPMethod { get }
    var path: String { get }
    var parameters: RequestParams { get }
    var headerType: HTTPHeaderType { get }
    var authorization: Authorization { get }
}

extension TargetType {
    var baseURL: String {
        return Config.baseURL
    }
    var headers: [String: String]? {
        switch headerType {
        case .plain:
            return [
                HTTPHeaderFieldKey.contentType.rawValue: HTTPHeaderFieldValue.json.rawValue,
            ]
        case .hasToken:
            return [
                HTTPHeaderFieldKey.contentType.rawValue: HTTPHeaderFieldValue.json.rawValue,
                HTTPHeaderFieldKey.authentication.rawValue: KeychainHandler.shared.accessToken,
            ]
        case .refreshToken:
            return [
                HTTPHeaderFieldKey.contentType.rawValue: HTTPHeaderFieldValue.json.rawValue,
                HTTPHeaderFieldKey.refreshtoken.rawValue: KeychainHandler.shared.refreshToken,
            ]
        }}
}
extension TargetType {
    func asURLRequest() throws -> URLRequest {
        let url = try baseURL.asURL()
        let accessToken = KeychainHandler.shared.accessToken
        var urlRequest = try URLRequest(
            url: url.appendingPathComponent(path),
            method: method
        )
        
        switch authorization {
        case .authorization:
            urlRequest.setValue(KeychainHandler.shared.accessToken, forHTTPHeaderField: HTTPHeaderFieldKey.authentication.rawValue)
        case .unauthorization:
            break
        case .reAuthorization:
            urlRequest.setValue(KeychainHandler.shared.refreshToken, forHTTPHeaderField: HTTPHeaderFieldKey.authentication.rawValue)
        }
        
        switch headerType {
        case .plain:
            urlRequest.setValue(HTTPHeaderFieldValue.json.rawValue, forHTTPHeaderField: HTTPHeaderFieldKey.contentType.rawValue)
        case .hasToken:
            urlRequest.setValue(HTTPHeaderFieldValue.json.rawValue, forHTTPHeaderField: HTTPHeaderFieldKey.contentType.rawValue)
            urlRequest.setValue(KeychainHandler.shared.accessToken, forHTTPHeaderField: HTTPHeaderFieldKey.authentication.rawValue)
        case .refreshToken:
            urlRequest.setValue(HTTPHeaderFieldValue.json.rawValue, forHTTPHeaderField: HTTPHeaderFieldKey.contentType.rawValue)
            urlRequest.setValue(KeychainHandler.shared.refreshToken, forHTTPHeaderField: HTTPHeaderFieldKey.refreshtoken.rawValue)
        }
        
        switch parameters {
        case .requestWithBody(let request):
            let params = request?.toDictionary() ?? [:]
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: params)
        case .requestQuery(let request):
            let params = request?.toDictionary()
            let queryParams = params?.map {
                URLQueryItem(name: $0.key, value: "\($0.value)")
            }
            var components = URLComponents(
                string: url.appendingPathComponent(path).absoluteString)
            components?.queryItems = queryParams
            urlRequest.url = components?.url
        case .requestQueryWithBody(let queryRequest, let bodyRequest):
            let params = queryRequest?.toDictionary()
            let queryParams = params?.map {
                URLQueryItem(name: $0.key, value: "\($0.value)")
            }
            var components = URLComponents(
                string: url.appendingPathComponent(path).absoluteString)
            components?.queryItems = queryParams
            urlRequest.url = components?.url
            
            let bodyParams = bodyRequest?.toDictionary() ?? [:]
            
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: bodyParams)
        case .requestWithMultipart(let multipartFormDataClosure):
            
            var multipartFormData = MultipartFormData()
            multipartFormDataClosure(multipartFormData)
            
            urlRequest.httpBody = try multipartFormData.encode()
            urlRequest.setValue(multipartFormData.contentType, forHTTPHeaderField: HTTPHeaderFieldKey.contentType.rawValue)
        case .requestPlain:
            break
        }
        return urlRequest
    }
}

@frozen
enum RequestParams {
    case requestPlain
    case requestWithBody(_ paramter: Encodable?)
    case requestQuery(_ parameter: Encodable?)
    case requestQueryWithBody(_ queryParameter: Encodable?, bodyParameter: Encodable?)
    case requestWithMultipart(_ multipartFormData: (MultipartFormData) -> Void)
}

extension Encodable {
    func toDictionary() -> [String: Any] {
        guard let data = try? JSONEncoder().encode(self),
              let jsonData = try? JSONSerialization.jsonObject(with: data),
              let dictionaryData = jsonData as? [String: Any]
        else { return [:] }
        
        return dictionaryData
    }
}
