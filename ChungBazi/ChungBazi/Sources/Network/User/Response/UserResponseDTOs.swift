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
    
    init(userId: Int, name: String, email: String) {
        self.userId = userId
        self.name = name
        self.email = email
    }
}
