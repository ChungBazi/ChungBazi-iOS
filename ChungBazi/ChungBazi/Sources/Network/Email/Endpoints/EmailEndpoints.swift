//
//  EmailEndpoints.swift
//  ChungBazi
//
//  Created by 엄민서 on 8/28/25.
//

import Foundation
import Moya
import KeychainSwift

enum EmailEndpoints {
    case postEmailRequest(email: String)
    case postEmailRequestNoAuth(email: String)
    case postEmailVerification(email: String, authCode: String)
}

extension EmailEndpoints: TargetType {
    public var baseURL: URL {
        guard let url = URL(string: API.emailURL) else {
            fatalError("잘못된 URL")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .postEmailRequest:
            return "/verification-requests"
        case .postEmailRequestNoAuth:     
            return "/verification-requests/no-authorization"
        case .postEmailVerification:
            return "/verification"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .postEmailRequest, .postEmailRequestNoAuth, .postEmailVerification:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .postEmailRequest(let email):
            return .requestParameters(
                parameters: ["email": email],
                encoding: JSONEncoding.default
            )
        case .postEmailRequestNoAuth(let email):
                    return .requestParameters(
                        parameters: ["email": email],
                        encoding: URLEncoding.httpBody
                    )
        case .postEmailVerification(let email, let authCode):
            return .requestParameters(
                parameters: ["email": email, "authCode": authCode],
                encoding: JSONEncoding.default
            )
        }
    }

    var headers: [String : String]? {
        switch self {
        case .postEmailRequestNoAuth:
            return ["Content-Type": "application/x-www-form-urlencoded"]
        case .postEmailVerification:
            return ["Content-Type": "application/json"]
        case .postEmailRequest:
            var headers = ["Content-Type": "application/json"]
            if let token = KeychainSwift().get("serverAccessToken"), !token.isEmpty {
                headers["Authorization"] = "Bearer \(token)"
            }
            return headers
        }
    }
}
