//
//  ReportsServices.swift
//  ChungBazi
//
//  Created by 신호연 on 9/22/25.
//

import Foundation
import Moya

final class ReportsService: NetworkManager {

    typealias Endpoint = ReportsEndpoints
    internal let provider: MoyaProvider<ReportsEndpoints>

    init(provider: MoyaProvider<ReportsEndpoints>? = nil) {
        let plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
        ]
        self.provider = provider ?? MoyaProvider<ReportsEndpoints>(plugins: plugins)
    }

    // 게시글 신고
    func reportPost(postId: Int,
                    reason: ReportReason,
                    description: String?,
                    completion: @escaping (Result<Void, NetworkError>) -> Void) {
        let body = ReportRequestDTO(reason: reason, description: description)
        // 서버 공통 래퍼일 경우 EmptyResponse로 무시
        requestOptional(target: .reportPost(postId: postId, body: body),
                        decodingType: EmptyResponse.self) { (result: Result<EmptyResponse?, NetworkError>) in
            completion(result.map { _ in () })
        }
    }

    // 댓글 신고
    func reportComment(commentId: Int,
                       reason: ReportReason,
                       description: String?,
                       completion: @escaping (Result<Void, NetworkError>) -> Void) {
        let body = ReportRequestDTO(reason: reason, description: description)
        requestOptional(target: .reportComment(commentId: commentId, body: body),
                        decodingType: EmptyResponse.self) { (result: Result<EmptyResponse?, NetworkError>) in
            completion(result.map { _ in () })
        }
    }
}
