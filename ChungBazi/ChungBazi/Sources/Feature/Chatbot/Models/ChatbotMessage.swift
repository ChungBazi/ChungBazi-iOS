//
//  ChatbotMessage.swift
//  ChungBazi
//
//  Created by 신호연 on 6/8/25.
//

import Foundation

enum ChatbotMessageType {
    case text(String)
    case buttons([ChatbotButton])
    case policyCards([ChatbotPolicy])
    case textWithButtons(String, [ChatbotButton])
}

struct ChatbotMessage {
    let id: UUID = UUID()
    let type: ChatbotMessageType
    let isUser: Bool
    let timestamp: Date
}
