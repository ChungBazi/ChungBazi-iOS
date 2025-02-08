//
//  CommunityService.swift
//  ChungBazi
//
//  Created by 이현주 on 1/27/25.
//

import Foundation
import Moya

final class CommunityService: NetworkManager {
    
    typealias Endpoint = CommunityEndpoints
    
    let provider: MoyaProvider<CommunityEndpoints>
    
    public init(provider: MoyaProvider<CommunityEndpoints>? = nil) {
        let plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
        ]
        
        self.provider = provider ?? MoyaProvider<CommunityEndpoints>(plugins: plugins)
    }
    
    public func getCommunityPosts(data: CommunityRequestDTO, completion: @escaping (Result<CommunityResponseDTO, NetworkError>) -> Void) {
        request(target: .getCommunityPosts(data: data), decodingType: CommunityResponseDTO.self, completion: completion)
    }
    
    public func getCommunityPost(postId: Int, completion: @escaping (Result<CommunityDetailResponseDTO, NetworkError>) -> Void) {
        request(target: .getCommunityPost(postId: postId), decodingType: CommunityDetailResponseDTO.self, completion: completion)
    }
    
    public func getCommunityComments(postId: Int, lastCommentId: Int?, size: Int, completion: @escaping (Result<[CommunityCommentResponseDTO.Comment], NetworkError>) -> Void) {
        request(target: .getCommunityComments(postId: postId, lastCommentId: lastCommentId, size: size), decodingType: CommunityCommentResponseDTO.self) { result in
            switch result {
            case .success(let response):
                completion(.success(response.result))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
