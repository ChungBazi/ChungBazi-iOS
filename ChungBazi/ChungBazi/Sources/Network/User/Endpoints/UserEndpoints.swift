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
    case updateProfile(data: ProfileUpdateRequestDto, profileImg: String)
    case postUserInfo(data: UserInfoRequestDto)
    case updateUserInfo(data: UserInfoRequestDto)
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
        case .updateProfile(let data, let profileImg):
            if let jsonData = try? JSONEncoder().encode(data) {
                let jsonFormData = MultipartFormData(
                    provider: .data(jsonData),
                    name: "info",
                    fileName: "info.json",
                    mimeType: "application/json"
                )
                return .uploadMultipart([jsonFormData])
            }
            return .requestPlain
//        case .updateProfile(let data, let profileImg):
//            var multipartData: [MultipartFormData] = []
//            
//            if let jsonData = try? JSONEncoder().encode(data) {
//                let jsonFormData = MultipartFormData(
//                    provider: .data(jsonData),
//                    name: "info",
//                    fileName: "info.json",
//                    mimeType: "application/json"
//                )
//                multipartData.append(jsonFormData)
//            }
//            
//            let fileName = "\(UUID().uuidString).jpeg"
//            if let imageData = profileImg.jpegData(compressionQuality: 0.8) {
//                let imageFormData = MultipartFormData(
//                    provider: .data(imageData),
//                    name: "profileImg",
//                    fileName: fileName,
//                    mimeType: "image/jpeg"
//                )
//                multipartData.append(imageFormData)
//            }
//            
//            return .uploadMultipart(multipartData)
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
