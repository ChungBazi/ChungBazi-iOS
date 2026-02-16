//
//  DateFormatter+Extensions.swift
//  ChungBazi
//
//  Created by 신호연 on 1/23/25.
//

import Foundation
import Then

extension DateFormatter {
    static let yearMonthDay: DateFormatter = {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter
        }()
        
        /// yyyy.MM.dd 형식 파싱용
        static let yearMonthDayDot: DateFormatter = {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
            formatter.dateFormat = "yyyy.MM.dd"
            return formatter
        }()
        
        /// yyyy-MM 형식 파싱용
        static let yearMonth: DateFormatter = {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
            formatter.dateFormat = "yyyy-MM"
            return formatter
        }()
        
        // MARK: - Display (화면 표시용 - ko_KR)
        
        /// M월 d일 형식 표시용
        static let monthDay: DateFormatter = {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
            formatter.dateFormat = "M월 d일"
            return formatter
        }()
        
        /// yyyy년 MM월 dd일 형식 표시용
        static let yearMonthDayKorean: DateFormatter = {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
            formatter.dateFormat = "yyyy년 MM월 dd일"
            return formatter
        }()
    
        /// MMMM 형식 (1월, 2월 등)
        static let monthFullName: DateFormatter = {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")  // 또는 en_US
            formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
            formatter.dateFormat = "MMMM"
            return formatter
        }()
        
        /// yyyy 형식
        static let year: DateFormatter = {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
            formatter.dateFormat = "yyyy"
            return formatter
        }()
        
        // MARK: - Helper Methods
        /// yyyy-MM-dd 문자열을 Date로 변환
        static func convertToDate(_ dateString: String) -> Date? {
            return yearMonthDay.date(from: dateString)
        }
}
