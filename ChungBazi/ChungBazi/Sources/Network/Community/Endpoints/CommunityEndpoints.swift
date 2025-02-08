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
    case getCommunityPosts(category: String, lastPostId: Int)
    case getCommunityPost(postId: Int)
    case getCommunityComments(postId: Int, lastCommentId: Int)
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
        case .getCommunityPosts(let category, let lastPostId):
            return .requestParameters(parameters: ["category": category, "lastPostId": lastPostId, "size": 10], encoding: URLEncoding.default)
        case .getCommunityPost:
            return .requestPlain
        case .getCommunityComments(let postId, let lastCommentId):
            return .requestParameters(parameters: ["postId": postId, "lastCommentId": lastCommentId, "size": 10], encoding: URLEncoding.default)
        case .postCommunityPost(let data, let imageList):
            var multipartData: [MultipartFormData] = []
            
            if let jsonData = try? JSONEncoder().encode(data) {
                let jsonFormData = MultipartFormData(
                    provider: .data(jsonData),
                    name: "info",
                    fileName: "info.json",
                    mimeType: "application/json"
                )
                multipartData.append(jsonFormData)
            }
            
            for image in imageList {
                let fileName = "\(UUID().uuidString).jpeg"
                if let imageData = image.jpegData(compressionQuality: 0.8) {
                    let imageFormData = MultipartFormData(
                        provider: .data(imageData),
                        name: "imageList", // 같은 key로 여러 개의 파일을 보냄
                        fileName: fileName,
                        mimeType: "image/jpeg"
                    )
                    multipartData.append(imageFormData)
                }
            }
            
            return .uploadMultipart(multipartData)
        case .postCommunityComment(let data):
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
