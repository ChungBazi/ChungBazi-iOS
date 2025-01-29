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
    
    static let monthDay: DateFormatter = {
        let formatter = DateFormatter.shared
        formatter.dateFormat = "M월 d일"
        return formatter
    }()
    
    static func convertToDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString)
    }
}
