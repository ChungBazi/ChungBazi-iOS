//
//  NotificationResponseDTOs.swift
//  ChungBazi
//
//  Created by 이현주 on 1/27/25.
//

struct NoticeListResponseDto: Decodable {
    let notifications: [notificationInfo]
    let nextCursor: Int
    let hasNext: Bool
    
    init(notifications: [notificationInfo], nextCursor: Int, hasNext: Bool) {
        self.notifications = notifications
        self.nextCursor = nextCursor
        self.hasNext = hasNext
    }
}

struct notificationInfo: Decodable {
    let notificationId: Int
    let message: String
    let type: String
    let read: Bool
    
    init(notificationId: Int, message: String, type: String, read: Bool) {
        self.notificationId = notificationId
        self.message = message
        self.type = type
        self.read = read
    }
}
