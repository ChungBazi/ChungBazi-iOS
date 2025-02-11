//
//  CalendarEndpoints.swift
//  ChungBazi
//
//  Created by 이현주 on 1/27/25.
//

import Foundation
import Moya
import KeychainSwift

enum CalendarEndpoints {
    case getCalendarPolicies(yearMonth: String)
}

extension CalendarEndpoints: TargetType {
    
    public var baseURL: URL {
        guard let url = URL(string: API.baseURL) else {
            fatalError("잘못된 URL")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .getCalendarPolicies:
            return "/policies/calendar"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getCalendarPolicies:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .getCalendarPolicies(let yearMonth):
            let parameters: [String: Any] = ["yearMonth": yearMonth]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
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
