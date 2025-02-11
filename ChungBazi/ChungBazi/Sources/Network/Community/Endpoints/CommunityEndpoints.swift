//
//  CommunityEndpoints.swift
//  ChungBazi
//
//  Created by 이현주 on 1/27/25.
//

import Foundation
import UIKit
import Moya
import KeychainSwift

enum CommunityEndpoints {
    case getCommunityPosts(category: String, cursor: Int)
    case getCommunityPost(postId: Int)
    case getCommunityComments(postId: Int, cursor: Int)
    case postCommunityPost(data: CommunityPostRequestDto, imageList: [UIImage])
    case postCommunityComment(data: CommunityCommentRequestDto)
}

extension CommunityEndpoints: TargetType {
    
    public var baseURL: URL {
        guard let url = URL(string: API.communityURL) else {
            fatalError("잘못된 URL")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .getCommunityPosts:
            return "/posts"
        case .getCommunityPost(let postId):
            return "/posts/\(postId)"
        case .getCommunityComments:
            return "/comments"
        case .postCommunityPost:
            return "/posts/upload"
        case .postCommunityComment:
            return "/comments/upload"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getCommunityPosts, .getCommunityPost, .getCommunityComments:
            return .get
        case .postCommunityPost, .postCommunityComment:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .getCommunityPosts(let category, let cursor):
            var parameters: [String: Any] = ["size": 10, "cursor": 0]
            if !category.isEmpty {
                parameters["category"] = category
            }
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)

        case .getCommunityComments(let postId, let cursor):
            let parameters: [String: Any] = [
                "postId": postId,
                "cursor": cursor,
                "size": 10
            ]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)

        case .getCommunityPost:
            return .requestPlain

        case .postCommunityPost(let data, let imageList):
            var multipartData: [MultipartFormData] = []

            do {
                let jsonData = try JSONEncoder().encode(data)
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    multipartData.append(
                        MultipartFormData(provider: .data(jsonData), name: "info", mimeType: "application/json")
                    )
                }
            } catch {
                print("JSON 인코딩 실패: \(error.localizedDescription)")
                return .requestPlain
            }

            for image in imageList.prefix(10) {
                if let imageData = image.jpegData(compressionQuality: 0.8) {
                    let fileName = "\(UUID().uuidString).jpg"
                    multipartData.append(
                        MultipartFormData(provider: .data(imageData), name: "imageList", fileName: fileName, mimeType: "image/jpeg")
                    )
                }
            }

            return .uploadMultipart(multipartData)

        case .postCommunityComment(let data):
            return .requestJSONEncodable(data)
        }
    }
    
    var headers: [String : String]? {
        guard let accessToken = KeychainSwift().get("serverAccessToken") else {
            return ["Content-type": "application/json"]
        }
        return [
            "Authorization": "Bearer \(accessToken)",
            "Content-type": "application/json"
        ]
    }
}
