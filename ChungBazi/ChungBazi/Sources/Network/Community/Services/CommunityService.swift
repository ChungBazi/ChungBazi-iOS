//
//  CommunityService.swift
//  ChungBazi
//
//  Created by 이현주 on 1/27/25.
//

import Foundation
import UIKit
import Moya

final class CommunityService: NetworkManager {
    
    typealias Endpoint = CommunityEndpoints
    
    // MARK: - Provider 설정
    let provider: MoyaProvider<CommunityEndpoints>
    
    public init(provider: MoyaProvider<CommunityEndpoints>? = nil) {
        //플러그인 추가
        let plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
        ]
        
        self.provider = provider ?? MoyaProvider<CommunityEndpoints>(plugins: plugins)
    }
    
    // MARK: - DTO funcs
    
    /// CommunityPostRequestDto 데이터 구조 생성
    public func makeCommunityPostRequestDto(title: String, content: String, category: String) -> CommunityPostRequestDto {
        return CommunityPostRequestDto(title: title, content: content, category: category)
    }
    
    /// CommunityCommentRequestDto 데이터 구조 생성
    public func makeCommunityCommentRequestDto(postId: Int, content: String) -> CommunityCommentRequestDto {
        return CommunityCommentRequestDto(postId: postId, content: content)
    }
    
    //MARK: - API funcs
    
    /// 커뮤니티 글 리스트 조회 API
    public func getCommunityPosts(category: String, lastPostId: Int?, completion: @escaping (Result<CommunityResponseDTO?, NetworkError>) -> Void) {
        requestOptional(target: .getCommunityPosts(category: category, lastPostId: lastPostId), decodingType: CommunityResponseDTO.self, completion: completion)
    }
    
    /// 커뮤니티 글 상세 조회 API
    public func getCommunityPost(postId: Int, completion: @escaping (Result<CommunityDetailResponseDTO, NetworkError>) -> Void) {
        request(target: .getCommunityPost(postId: postId), decodingType: CommunityDetailResponseDTO.self, completion: completion)
    }
  
    /// 커뮤니티 댓글 리스트 조회 API
    public func getCommunityComments(postId: Int, lastCommentId: Int?, completion: @escaping (Result<CommunityCommentResponseDTO?, NetworkError>) -> Void) {
        requestOptional(target: .getCommunityComments(postId: postId, lastCommentId: lastCommentId), decodingType: CommunityCommentResponseDTO.self, completion: completion)
    }
    
    /// 커뮤니티 글 작성 API
    public func postCommunityPost(body: CommunityPostRequestDto, imageList: [UIImage], completion: @escaping (Result<PostPostResponse, NetworkError>) -> Void) {
        request(target: .postCommunityPost(data: body, imageList: imageList), decodingType: PostPostResponse.self, completion: completion)
    }
    
    /// 커뮤니티 댓글 작성 API
    public func postCommunityComment(body: CommunityCommentRequestDto, completion: @escaping (Result<PostCommentResponse, NetworkError>) -> Void) {
        request(target: .postCommunityComment(data: body), decodingType: PostCommentResponse.self, completion: completion)
    }
}
