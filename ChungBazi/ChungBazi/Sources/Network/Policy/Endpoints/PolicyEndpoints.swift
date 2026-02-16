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
    case fetchCategoryPolicy(category: String, cursor: String, order: String)
    case fetchPolicyDetail(policyId: Int)
    case fetchCalendarPolicyList(yearMonth: String)
    case fetchRecommendPolicy(category: String, cursor: String, order: String)
    case fetchCalendarPolicyDetail(cartId: Int)
}

extension PolicyEndpoints: AuthenticatedTarget {
    
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
        case .fetchCategoryPolicy:
            return ""
        case .fetchPolicyDetail(let policyId):
            return "/\(policyId)"
        case .fetchCalendarPolicyList:
            return "/calendar"
        case .fetchRecommendPolicy:
            return "/recommend"
        case .fetchCalendarPolicyDetail(let cartId):
            return  "/calendar/\(cartId)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        default :
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .searchPolicy(let name, let cursor, let order):
            return .requestParameters(parameters: ["name": name, "cursor": cursor, "size": 15, "order": order], encoding: URLEncoding.queryString)
        case .fetchPopularSearchText:
            return .requestPlain
        case .fetchCategoryPolicy(let category, let cursor, let order):
            return .requestParameters(parameters: ["category": category, "cursor": cursor, "size": 15, "order": order], encoding: URLEncoding.queryString)
        case .fetchPolicyDetail(_):
            return .requestPlain
        case .fetchCalendarPolicyList(let yearMonth):
            return .requestParameters(parameters: ["yearMonth": yearMonth], encoding: URLEncoding.queryString)
        case .fetchRecommendPolicy(let category, let cursor, let order):
            return .requestParameters(parameters: ["category": category, "cursor": cursor, "order": order], encoding: URLEncoding.queryString)
        case .fetchCalendarPolicyDetail:
            return .requestPlain
        }
    }
    
    var requiresAuthentication: Bool {
        true
    }
    
    var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
}
