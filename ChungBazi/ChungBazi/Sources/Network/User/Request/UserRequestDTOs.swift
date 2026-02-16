//
//  UserRequestDTOs.swift
//  ChungBazi
//
//  Created by 이현주 on 1/27/25.
//

struct UserInfoRequestDto: Codable {
    let region: String
    let employment: String
    let income: String
    let education: String
    let interests: [String]
    let additionInfo: [String]
}

struct ProfileUpdateRequestDto: Codable {
    let name: String
    let characterImg: String
}
