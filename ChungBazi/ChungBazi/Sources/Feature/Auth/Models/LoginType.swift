//
//  LoginType.swift
//  ChungBazi
//
//  Created by 이현주 on 2/12/26.
//

import Foundation

enum LoginType: String {
    case kakao = "KAKAO"
    case apple = "APPLE"
    case normal = "LOCAL"
    
    static func from(serverType: String) -> LoginType {
        switch serverType.uppercased() {
        case "KAKAO":
            return .kakao
        case "APPLE":
            return .apple
        default:
            return .normal
        }
    }
}
