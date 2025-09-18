//
//  MoreActions.swift
//  ChungBazi
//
//  Created by 신호연 on 9/18/25.
//

import UIKit

enum MoreEntity {
    case post(postId: Int, ownerUserId: Int, mine: Bool)
    case comment(commentId: Int, postId: Int, ownerUserId: Int, mine: Bool)

    var mine: Bool {
        switch self {
        case .post(_, _, let m): return m
        case .comment(_, _, _, let m): return m
        }
    }
}

enum MoreAction: Equatable {
    // 내 컨텐츠
    case delete
    // 타인 컨텐츠
    case toggleReplyAlarm
    case sendMessage
    case report
    case block
}

struct MoreActionItem {
    let title: String
    let color: UIColor?
    let action: MoreAction
}
