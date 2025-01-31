//
//  AuthResponseDTOs.swift
//  ChungBazi
//
//  Created by 이현주 on 1/27/25.
//

struct KakaoLoginResponseDto: Decodable {
    let userId: Int
    let userName: String
    let isFirst: Bool
    let accessToken: String
    let refreshToken: String
    let accessExp: Int
    
    init(userId: Int, userName: String, isFirst: Bool, accessToken: String, refreshToken: String, accessExp: Int) {
        self.userId = userId
        self.userName = userName
        self.isFirst = isFirst
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.accessExp = accessExp
    }
}

struct ReIssueResponseDto: Decodable {
    let userId: Int
    let userName: String
    let accessToken: String
    let accessExp: Int
    
    init(userId: Int, userName: String, accessToken: String, accessExp: Int) {
        self.userId = userId
        self.userName = userName
        self.accessToken = accessToken
        self.accessExp = accessExp
    }
}
