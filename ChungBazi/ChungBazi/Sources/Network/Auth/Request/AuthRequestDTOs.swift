//
//  AuthRequestDTOs.swift
//  ChungBazi
//
//  Created by 이현주 on 1/27/25.
//

struct KakaoLoginRequestDto : Codable {
    let name: String
    let email: String
    let fcmToken: String
    
    init(name: String, email: String, fcmToken: String) {
        self.name = name
        self.email = email
        self.fcmToken = fcmToken
    }
}

struct ReIssueRequestDto: Codable {
    let refreshToken: String
    
    init(refreshToken: String) {
        self.refreshToken = refreshToken
    }
}
