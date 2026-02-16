//
//  EmailEndpoints.swift
//  ChungBazi
//
//  Created by 엄민서 on 8/28/25.
//

import Foundation
import Moya

enum EmailEndpoints {
    case postEmailRequest(email: String)
    case postEmailRequestNoAuth(email: String)
    case postEmailVerification(email: String, authCode: String)
}

extension EmailEndpoints: AuthenticatedTarget {
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
    
    var requiresAuthentication: Bool {
        switch self {
        case .postEmailRequestNoAuth, .postEmailVerification:
            return false
        default:
            return true
        }
    }

    var headers: [String : String]? {
        switch self {
        case .postEmailRequestNoAuth:
            return ["Content-Type": "application/x-www-form-urlencoded"]
        case .postEmailVerification:
            return ["Content-Type": "application/json"]
        case .postEmailRequest:
            return ["Content-Type": "application/json"]
        }
    }
}
