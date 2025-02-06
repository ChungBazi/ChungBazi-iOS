//
//  NotificationRequestDTOs.swift
//  ChungBazi
//
//  Created by 이현주 on 1/27/25.
//

struct NoticeSettingRequestDto: Codable {
    let policyAlarm: Bool
    let communityAlarm: Bool
    let rewardAlarm: Bool
    let noticeAlarm: Bool
    
    init(policyAlarm: Bool, communityAlarm: Bool, rewardAlarm: Bool, noticeAlarm: Bool) {
        self.policyAlarm = policyAlarm
        self.communityAlarm = communityAlarm
        self.rewardAlarm = rewardAlarm
        self.noticeAlarm = noticeAlarm
    }
}
