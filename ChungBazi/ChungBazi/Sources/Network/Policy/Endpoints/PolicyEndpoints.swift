//
//  PolicyEndpoints.swift
//  ChungBazi
//
//  Created by 이현주 on 1/27/25.
//

import Foundation
import Moya

enum PolicyEndpoints {
    case searchPolicy(name: String, cursor: String, order: String)
    case fetchPopularSearchText
}

extension PolicyEndpoints: TargetType {
    
    public var baseURL: URL {
        guard let url = URL(string: API.policyURL) else {
            fatalError("잘못된 URL")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .searchPolicy:
            return "/search"
        case .fetchPopularSearchText:
            return "/search/popular"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .searchPolicy, .fetchPopularSearchText:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .searchPolicy(let name, let cursor, let order):
            return .requestParameters(parameters: ["name": name, "cursor": cursor, "size": 15, "order": order], encoding: URLEncoding.default)
        case .fetchPopularSearchText:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return [
            "Content-type": "application/json"
        ]
    }
}
