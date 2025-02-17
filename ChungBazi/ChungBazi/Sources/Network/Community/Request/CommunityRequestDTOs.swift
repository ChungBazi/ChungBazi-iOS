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
    
    init(title: String, content: String, category: String) {
        self.title = title
        self.content = content
        self.category = category
    }
}

struct CommunityCommentRequestDto: Codable {
    let postId: Int
    let content: String
}

struct CommunityRequestDTO: Codable {
    let category: CommunityCategory
    let cursor: Int
    let size: Int
    
    init(category: CommunityCategory, cursor: Int, size: Int = 10) {
        self.category = category
        self.cursor = cursor
        self.size = size
    }
}

struct CommunityCommentRequestDTO: Codable {
    let postId: Int
    let cursor: Int
    let size: Int
}
