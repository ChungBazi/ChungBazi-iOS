//
//  AuthResponseDTOs.swift
//  ChungBazi
//
//  Created by 이현주 on 1/27/25.
//

struct ReIssueResponseDto: Decodable {
    let userId: Int
    let hashedUserId: String
    let userName: String
    let accessToken: String
    let refreshToken: String
    let accessExp: Int
}

struct LoginResponseDto: Decodable {
    let userId: Int
    let hashedUserId: String
    let userName: String?
    let isFirst: Bool
    let accessToken: String
    let refreshToken: String
    let accessExp: Int
    let loginType: String
}
