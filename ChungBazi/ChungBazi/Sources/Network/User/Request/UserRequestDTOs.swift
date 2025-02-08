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
    
    init(region: String, employment: String, income: String, education: String, interests: [String], additionInfo: [String]) {
        self.region = region
        self.employment = employment
        self.income = income
        self.education = education
        self.interests = interests
        self.additionInfo = additionInfo
    }
}

struct ProfileUpdateRequestDto: Codable {
    let name: String
}
