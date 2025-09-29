//
//  CommunityResponseDTOs.swift
//  ChungBazi
//
//  Created by 이현주 on 1/27/25.
//

import Foundation

struct CommunityResponseDTO: Decodable {
    let totalPostCount: Int
    let postList: [Post]?
    let nextCursor: Int
    let hasNext: Bool?
}

struct Post: Decodable {
    let postId: Int
    let title: String
    let content: String
    let category: String
    let formattedCreatedAt: String
    let anonymous: Bool
    let views: Int
    let commentCount: Int
    let postLikes: Int
    let userId: Int
    let userName: String
    let reward: String
    let characterImg: String
    let thumbnailUrl: String?
    let imageUrls: [String]?
    let mine: Bool
}

struct SearchCommunityPopularWordsResponseDTO: Decodable {
    let keywords: [String]?
}

struct CommunityDetailResponseDTO: Decodable {
    let postId: Int
    let title: String
    let content: String
    let category: String
    let formattedCreatedAt: String
    let status: String
    let anonymous: Bool
    let views: Int
    let commentCount: Int
    let postLikes: Int
    let userId: Int
    let userName: String
    let reward: String
    let characterImg: String
    let thumbnailUrl: String?
    let imageUrls: [String]?
    let mine: Bool
    let likedByUser: Bool
}

struct CommunityCommentResponseDTO: Decodable {
    let commentsList: [Comment]
    let nextCursor: Int
    let hasNext: Bool
}

struct Comment: Decodable {
    let postId: Int?
    let content: String?
    let formattedCreatedAt: String?
    let commentId: Int?
    let userId: Int?
    let userName: String?
    let reward: String?
    let characterImg: String?
    let likesCount: Int?
    let parentCommentId: Int?
    let deleted: Bool?
    let mine: Bool
    let likedByUser: Bool?
}

struct PostPostResponse: Decodable {
    let postId: Int
    let title: String
    let content: String
    let category: String
    let formattedCreatedAt: String
    let views: Int
    let commentCount: Int
    let postLikes: Int
    let userId: Int
    let userName: String
    let reward: String
    let characterImg: String
    let thumbnailUrl: String?
    let imageUrls: [String]?
}

struct PostCommentResponse: Decodable {
    let postId: Int
    let content: String
    let formattedCreatedAt: String
    let commentId: Int
    let userId: Int
    let userName: String
    let reward: String
    let characterImg: String
}
