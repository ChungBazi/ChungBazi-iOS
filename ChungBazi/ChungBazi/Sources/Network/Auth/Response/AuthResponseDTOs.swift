//
//  AuthResponseDTOs.swift
//  ChungBazi
//
//  Created by 이현주 on 1/27/25.
//

struct KakaoResponseDto: Decodable {
    let userId: Int
    let userName: String
    let isFirst: Bool
    
    init(userId: Int, userName: String, isFirst: Bool) {
        self.userId = userId
        self.userName = userName
        self.isFirst = isFirst
    }
}
