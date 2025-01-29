//
//  DDayHelper.swift
//  ChungBazi
//
//  Created by 신호연 on 1/29/25.
//

import UIKit

enum DDayStyle {
    case moreThanTen
    case twoToTen
    case oneDay
    case deadline
    case today
    
    var assetName: String {
        switch self {
        case .moreThanTen: return "d_day_blue200"
        case .twoToTen: return "d_day_blue700"
        case .oneDay: return "d_day_blue900"
        case .deadline: return "d_day_grayscale200"
        case .today: return "d_day_red"
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .moreThanTen: return .gray800
        case .twoToTen, .oneDay, .today: return .white
        case .deadline: return .gray500
        }
    }
    
    var displayText: String {
        switch self {
        case .deadline:
            return "마감"
        case .today:
            return "D-0"
        default:
            return ""
        }
    }
    
    static func determineStyle(from daysLeft: Int) -> DDayStyle {
        switch daysLeft {
        case let x where x > 10: return .moreThanTen
        case 2...10: return .twoToTen
        case 1: return .oneDay
        case 0: return .today
        default: return .deadline
        }
    }
}
