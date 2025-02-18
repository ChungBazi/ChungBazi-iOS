//
//  CartResponseDTOs.swift
//  ChungBazi
//
//  Created by 이현주 on 1/27/25.
//

struct CartListResponseDto: Decodable {
    let categoryPolicyList: [CategoryPolicyList]?
}

struct CategoryPolicyList: Decodable {
    let categoryName: String?
    let cartPolicies: [CartPolicyList]?
}

struct CartPolicyList: Decodable {
    let name: String?
    let startDate: String?
    let endDate: String?
    let policyId: Int?
    let dday: Int?
}
