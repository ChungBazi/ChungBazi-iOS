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
    case fetchAlarmSetting
    case patchAlarmSetting(data: NoticeSettingRequestDto)
}

extension NotificationEndpoints: AuthenticatedTarget {
    
    public var baseURL: URL {
        guard let url = URL(string: API.notificationURL) else {
            fatalError("잘못된 URL")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .fetchAlarmList:
            return ""
        case .fetchAlarmSetting:
            return "/settings"
        case .patchAlarmSetting:
            return "settings-up"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchAlarmList, .fetchAlarmSetting:
            return .get
        case .patchAlarmSetting:
            return .patch
        }
    }
    
    var task: Task {
        switch self {
        case .fetchAlarmList(let type, let cursor):
            return .requestParameters(parameters: ["type": type, "cursor": cursor, "limit": 15], encoding: URLEncoding.queryString)
        case .fetchAlarmSetting:
            return .requestPlain
        case .patchAlarmSetting(let data):
            return .requestJSONEncodable(data)
        }
    }
    
    var requiresAuthentication: Bool {
        true
    }
    
    var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
}
