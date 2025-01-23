//
//  DateFormatter+Extensions.swift
//  ChungBazi
//
//  Created by 신호연 on 1/23/25.
//

import Foundation

extension DateFormatter {
    static let shared: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()
    
    static let yearMonthDay: DateFormatter = {
        let formatter = DateFormatter.shared
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}