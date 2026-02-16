//
//  BlockEndpoints.swift
//  ChungBazi
//
//  Created by 신호연 on 9/18/25.
//

import Foundation
import Moya

enum BlockEndpoints {
    case postBlock(blockedUserId: Int)
}

extension BlockEndpoints: AuthenticatedTarget {
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
    
    var requiresAuthentication: Bool {
        return true
    }

    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
}
