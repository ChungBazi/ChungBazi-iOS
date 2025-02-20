//
//  NotificationResponseDTOs.swift
//  ChungBazi
//
//  Created by 이현주 on 1/27/25.
//

struct NoticeListResponseDto: Decodable {
    let notifications: [NotificationInfo]?
    let nextCursor: Int?
    let hasNext: Bool
}

struct NotificationInfo: Decodable {
    let notificationId: Int?
    let message: String?
    let type: String?
    let policyId: Int?
    let postId: Int?
    let formattedCreatedAt: String?
    let read: Bool?
}

struct NoticeSettingResponseDto: Decodable {
    let policyAlarm: Bool
    let communityAlarm: Bool
    let rewardAlarm: Bool
    let noticeAlarm: Bool
}

