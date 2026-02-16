//
//  ChatbotButton.swift
//  ChungBazi
//
//  Created by 신호연 on 6/8/25.
//

import Foundation

enum ChatbotButtonStyle {
    case blue
    case normal
}

enum ChatbotActionType {
    case sendMessage(text: String)
    case openPolicyDetail(policyNumber: String)
}

struct ChatbotButton {
    let title: String
    let actionType: ChatbotActionType
    let style: ChatbotButtonStyle
}
