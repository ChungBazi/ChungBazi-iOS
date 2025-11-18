//
//  ChatbotRequestDTOs.swift
//  ChungBazi
//
//  Created by 신호연 on 12/11/25.
//

import Foundation

struct ChatbotAskRequestDto: Codable {
    let message: String
}

enum ChatbotCategory: String, Codable, CaseIterable {
    case JOBS
    case HOUSING
    case EDUCATION
    case WELFARE_CULTURE
    case PARTICIPATION_RIGHTS
}
