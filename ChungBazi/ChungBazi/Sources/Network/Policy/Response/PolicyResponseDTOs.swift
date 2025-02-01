//
//  PolicyResponseDTOs.swift
//  ChungBazi
//
//  Created by 이현주 on 1/27/25.
//

struct PolicySearchResponseDto: Decodable {
    let policies: [PolicyInfo]
    let nextCursor: String
    let hasNext: Bool
    
    init(policies: [PolicyInfo], nextCursor: String, hasNext: Bool) {
        self.policies = policies
        self.nextCursor = nextCursor
        self.hasNext = hasNext
    }
}

struct PolicyInfo: Decodable {
    let policyId: Int
    let policyName: String
    let startDate: String
    let endDate: String
    let dday: Int
    
    init(policyId: Int, policyName: String, startDate: String, endDate: String, dday: Int) {
        self.policyId = policyId
        self.policyName = policyName
        self.startDate = startDate
        self.endDate = endDate
        self.dday = dday
    }
}

struct PopularSearchTextDto: Decodable {
    let keywords: [String]
    
    init(keywords: [String]) {
        self.keywords = keywords
    }
}
