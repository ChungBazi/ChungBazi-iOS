//
//  AlarmModel.swift
//  ChungBazi
//
//  Created by 이현주 on 2/6/25.
//

import UIKit
struct AlarmModel {
    let notificationId: Int
    let message: String
    let type: AlarmType
    let targetId: Int?
    let sentTime: String
    
    init(notificationId: Int, message: String, type: AlarmType, targetId: Int?, sentTime: String) {
        self.notificationId = notificationId
        self.message = message
        self.type = type
        self.targetId = targetId
        self.sentTime = sentTime
    }
}

enum AlarmType: String {
    case entire = ""
    case policy = "POLICY"
    case community = "COMMUNITY"
    case reward = "REWARD"
    case notice = "NOTICE"
    case chat = "CHAT"
    case unknown // 예외 처리 (예상치 못한 값 대응)
    
    // rawValue -> AlarmType
    static func from(_ rawValue: String) -> AlarmType {
        return AlarmType(rawValue: rawValue) ?? .unknown
    }
    
    // 각 타입에 맞는 이미지 이름 반환
    var image: UIImage? {
        switch self {
        case .policy:
            return .alarmCalendarIcon
        case .community:
            return .alarmCommunityIcon
        case .reward:
            return .alarmRewardIcon
        case .unknown, .entire, .notice, .chat:
            return nil
        }
    }
}
