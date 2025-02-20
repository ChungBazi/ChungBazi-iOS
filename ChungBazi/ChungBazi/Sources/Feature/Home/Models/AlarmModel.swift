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
    let policyId: Int?
    let postId: Int?
    let sentTime: String
    
    init(notificationId: Int, message: String, type: AlarmType, policyId: Int?, postId: Int?, sentTime: String) {
        self.notificationId = notificationId
        self.message = message
        self.type = type
        self.policyId = policyId
        self.postId = postId
        self.sentTime = sentTime
    }
}

enum AlarmType: String {
    case entire = ""
    case policy = "POLICY_ALARM"
    case community = "COMMUNITY_ALARM"
    case reward = "REWARD_ALARM"
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
        case .unknown, .entire:
            return nil
        }
    }
}
