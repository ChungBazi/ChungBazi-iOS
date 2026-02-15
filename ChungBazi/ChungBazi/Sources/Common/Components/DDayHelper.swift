//
//  DDayHelper.swift
//  ChungBazi
//
//  Created by 신호연 on 1/29/25.
//

import UIKit

enum DDayStyle {
    case scheduled      // 예정 (dday < 0)
    case permanent      // 상시 (dday > 999 또는 nil)
    case moreThanTen    // D-10 이상
    case twoToNine      // D-2 ~ D-9
    case today          // D-0 ~ D-1
    case closed         // 마감
    
    var assetName: ImageResource {
        switch self {
        case .scheduled:
            return .blue50Pocket
        case .permanent:
            return .green300Pocket
        case .moreThanTen:
            return .blue200Pocket
        case .twoToNine:
            return .blue700Pocket
        case .today:
            return .redPocket
        case .closed:
            return .gray500Pocket
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .scheduled, .permanent, .moreThanTen:
            return AppColor.gray800!
        case .twoToNine, .today:
            return .white
        case .closed:
            return AppColor.gray500!
        }
    }
    
    var displayText: String {
        switch self {
        case .scheduled:
            return "예정"
        case .permanent:
            return "상시"
        case .closed:
            return "마감"
        case .today:
            return ""
        case .moreThanTen, .twoToNine:
            return "" // D-day 숫자는 별도로 설정
        }
    }
    
    /// dday 값으로 스타일 결정
    static func determineStyle(from dday: Int?) -> (style: DDayStyle, text: String) {
        guard let dday = dday else {
            return (.permanent, "상시")
        }
        
        if dday > 999 {
            return (.permanent, "상시")
        } else if dday < 0 {
            return (.scheduled, "예정")
        } else if dday >= 10 {
            return (.moreThanTen, "D-\(dday)")
        } else if dday >= 2 {
            return (.twoToNine, "D-\(dday)")
        } else if dday >= 0 {
            return (.today, "D-\(dday)")
        }
        
        return (.moreThanTen, "D-\(dday)")
    }
    
    /// 배지 텍스트로 스타일 결정 (역방향 호환)
    static func determineStyle(from badge: String) -> DDayStyle {
        switch badge {
        case "예정":
            return .scheduled
        case "마감":
            return .closed
        case "상시":
            return .permanent
        case let value where value.starts(with: "D-"):
            if let day = Int(value.dropFirst(2)) {
                if day >= 10 {
                    return .moreThanTen
                } else if day >= 2 {
                    return .twoToNine
                } else if day >= 0 {
                    return .today
                }
            }
            return .moreThanTen
        default:
            return .moreThanTen
        }
    }
}
