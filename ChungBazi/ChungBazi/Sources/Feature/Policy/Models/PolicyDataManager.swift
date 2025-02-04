//
//  PolicyDataManager.swift
//  ChungBazi
//
//  Created by 엄민서 on 2/3/25.
//

import Foundation

final class PolicyDataManager {
    
    static let shared = PolicyDataManager()
    
    private var policies: [Int: PolicyModel] = [:]
    
    private init() {
        // 예시 데이터
        let samplePolicy = PolicyModel(
            policyId: 1,
            policyName: "노원구 1인가구 안심홈 3종 세트",
            category: "주거",
            startDate: "2024-12-12",
            endDate: "2024-12-23",
            intro: "소득 근로자가 일·생활 균형을 위해...",
            content: "□ 지원내용: ...",
            target: PolicyTarget(
                age: "20세 이상",
                major: nil,
                employment: nil,
                residenceIncome: "소득 조건 있음",
                education: "대학 졸업"
            ),
            document: "공고문 참고",
            applyProcedure: "서울시청 접수",
            result: "결과 통보",
            referenceUrls: ["https://example.com"],
            registerUrl: "https://example.com"
        )
        
        policies[samplePolicy.policyId] = samplePolicy
    }
    
    func getPolicy(by policyId: Int) -> PolicyModel? {
        return policies[policyId]
    }
}
