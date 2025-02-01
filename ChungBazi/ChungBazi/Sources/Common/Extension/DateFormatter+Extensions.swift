//
//  DateFormatter+Extensions.swift
//  ChungBazi
//
//  Created by 신호연 on 1/23/25.
//

import Foundation
import Then

extension DateFormatter {
    static let shared = DateFormatter().then {
        $0.locale = Locale(identifier: "ko_KR")
    }

    static let yearMonthDay = DateFormatter().then {
        $0.locale = Locale(identifier: "ko_KR")
        $0.timeZone = TimeZone(identifier: "Asia/Seoul")
        $0.dateFormat = "yyyy-MM-dd"
    }

    static let yearMonthDayDot = DateFormatter().then {
        $0.locale = Locale(identifier: "ko_KR")
        $0.timeZone = TimeZone(identifier: "Asia/Seoul")
        $0.dateFormat = "yyyy.MM.dd"
    }

    static let monthDay = DateFormatter().then {
        $0.locale = Locale(identifier: "ko_KR")
        $0.timeZone = TimeZone(identifier: "Asia/Seoul")
        $0.dateFormat = "M월 d일"
    }

    static func convertToDate(_ dateString: String) -> Date? {
        return DateFormatter().then {
            $0.locale = Locale(identifier: "ko_KR")
            $0.timeZone = TimeZone(identifier: "Asia/Seoul")
            $0.dateFormat = "yyyy-MM-dd"
        }.date(from: dateString)
    }
}
