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
    case postEmailRequest
    case postEmailVerification(data: EmailVerificationRequestDTO)
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
        case .postEmailRequest:
            return .requestPlain
        case .postEmailVerification(let data):
            return .requestJSONEncodable(data)
        }
    }
    
    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
}
