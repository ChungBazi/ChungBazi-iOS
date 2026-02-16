//
//  PolicyModel.swift
//  ChungBazi
//
//  Created by 엄민서 on 2/2/25.
//

import Foundation

struct PolicyModel {
    let policyId: Int
    let posterUrl: String?
    let categoryName: String
    let name: String
    let intro: String // 정책소개
    let content: String // 지원 내용
    let startDate: String?
    let endDate: String?
    let applyProcedure: String? // 정책 신청 방법 내용
    let document: String? // 제출 서류 내용
    let result: String? // 심사 발표 내용
    let referenceUrl1: String?
    let referenceUrl2: String?
    let registerUrl: String?
}

struct PolicyTarget {
    let minAge: String?
    let maxAge: String?
    let minIncome: String?
    let maxIncome: String?
    let incomeEtc: String?
    let additionCondition: String? // 추가 신청 자격
    let restrictionCondition: String? // 참여 제한 대상
}
