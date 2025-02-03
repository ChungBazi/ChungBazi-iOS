//
//  CommunityEndpoints.swift
//  ChungBazi
//
//  Created by 이현주 on 1/27/25.
//

import Foundation
import Moya

enum CommunityEndpoints {
    case getCommunityPosts(data: CommunityRequestDTO)
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
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getCommunityPosts:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .getCommunityPosts(let data):
            var parameters: [String: Any] = [
                "lastPostId": data.lastPostId,
                "size": data.size
            ]
            if data.category != .all {
                parameters["category"] = data.category.rawValue
            }

            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        return [
            "Content-type" : "application/json"
        ]
    }
}
