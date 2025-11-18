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
    
    
    private let chatbotService = ChatbotService()
    
    func getDummyMessages() -> [ChatbotMessage] {
        return [
            ChatbotMessage(
                type: .textWithButtons(
                    "안녕하세요.\n청바지 챗봇 ‘바로봇'이에요!\n궁금한 내용을 바로 질문하시거나, 아래 버튼을 선택해 주세요.",
                    [
//                        ChatbotButton(title: "정책 찾기", actionType: .sendMessage(text: "정책 찾기"), style: .blue),
//                        ChatbotButton(title: "정책 용어 쉽게 알기", actionType: .sendMessage(text: "정책 용어 쉽게 알기"), style: .blue),
                        ChatbotButton(title: "인기있는 청년 정책은?", actionType: .sendMessage(text: "인기있는 청년 정책은?"), style: .normal),
                        ChatbotButton(title: "월세 지원", actionType: .sendMessage(text: "월세 지원"), style: .normal),
                        ChatbotButton(title: "청년 인턴 지원", actionType: .sendMessage(text: "청년 인턴 지원"), style: .normal),
                        ChatbotButton(title: "청년창업 지원 정책", actionType: .sendMessage(text: "청년창업 지원 정책"), style: .normal)
                    ]
                ),
                isUser: false,
                timestamp: Date()
            )
            //            ,
            //
            //            // 3️⃣ 메시지 + 정책 소개(카드)
            //            ChatbotMessage(
            //                type: .text("청년을 위한 추천 정책이 있어요!"),
            //                isUser: false,
            //                timestamp: Date()
            //            ),
            //            ChatbotMessage(
            //                type: .policyCards([
            //                    ChatbotPolicy(
            //                        title: "취업 특강",
            //                        description: "고용시장에 대해 이해하고 구직에 필요한 근로기준법, 이력서/자기소개서 작성방법, 면접 요령 등을 알려드립니다.",
            //                        applyPeriod: "상시",
            //                        policyNumber: "20250212005400110427",
            //                        category: .jobs
            //                    ),
            //                    ChatbotPolicy(
            //                        title: "해외 K-Move 센터 운영",
            //                        description: "해외취업을 준비하는 청년을 위해 K-Move 센터에서 취업 지원 서비스를 제공합니다.",
            //                        applyPeriod: "진행중",
            //                        policyNumber: "20250212005400110428",
            //                        category: .participationRights
            //                    )
            //                ]),
            //                isUser: false,
            //                timestamp: Date()
            //            ),
            //            ChatbotMessage(
            //                type: .text("다른 궁금한 점이 있으시면 말씀해 주세요!"),
            //                isUser: false,
            //                timestamp: Date()
            //            ),
            //
            //            // 4️⃣ 사용자 메시지 예시
            //            ChatbotMessage(
            //                type: .text("청년 지원금 정책 알려줘!"),
            //                isUser: true,
            //                timestamp: Date()
            //            )
        ]
    }
    
    func sendMessage(_ text: String, completion: @escaping (Result<ChatbotMessage, Error>) -> Void) {
        chatbotService.ask(message: text) { result in
            switch result {
            case .success(let askResult):
                let replyText = askResult.answer

                let botMessage = ChatbotMessage(
                    type: .text(replyText),
                    isUser: false,
                    timestamp: Date()
                )
                completion(.success(botMessage))
                
            case .failure(let error):
                print("❌ [ChatbotDataManager] 서버 요청 실패: \(error)")
                completion(.failure(error))
            }
        }
    }
}
