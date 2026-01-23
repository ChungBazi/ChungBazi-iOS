//
//  UserResponseDTOs.swift
//  ChungBazi
//
//  Created by 이현주 on 1/27/25.
//

struct ProfileResponseDto: Decodable {
    let userId: Int
    let name: String
    let email: String
    let characterImg: String
}

struct RewardResponseDto: Decodable {
    let rewardLevel: Int
    let postCount: Int
    let commentCount: Int
}

struct ProfileImgResponseDto: Decodable {
    let characterImg: String
}

struct UserInfoResponseDto: Decodable {
    let employment: String
    let education: String
    let income: String
    let interests: [String]
    let additions: [String]
}
