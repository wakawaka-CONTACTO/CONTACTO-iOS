//
//  APIRequestLoader.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/9/24.
//

import Foundation

import Alamofire

class APIRequestLoader<T: TargetType> {
    private let configuration: URLSessionConfiguration
    private let apiLogger: APIEventLogger
    private let session: Session
    private let interceptorSession: Session
    let interceptor = ContactoRequestInterceptor()
    
    init(
        configuration: URLSessionConfiguration = .default,
        apiLogger: APIEventLogger
    ) {
        // URLCache 설정
        let cacheSize = 50 * 1024 * 1024 // 50MB
        let cache = URLCache(memoryCapacity: cacheSize, diskCapacity: cacheSize, directory: nil)
        configuration.urlCache = cache
        
        // 타임아웃 설정
        configuration.timeoutIntervalForRequest = 30 // 30초
        configuration.timeoutIntervalForResource = 60 // 60초
        
        self.configuration = configuration
        self.apiLogger = apiLogger
        
        self.session = Session(configuration: configuration, eventMonitors: [apiLogger])
        self.interceptorSession = Session(configuration: configuration, interceptor: interceptor, eventMonitors: [apiLogger])
    }
    
    func fetchData<M: Decodable>(
        target: T,
        responseData: M.Type,
        completion: @escaping (NetworkResult<M>) -> Void
    ) {
        var dataRequest = session.request(target)
        
        if target.authorization == .authorization {
            dataRequest = interceptorSession.request(target).validate()
        }
        
        dataRequest.responseData(emptyResponseCodes: [200]) { response in
            switch response.result {
            case .success:
                guard let statusCode = response.response?.statusCode else { return }
                guard let value = response.value else { return }
                
                let networkRequest = self.judgeStatus(by: statusCode, value, type: M.self)
                completion(networkRequest)
            case .failure:
                guard let statusCode = response.response?.statusCode else { return }
                guard let data = response.data else { return }
                
                let networkRequest = self.judgeStatus(by: statusCode, data, type: M.self)
                completion(networkRequest)
            }
        }
    }
    
    private func judgeStatus<M: Decodable>(by statusCode: Int, _ data: Data, type: M.Type) -> NetworkResult<M> {
        switch statusCode {
        case 200...299:
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let status = json["status"] as? String,
               status == "NOT_FOUND" {
                let error = NetworkError(data: data, statusCode: 404, underlyingError: nil)
                return .failure(error)
            }
            return isValidData(data: data, type: M.self)
            
        case 400...499: 
            let error = NetworkError(data: data, statusCode: statusCode, underlyingError: nil)
            return .failure(error)
            
        case 500...599: 
            let error = NetworkError(data: data, statusCode: statusCode, underlyingError: nil)
            return .failure(error)
            
        default:
            let error = NetworkError(data: data, statusCode: statusCode, underlyingError: nil)
            return .failure(error)
        }
    }
    
    private func isValidData<M: Decodable>(data: Data, type: M.Type) -> NetworkResult<M> {
        if data.isEmpty, M.self == EmptyResponse.self {
            guard let emptyResponse = EmptyResponse() as? M else{
                return .pathErr
            }
            return .success(emptyResponse)
        }

        let decoder = JSONDecoder()

        do {
            let members = try decoder.decode(M.self, from: data)
        } catch let DecodingError.dataCorrupted(context) {
            print(context)
        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.valueNotFound(value, context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.typeMismatch(type, context) {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch {
            print("error: ", error)
            print(error.localizedDescription)
        }
        guard let decodedData = try? decoder.decode(M.self, from: data) else {
            print("json decoded failed !")
            return .pathErr
        }
        
        return .success(decodedData)
    }
}
