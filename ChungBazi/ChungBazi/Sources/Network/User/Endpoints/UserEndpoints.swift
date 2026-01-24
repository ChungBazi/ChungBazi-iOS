//
//  UserEndpoints.swift
//  ChungBazi
//
//  Created by 이현주 on 1/27/25.
//

import Foundation
import UIKit
import Moya
import KeychainSwift

enum UserEndpoints {
    case fetchProfile
    case updateProfile(data: ProfileUpdateRequestDto)
    case fetchReward
    case fetchUserInfo
    case postUserInfo(data: UserInfoRequestDto)
    case updateUserInfo(data: UserInfoRequestDto)
    case fetchProfileImg
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
        case .fetchReward:
            return "/reward"
        case .fetchUserInfo:
            return "/information"
        case .postUserInfo:
            return "/register"
        case .updateProfile:
            return "/profile/update"
        case .fetchProfileImg:
            return "/characterImg"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchProfile, .fetchReward, .fetchProfileImg, .fetchUserInfo:
            return .get
        case .updateUserInfo, .updateProfile:
            return .patch
        case .postUserInfo:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .fetchProfile, .fetchReward, .fetchProfileImg, .fetchUserInfo:
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
