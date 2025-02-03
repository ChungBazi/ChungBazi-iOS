//
//  CommunityRequestDTOs.swift
//  ChungBazi
//
//  Created by 이현주 on 1/27/25.
//

struct CommunityRequestDTO: Codable {
    let category: CommunityCategory
    let lastPostId: Int
    let size: Int
}
