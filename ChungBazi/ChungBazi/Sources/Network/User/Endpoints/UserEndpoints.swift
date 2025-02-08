//
//  UserEndpoints.swift
//  ChungBazi
//
//  Created by 이현주 on 1/27/25.
//

import Foundation
import Moya
import KeychainSwift

enum UserEndpoints {
    case fetchProfile
    case updateUserInfo(data: UserInfoRequestDto)
    case postUserInfo(data: UserInfoRequestDto)
    case updateProfile(data: ProfileUpdateRequestDto)
}

extension UserEndpoints: TargetType {
    public var baseURL: URL {
        guard let url = URL(string: API.userURL) else {
            fatalError("잘못된 URL")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .fetchProfile:
            return "/profile"
        case .updateUserInfo:
            return "/update"
        case .postUserInfo:
            return "/register"
        case .updateProfile:
            return "/profile/update"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchProfile:
            return .get
        case .updateUserInfo, .updateProfile:
            return .patch
        case .postUserInfo:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .fetchProfile:
            return .requestPlain
        case .updateUserInfo(let data):
            return .requestJSONEncodable(data)
        case .postUserInfo(let data):
            return .requestJSONEncodable(data)
        case .updateProfile(let data):
            return .requestJSONEncodable(data)
        }
    }
    
    var headers: [String : String]? {
        let accessToken = KeychainSwift().get("serverAccessToken")
        return [
            "Authorization": "Bearer \(accessToken!)",
            "Content-type": "application/json"
        ]
    }
}
