//
//  CommunityDetailModel.swift
//  ChungBazi
//
//  Created by 신호연 on 2/8/25.
//

struct CommunityDetailCommentModel {
    let postId: Int
    let content: String
    let formattedCreatedAt: String
    let commentId: Int
    let userId: Int
    let userName: String
    let reward: String
    let characterImg: String
    let likesCount: Int
    let parentCommentId: Int?
    let deleted: Bool
    let mine: Bool
    let likedByUser: Bool
    let replyCount: Int
}

struct CommunityDetailPostModel {
    let postId: Int
    let title: String
    let content: String
    let category: CommunityCategory
    let formattedCreatedAt: String
    let status: String
    let views: Int
    let commentCount: Int
    let postLikes: Int
    let userId: Int
    let userName: String
    let reward: String
    let characterImg: String
    let thumbnailUrl: String?
    let imageUrls: [String]?
    let anonymous: Bool
    let mine: Bool
    let likedByUser: Bool

    var categoryDisplayName: String { category.displayName }
}
