//
//  ChatbotEndpoints.swift
//  ChungBazi
//
//  Created by 신호연 on 12/11/25.
//

import Foundation
import Moya

enum ChatbotEndpoints {
    case getPolicyDetail(policyId: Int)
    case getPolicies(category: ChatbotCategory)
    case ask(data: ChatbotAskRequestDto)
}

extension ChatbotEndpoints: TargetType {
    
    public var baseURL: URL {
        guard let url = URL(string: API.chatbotURL) else {
            fatalError("잘못된 URL")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .getPolicyDetail(let policyId):
            return "/\(policyId)"
        case .getPolicies:
            return "/policies"
        case .ask:
            return "/ask"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getPolicyDetail, .getPolicies:
            return .get
        case .ask:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .getPolicyDetail:
            return .requestPlain
        case .getPolicies(let category):
            return .requestParameters(
                parameters: ["category": category.rawValue],
                encoding: URLEncoding.queryString
            )
        case .ask(let data):
            return .requestJSONEncodable(data)
        }
    }
    
    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
}
