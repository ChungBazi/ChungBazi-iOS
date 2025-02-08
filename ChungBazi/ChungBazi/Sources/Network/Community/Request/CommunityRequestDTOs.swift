//
//  CommunityRequestDTOs.swift
//  ChungBazi
//
//  Created by 이현주 on 1/27/25.
//

struct CommunityPostRequestDto: Codable {
    let title: String
    let content: String
    let category: String
}

struct CommunityCommentRequestDto: Codable {
    let postId: Int
    let content: String
}
