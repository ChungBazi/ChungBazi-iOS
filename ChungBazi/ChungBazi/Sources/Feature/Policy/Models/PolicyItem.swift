//
//  PolicyItem.swift
//  ChungBazi
//
//  Created by 엄민서 on 1/24/25.
//

import Foundation

struct PolicyItem {
    let policyId: Int
    let policyName: String
    let startDate: String
    let endDate: String
    let dday: Int?
    
    init(policyId: Int, policyName: String, startDate: String, endDate: String, dday: Int?) {
        self.policyId = policyId
        self.policyName = policyName
        self.startDate = startDate
        self.endDate = endDate
        self.dday = dday
    }
}
