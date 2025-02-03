//
//  CommunityResponseDTOs.swift
//  ChungBazi
//
//  Created by 이현주 on 1/27/25.
//

struct CommunityResponseDTO: Decodable {
    struct Post: Decodable {
        let postId: Int
        let title: String
        let content: String
        let category: String
        let formattedCreatedAt: String
        let views: Int
        let commentCount: Int
        let userId: Int
        let userName: String
        let reward: Int
        let characterImg: String
        let thumbnailUrl: String?
    }

    let totalPostCount: Int
    let postList: [Post]
}
