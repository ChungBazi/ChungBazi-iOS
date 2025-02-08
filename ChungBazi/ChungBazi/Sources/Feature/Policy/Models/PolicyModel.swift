//
//  PolicyModel.swift
//  ChungBazi
//
//  Created by 엄민서 on 2/2/25.
//

import Foundation

struct PolicyModel {
    let policyId: Int
    let policyName: String
    let category: String
    let startDate: String
    let endDate: String
    let intro: String
    let content: String
    let target: PolicyTarget
    let document: String
    let applyProcedure: String
    let result: String
    let referenceUrls: [String?]
    let registerUrl: String
}

struct PolicyTarget {
    let age: String
    let major: String?
    let employment: String?
    let residenceIncome: String
    let education: String
}
