//
//  AuthEndpoints.swift
//  ChungBazi
//
//  Created by 이현주 on 1/27/25.
//

import Foundation
import Moya

enum AuthEndpoints {
    case postKakaoLogin(data : KakaoLoginRequestDTO)
    case postLogout
    case deleteUser
    case postReIssueToken
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
        case .deleteUser:
            return .delete
        case .postLogout, .postReIssueToken, .postKakaoLogin:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .postLogout, .deleteUser, .postReIssueToken:
            return .requestPlain
        case .postKakaoLogin(let data) :
            return .requestJSONEncodable(data)
        }
    }
    
    var headers: [String : String]? {
        var headers: [String: String] = [
            "Content-type": "application/json"
        ]
        
        switch self {
        case .postReIssueToken, .postLogout, .deleteUser:
            if let cookies = HTTPCookieStorage.shared.cookies {
                let cookieHeader = HTTPCookie.requestHeaderFields(with: cookies)
                for (key, value) in cookieHeader {
                    headers[key] = value // 쿠키를 헤더에 추가
                }
            }
        default:
            break
        }
        
        return headers
    }
}
