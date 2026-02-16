//
//  ReportsEndpoints.swift
//  ChungBazi
//
//  Created by 신호연 on 9/22/25.
//

import Foundation
import Moya

enum ReportsEndpoints {
    case reportPost(postId: Int, body: ReportRequestDTO)
    case reportComment(commentId: Int, body: ReportRequestDTO)
}

extension ReportsEndpoints: AuthenticatedTarget {
    public var baseURL: URL {
        guard let url = URL(string: API.baseURL) else {
            fatalError("잘못된 baseURL")
        }
        return url
    }

    var path: String {
        switch self {
        case .reportPost(let postId, _):
            return "/reports/posts/\(postId)"
        case .reportComment(let commentId, _):
            return "/reports/comments/\(commentId)"
        }
    }

    var method: Moya.Method { .post }

    var task: Task {
        switch self {
        case .reportPost(_, let body),
             .reportComment(_, let body):
            return .requestJSONEncodable(body)
        }
    }
    
    var requiresAuthentication: Bool {
        true
    }

    var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
}
