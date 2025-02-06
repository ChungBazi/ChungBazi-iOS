//
//  NotificationSettingModel.swift
//  ChungBazi
//
//  Created by 이현주 on 2/6/25.
//

struct NotificationSettingModel {
    var push: Bool
    var policy: Bool
    var community: Bool
    var reward: Bool
}

struct NotificationItem {
    let title: String
    var isOn: Bool
}
