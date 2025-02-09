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

struct CommunityRequestDTO: Codable {
    let category: CommunityCategory
    let lastPostId: Int?
    let size: Int
    
    init(category: CommunityCategory, lastPostId: Int? = nil, size: Int = 10) {
        self.category = category
        self.lastPostId = lastPostId
        self.size = size
    }
}

struct CommunityCommentRequestDTO: Codable {
    let postId: Int
    let lastCommentId: Int?
    let size: Int
}
