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
    case searchCommunity(query: String, filter: String, period: String, cursor: Int)
    case getCommunityPopularWords
    case postCommunityLike(postId: Int)
    case deleteCommunityLike(postId: Int)
    case deleteCommunityPost(postId: Int)
    case deleteCommunityComment(commentId: Int)
    case postLike(postId: Int)
    case deleteLike(postId: Int)
    case postCommentLike(commentId: Int)
    case deleteCommentLike(commentId: Int)
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
        case .searchCommunity:
            return "/search"
        case .getCommunityPopularWords:
            return "/search/popular"
        case .deleteCommunityLike, .postCommunityLike:
            return "/likes"
        case .deleteCommunityPost(let postId):
            return "/posts/\(postId)"
        case .deleteCommunityComment(let commentId):
            return "/comments/\(commentId)"
        case .postLike:
            return "/community/likes"
        case .deleteLike:
            return "/community/likes"
        case .postCommentLike(let commentId):
            return "/community/likes/\(commentId)"
        case .deleteCommentLike(let commentId):
            return "/community/likes/\(commentId)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getCommunityPosts, .getCommunityPost, .getCommunityComments, .searchCommunity, .getCommunityPopularWords:
            return .get
        case .postCommunityPost, .postCommunityComment, .postCommunityLike, .postLike, .postCommentLike:
            return .post
        case .deleteCommunityLike, .deleteCommunityPost, .deleteCommunityComment, .deleteLike, .deleteCommentLike:
            return .delete
        }
    }
    
    var task: Task {
        switch self {
        case .getCommunityPosts(let category, let cursor):
            var parameters: [String: Any] = ["size": 10, "cursor": cursor]
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
        case .searchCommunity(let query, let filter, let period, let cursor):
            return .requestParameters(parameters: ["query": query, "filter": filter, "period": period, "cursor": cursor, "size": 10], encoding: URLEncoding.queryString)
        case .getCommunityPopularWords:
            return .requestPlain
        case .postCommunityLike(let postId), .deleteCommunityLike(let postId), .postLike(let postId), .deleteLike(let postId):
            return .requestParameters(parameters: ["postId": postId], encoding: URLEncoding.queryString)
        case .deleteCommunityPost, .deleteCommunityComment, .postCommentLike, .deleteCommentLike:
            return .requestPlain
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
