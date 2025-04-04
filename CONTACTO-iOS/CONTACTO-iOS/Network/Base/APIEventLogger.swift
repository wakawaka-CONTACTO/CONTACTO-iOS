//
//  APIEventLogger.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/9/24.
//

import Foundation

import Alamofire

final class APIEventLogger: EventMonitor {
    func requestDidFinish(_ request: Request) {
        #if DEBUG
        print("===========================🛰 NETWORK Request LOG===========================")
        print(request.description)
        
        print(
            "URL: " + (request.request?.url?.absoluteString ?? "")  + "\n"
            + "Method: " + (request.request?.httpMethod ?? "") + "\n"
            + "Headers: " + "\(request.request?.allHTTPHeaderFields ?? [:])" + "\n"
        )
        print("Authorization: " + (request.request?.headers["Authorization"] ?? ""))
        print("Body: " + (request.request?.httpBody?.toPrettyPrintedString ?? ""))
        #endif
    }
    
    func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
        #if DEBUG
        print("===========================🛰 NETWORK Response LOG===========================")
        print(
            "URL: " + (request.request?.url?.absoluteString ?? "") + "\n"
            + "Result: " + "\(response.result)" + "\n"
            + "StatusCode: " + "\(response.response?.statusCode ?? 0)" + "\n"
            + "Data: \(response.data?.toPrettyPrintedString ?? "")"
        )
        #endif
    }
}

extension Data {
    var toPrettyPrintedString: String? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }
        return prettyPrintedString as String
    }
}
