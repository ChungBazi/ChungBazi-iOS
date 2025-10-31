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
        case .postEmailVerification:
            return "/verification"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .postEmailRequest, .postEmailVerification:
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
        case .postEmailVerification(let email, let authCode):
            return .requestParameters(
                parameters: ["email": email, "authCode": authCode],
                encoding: JSONEncoding.default
            )
        }
    }

    var headers: [String : String]? {
        var headers: [String: String] = ["Content-Type": "application/json"]
        if let token = KeychainSwift().get("serverAccessToken"), !token.isEmpty {
            headers["Authorization"] = "Bearer \(token)"
        }
        return headers
    }
}
