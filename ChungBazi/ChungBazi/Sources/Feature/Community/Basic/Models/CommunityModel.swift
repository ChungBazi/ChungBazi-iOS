//
//  CommunityModel.swift
//  ChungBazi
//
//  Created by 신호연 on 2/3/25.
//

import Foundation

struct CommunityResult: Decodable {
    let totalPostCount: Int
    let postList: [CommunityPost]
}

struct CommunityPost: Codable {
    let postId: Int
    let title: String
    let content: String
    let category: CommunityCategory
    let formattedCreatedAt: String
    let views: Int
    let commentCount: Int
    let postLikes: Int
    let userId: Int
    let userName: String
    let reward: String
    let characterImg: String?
    let thumbnailUrl: String?
}

enum CommunityCategory: String, CaseIterable, Codable {
    case all = ""
    case jobs = "JOBS"
    case housing = "HOUSING"
    case education = "EDUCATION"
    case welfareCulture = "WELFARE_CULTURE"
    case participationRights = "PARTICIPATION_RIGHTS"
    
    var displayName: String {
        switch self {
        case .all: return "전체"
        case .jobs: return "일자리"
        case .housing: return "주거"
        case .education: return "교육"
        case .welfareCulture: return "복지,문화"
        case .participationRights: return "참여,권리"
        }
    }
    
    /// `UISegmentedControl`의 인덱스와 매핑
    static func category(from index: Int) -> CommunityCategory {
        return CommunityCategory.allCases[safe: index] ?? .all
    }
    
    static func index(of category: CommunityCategory) -> Int? {
        return CommunityCategory.allCases.firstIndex(of: category)
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
