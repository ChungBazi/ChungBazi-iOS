//
//  NotificationResponseDTOs.swift
//  ChungBazi
//
//  Created by 이현주 on 1/27/25.
//

struct NoticeListResponseDto: Decodable {
    let notifications: [NotificationInfo]
    let nextCursor: Int
    let hasNext: Bool
    
    init(notifications: [NotificationInfo], nextCursor: Int, hasNext: Bool) {
        self.notifications = notifications
        self.nextCursor = nextCursor
        self.hasNext = hasNext
    }
}

struct NotificationInfo: Decodable {
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
