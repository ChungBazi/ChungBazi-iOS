//
//  ReportRequestDTO.swift
//  ChungBazi
//
//  Created by 신호연 on 9/22/25.
//

import Foundation

enum ReportReason: String, Codable {
    case spam = "SPAM"
    case abuse = "ABUSE"
    case inappropriate = "INAPPROPRIATE"
    case other = "OTHER"
}

struct ReportRequestDTO: Codable {
    let reason: ReportReason
    let description: String?
}
