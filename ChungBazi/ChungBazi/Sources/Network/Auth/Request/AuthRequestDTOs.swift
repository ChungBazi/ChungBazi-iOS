//
//  AuthRequestDTOs.swift
//  ChungBazi
//
//  Created by 이현주 on 1/27/25.
//

struct KakaoLoginRequestDto : Codable {
    let name: String
    let email: String
    let imageUrl: String
    
    init(name: String, email: String, imageUrl: String) {
        self.name = name
        self.email = email
        self.imageUrl = imageUrl
    }
}
