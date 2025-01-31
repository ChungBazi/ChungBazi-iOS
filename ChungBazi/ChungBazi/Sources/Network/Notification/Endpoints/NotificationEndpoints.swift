//
//  NotificationEndpoints.swift
//  ChungBazi
//
//  Created by 이현주 on 1/27/25.
//

import Foundation
import Moya

enum NotificationEndpoints {
    case fetchAlarmList(type: String, cursor: Int)
}

extension NotificationEndpoints: TargetType {
    
    public var baseURL: URL {
        guard let url = URL(string: API.notificationURL) else {
            fatalError("잘못된 URL")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .fetchAlarmList:
            return "/notifications"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchAlarmList:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .fetchAlarmList(let type, let cursor):
            return .requestParameters(parameters: ["type": type, "cursor": cursor, "limit": 15], encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return [
            "Content-type": "application/json"
        ]
    }
}
