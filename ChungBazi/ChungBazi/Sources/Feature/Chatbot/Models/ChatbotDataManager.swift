//
//  ChatbotDataManager.swift
//  ChungBazi
//
//  Created by 신호연 on 6/8/25.
//

import Foundation

class ChatbotDataManager {
    static let shared = ChatbotDataManager()
    
    private init() {}

    func getDummyMessages() -> [ChatbotMessage] {
        return [
            ChatbotMessage(text: "안녕하세요. 청바지 챗봇 ‘바로봇'이에요! 궁금한 내용을 바로 질문하시거나, 아래 버튼을 선택해 주세요.", isUser: false, timestamp: Date()),
            ChatbotMessage(text: "일자리 정책이 궁금해요.", isUser: true, timestamp: Date())
        ]
    }
    
    func getDummyPolicies() -> [ChatbotPolicy] {
        return [
            ChatbotPolicy(title: "취업 특강",
                          description: "고용시장에 대해 이해하고 구직에 필요한 근로기준법, 일자리 정보 수집방법, 이력서/자기소개서 작성방법 및 면접 요령 등을 빠르게 알 수 있도록 지원하는 정책 ",
                          applyPeriod: "상시",
                          policyNumber: "20250212005400110427",
                          category: .jobs),
            ChatbotPolicy(title: "해외 K-Move 센터 운영",
                          description: "해외 취업을 위한 지원 정책입니다.",
                          applyPeriod: "진행중",
                          policyNumber: "20250212005400110428",
                          category: .participationRights)
        ]
    }
}
