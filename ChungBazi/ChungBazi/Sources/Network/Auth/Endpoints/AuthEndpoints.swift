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
    case postAppleLogin(data: AppleLoginRequestDto)
    case postLogout
    case deleteUser
    case postReIssueToken(data: ReIssueRequestDto)
    case postResetPassword(data: ResetPasswordRequestDto)
    case postRegister(data: RegisterRequestDto)
    case postRegisterNickname(data: RegisterNicknameRequestDto)
    case postLogin(data: LoginRequestDto)
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
            return "/logout"
        case .postAppleLogin:
            return "/apple-login"
        case .deleteUser:
            return "/delete-account"
        case .postReIssueToken:
            return "/refresh-token"
        case .postResetPassword:
            return "/reset-password"
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
        case .postLogout, .postReIssueToken, .postKakaoLogin, .postAppleLogin, .postResetPassword, .postRegister, .postRegisterNickname, .postLogin:
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
        case .postRegister(let data):
            return .requestJSONEncodable(data)
        case .postRegisterNickname(let data):
            return .requestJSONEncodable(data)
        case .postLogin(let data):
            return .requestJSONEncodable(data)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .postKakaoLogin, .postAppleLogin, .postReIssueToken,
             .postRegister, .postRegisterNickname, .postLogin:
            return ["Content-Type": "application/json"]

        case .postResetPassword, .postLogout, .deleteUser:
            let accessToken = KeychainSwift().get("serverAccessToken") ?? ""
            return [
                "Authorization": "Bearer \(accessToken)",
                "Content-type": "application/json"
            ]
        }
    }
}
