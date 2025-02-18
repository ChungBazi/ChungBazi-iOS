//
//  PolicyResponseDTOs.swift
//  ChungBazi
//
//  Created by 이현주 on 1/27/25.
//

struct PolicyListResponseDto: Decodable {
    let policies: [PolicyInfo]?
    let nextCursor: String?
    let hasNext: Bool
}

struct RecommendPolicyListResponseDto: Decodable {
    let policies: [PolicyInfo]?
    let interests: [String]?
    let hasNext: Bool
    let nextCursor: Int
    let readAllNotifications: Bool
}

struct PolicyInfo: Decodable {
    let policyId: Int?
    let policyName: String?
    let startDate: String?
    let endDate: String?
    let dday: Int?
}

struct PopularSearchTextDto: Decodable {
    let keywords: [String]?
}

struct PolicyDetailResponseDto: Decodable {
    let posterUrl: String?
    let categoryName: String
    let name: String
    let intro: String // 정책소개
    let content: String // 지원 내용
    let startDate: String?
    let endDate: String?
    let minAge: String?
    let maxAge: String?
    let minIncome: String?
    let maxIncome: String?
    let incomeEtc: String?
    let additionCondition: String? // 추가 신청 자격
    let restrictionCondition: String? // 참여 제한 대상
    let applyProcedure: String? // 정책 신청 방법 내용
    let document: String? // 제출 서류 내용
    let result: String? // 심사 발표 내용
    let referenceUrl1: String?
    let referenceUrl2: String?
    let registerUrl: String?
}

struct CalendarPolicyListResponseDto: Decodable {
    let calendarPolicy: [CalendarPolicy]?
}

struct CalendarPolicy: Decodable {
    let name: String?
    let startDate: String?
    let endDate: String?
}

struct CalendarPolicyDetailResponseDto: Decodable {
    let name: String
    let startDate: String
    let endDate: String
    let cartId: Int
    let policyId: Int
    let documents: [CalendarPolicyDetailDocument]?
    let referenceDocuments: String?
    let dday: Int
}

struct CalendarPolicyDetailDocument: Decodable {
    let documentId: Int?
    let content: String?
    let checked: Bool?
}
