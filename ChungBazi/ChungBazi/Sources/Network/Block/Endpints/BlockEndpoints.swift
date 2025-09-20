//
//  BlockEndpoints.swift
//  ChungBazi
//
//  Created by 신호연 on 9/18/25.
//

import Foundation
import Moya
import KeychainSwift

enum BlockEndpoints {
    case postBlock(blockedUserId: Int)
}

extension BlockEndpoints: TargetType {
    var baseURL: URL {
        guard let url = URL(string: API.baseURL) else {
            fatalError("잘못된 URL")
        }
        return url
    }

    var path: String {
        switch self {
        case .postBlock(let id):
            return "/block/\(id)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .postBlock: return .post
        }
    }

    var task: Task {
        return .requestPlain
    }

    var headers: [String: String]? {
        if let token = KeychainSwift().get("serverAccessToken") {
            return [
                "Authorization": "Bearer \(token)",
                "Content-Type": "application/json"
            ]
        }
        return ["Content-Type": "application/json"]
    }
}
