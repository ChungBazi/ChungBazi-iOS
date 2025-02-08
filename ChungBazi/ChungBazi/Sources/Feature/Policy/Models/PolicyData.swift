//
//  PolicyData.swift
//  ChungBazi
//
//  Created by 엄민서 on 1/29/25.
//

class PolicyData {
    static func getPolicies(for category: String) -> CategoryItem? {
        switch category {
        case "일자리":
            let jobPolicies = [
                PolicyItem(title: "<청년 맞춤형 일자리 매칭 지원 프로그램>", region: "강남구", period: "2024.12.11 - 2025.01.31", badge: "D-0", policyId: 2),
                PolicyItem(title: "<청년 일자리 디딤돌: 취업 준비 지원 패키지>", region: "서대문구", period: "2024.12.11 - 2025.01.31", badge: "D-1", policyId: 3),
                PolicyItem(title: "<청년 IT 직무 역량 강화와 일자리 연결 프로젝트>", region: "구로구", period: "2024.12.11 - 2025.01.31", badge: "D-2", policyId: 4),
                PolicyItem(title: "<문화·예술 분야 청년 일자리 창출 지원 사업>", region: "마포구", period: "2024.12.11 - 2025.01.31", badge: "D-5", policyId: 5),
                PolicyItem(title: "<청년 스타트업 창업 지원 및 일자리 창출 프로젝트>", region: "금천구", period: "2024.12.11 - 2025.01.31", badge: "마감", policyId: 6)
            ]
            return CategoryItem(title: "일자리", iconName: "", policies: jobPolicies)
            
        case "주거":
            let housingPolicies = [
                PolicyItem(title: "<노원구 1인가구 안심홈 3종 세트>", region: "노원구", period: "2024.12.11 - 2025.01.31", badge: "D-0", policyId: 1)
            ]
            return CategoryItem(title: "주거", iconName: "", policies: housingPolicies)
            
        case "교육":
            return CategoryItem(title: "교육", iconName: "", policies: [])
            
        case "복지,문화":
            return CategoryItem(title: "복지,문화", iconName: "", policies: [])
            
        case "참여,권리":
            return CategoryItem(title: "참여,권리", iconName: "", policies: [])
            
        default:
            return nil
        }
    }
}
