//
//  MoreActionHandler.swift
//  ChungBazi
//
//  Created by 신호연 on 9/18/25.
//

import Foundation

final class MoreActionHandler {
    private let service = CommunityService()
    private let reportsService = ReportsService()
    private let block = BlockService()

    func handle(_ action: MoreAction, entity: MoreEntity, completion: @escaping (Result<Void, Error>) -> Void) {
        switch (action, entity) {

        /// 삭제
        case (.delete, .post(let postId, _, _)):
            service.deleteCommunityPost(postId: postId) { result in
                switch result {
                case .success:
                    completion(.success(()))
                case .failure(let err):
                    completion(.failure(err))
                }
            }

        /// 삭제: 댓글
        case (.delete, .comment(let commentId, _, _, _)):
            service.deleteCommunityComment(commentId: commentId) { result in
                switch result {
                case .success:
                    completion(.success(()))
                case .failure(let err):
                    completion(.failure(err))
                }
            }

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
            reportsService.reportPost(postId: postId, reason: .spam, description: nil) { result in
                completion(result.mapError { $0 as Error })
            }

        case (.report, .comment(let commentId, _, _, _)):
            reportsService.reportComment(commentId: commentId, reason: .spam, description: nil) { result in
                completion(result.mapError { $0 as Error })
            }

        // 차단
        case (.block, .post(_, let ownerUserId, _)),
             (.block, .comment(_, _, let ownerUserId, _)):
            block.postBlockUser(blockedUserId: ownerUserId) { result in
                switch result {
                case .success: completion(.success(()))
                case .failure(let e): completion(.failure(e))
                }
            }
        }
    }
}
