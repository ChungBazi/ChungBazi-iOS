//
//  AuthEndpoints.swift
//  ChungBazi
//
//  Created by 이현주 on 1/27/25.
//

import Foundation
import Moya
import KeychainSwift

enum AuthEndpoints {
    case postKakaoLogin(data: KakaoLoginRequestDto)
    case postLogout
    case deleteUser
    case postReIssueToken(data: ReIssueRequestDto)
}

extension AuthEndpoints: TargetType {
    public var baseURL: URL {
        guard let url = URL(string: API.authURL) else {
            fatalError("잘못된 URL")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .postKakaoLogin:
            return "/kakao-login"
        case .postLogout:
            return "/kakao-logout"
        case .deleteUser:
            return "/delete-account"
        case .postReIssueToken:
            return "/refresh-token"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .postLogout, .postReIssueToken, .postKakaoLogin, .deleteUser:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .postLogout, .deleteUser:
            return .requestPlain
        case .postKakaoLogin(let data):
            return .requestJSONEncodable(data)
        case .postReIssueToken(let data):
            return .requestJSONEncodable(data)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .postKakaoLogin:
            return ["Content-Type": "application/json"]
        default:
            let accessToken = KeychainSwift().get("serverAccessToken")
            return [
                "Authorization": "Bearer \(accessToken!)",
                "Content-type": "application/json"
            ]
        }
    }
}
