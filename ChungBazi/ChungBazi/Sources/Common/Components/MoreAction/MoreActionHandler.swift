//
//  MoreActionHandler.swift
//  ChungBazi
//
//  Created by 신호연 on 9/18/25.
//

import Foundation

final class MoreActionHandler {
    private let service = CommunityService()

    func handle(_ action: MoreAction, entity: MoreEntity, completion: @escaping (Result<Void, Error>) -> Void) {
        switch (action, entity) {

        // 삭제
        case (.delete, .post(let postId, _, _)):
            // TODO: 게시글 삭제 API 연결
            // service.deletePost(postId: postId) { completion($0.map { _ in () }) }
            completion(.success(()))

        case (.delete, .comment(let commentId, _, _, _)):
            // TODO: 댓글 삭제 API 연결
            // service.deleteComment(commentId: commentId) { completion($0.map { _ in () }) }
            completion(.success(()))

        // 대댓글 알림
        case (.toggleReplyAlarm, .post(let postId, _, _)):
            // TODO: 글 스레드 알림 토글 API
            completion(.success(()))
        case (.toggleReplyAlarm, .comment(_, let postId, _, _)):
            // TODO: 댓글 스레드 알림 토글 API
            completion(.success(()))

        // 쪽지
        case (.sendMessage, .post(_, let ownerUserId, _)):
            // TODO: DM 화면 이동 or DM API
            completion(.success(()))

        case (.sendMessage, .comment(_, _, let ownerUserId, _)):
            // TODO: DM 화면 이동 or DM API
            completion(.success(()))

        // 신고
        case (.report, .post(let postId, _, _)):
            // TODO: 게시글 신고 API
            completion(.success(()))

        case (.report, .comment(let commentId, _, _, _)):
            // TODO: 댓글 신고 API
            completion(.success(()))

        // 차단
        case (.block, .post(_, let ownerUserId, _)):
            // TODO: 유저 차단 API
            completion(.success(()))

        case (.block, .comment(_, _, let ownerUserId, _)):
            // TODO: 유저 차단 API
            completion(.success(()))
        }
    }
}
