//
//  CalendarDetailModel.swift
//  ChungBazi
//
//  Created by 신호연 on 1/20/25.
//

import Foundation

struct Policy: Decodable {
    let policyId: Int
    let policyName: String
    let startDate: String
    let endDate: String
    let documentText: String
    let userDocuments: [Document]?
}

struct Document: Decodable {
    let documentId: Int
    let name: String
    let isChecked: Bool
}
