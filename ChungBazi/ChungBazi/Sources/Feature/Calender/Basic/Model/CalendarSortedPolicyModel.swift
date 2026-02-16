//
//  CalendarMarkerModel.swift
//  ChungBazi
//
//  Created by 신호연 on 1/23/25.
//

import Foundation

struct SortedPolicy {
    let cartId: Int
    let policyId: Int
    let startDate: Date
    let endDate: Date
    let policyName: String
}

func sortMarkers(policies: [SortedPolicy]) -> [SortedPolicy] {
    return policies.sorted { policy1, policy2 in
        
        /// 종료일에 따른 정렬
        /// 종료일 빠를 수록 앞으로
        if policy1.endDate != policy2.endDate {
            return policy1.endDate < policy2.endDate
        }
        
        /// 시작일에 따른 정렬
        /// 시작일 빠를 수록 앞으로
        if policy1.startDate != policy2.startDate {
            return policy1.startDate < policy2.startDate
        }
        
        /// 정책명에 따른 정렬
        /// 철자 순으로 정렬
        return policy1.policyName < policy2.policyName
    }
}
