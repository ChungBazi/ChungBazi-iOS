//
//  ChatbotResponseDTOs.swift
//  ChungBazi
//
//  Created by 신호연 on 12/11/25.
//

import Foundation

struct ChatbotPolicyDetail: Decodable {
    let policyId: Int
    let title: String
    let category: String
    let intro: String
    let bizId: String
    let status: String
}

struct ChatbotPolicySummary: Decodable {
    let policyId: Int
    let title: String
    let status: String
}

struct ChatbotAskResult: Decodable {
    let answer: String
}
