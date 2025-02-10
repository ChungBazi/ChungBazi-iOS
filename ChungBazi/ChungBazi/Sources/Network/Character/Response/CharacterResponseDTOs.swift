//  CharacterResponseDTOs.swift
//  ChungBazi
//
//  Created by 이현주 on 2/10/25.
//

struct MainCharacterResponseDto: Decodable {
    let rewardLevel: String
    let name: String
    let nextRewardLevel: String
    let posts: Int
    let comments: Int
}

struct CharacterListResponseDto: Decodable {
    let rewardLevel: String
    let open: Bool
}
