//
//  AuthEndpoints.swift
//  ChungBazi
//
//  Created by 이현주 on 1/27/25.
//

import Foundation
import Moya

enum AuthEndpoints {
    case postKakaoLogin(data: KakaoLoginRequestDto)
    case postAppleLogin(data: AppleLoginRequestDto)
    case postLogout
    case deleteUser
    case postReIssueToken(data: ReIssueRequestDto)
    case postResetPassword(data: ResetPasswordRequestDto)
    case postResetPasswordNoAuth(data: ResetPasswordNoAuthRequestDto)
    case postRegister(data: RegisterRequestDto)
    case postRegisterNickname(data: RegisterNicknameRequestDto)
    case postLogin(data: LoginRequestDto)
}

extension AuthEndpoints: AuthenticatedTarget {
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
            return "/logout"
        case .postAppleLogin:
            return "/apple-login"
        case .deleteUser:
            return "/delete-account"
        case .postReIssueToken:
            return "/refresh-token"
        case .postResetPassword:
            return "/reset-password"
        case .postResetPasswordNoAuth:
            return "/reset-password/no-auth"
        case .postRegister:
            return "/register"
        case .postRegisterNickname:
            return "/register-nickname"
        case .postLogin:
            return "/login"
            
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .postLogout, .postReIssueToken, .postKakaoLogin, .postAppleLogin, .postResetPassword, .postResetPasswordNoAuth, .postRegister, .postRegisterNickname, .postLogin:
            return .post
        case .deleteUser:
            return .delete
        }
    }
    
    var task: Task {
        switch self {
        case .postLogout, .deleteUser:
            return .requestPlain
        case .postKakaoLogin(let data):
            return .requestJSONEncodable(data)
        case .postAppleLogin(let data):
            return .requestJSONEncodable(data)
        case .postReIssueToken(let data):
            return .requestJSONEncodable(data)
        case .postResetPassword(let data):
            return .requestJSONEncodable(data)
        case .postResetPasswordNoAuth(let data):
            return .requestJSONEncodable(data)
        case .postRegister(let data):
            return .requestJSONEncodable(data)
        case .postRegisterNickname(let data):
            return .requestJSONEncodable(data)
        case .postLogin(let data):
            return .requestJSONEncodable(data)
        }
    }
    
    var requiresAuthentication: Bool {
        switch self {
        case .postLogin, .postKakaoLogin, .postAppleLogin, .postRegisterNickname, .postRegister, .postReIssueToken, .postResetPasswordNoAuth:
            return false
        default:
            return true
        }
    }
    
    var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
    
    private func isLikelyJWT(_ s: String) -> Bool {
        let parts = s.split(separator: ".")
        return parts.count == 3 && parts.allSatisfy { !$0.isEmpty } && s.count > 30
    }
}
