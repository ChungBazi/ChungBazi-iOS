//
//  CalendarDetailModel.swift
//  ChungBazi
//
//  Created by 신호연 on 1/20/25.
//

import Foundation

struct Policy {
    let cartId: Int
    let policyId: Int
    let policyName: String
    let startDate: String
    let endDate: String
    var documentText: String
    var userDocuments: [Document]?
}

struct Document {
    var documentId: Int
    var name: String
    var isChecked: Bool
}
