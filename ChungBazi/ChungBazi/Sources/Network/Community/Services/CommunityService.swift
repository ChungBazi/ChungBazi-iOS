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
    public func getCommunityPosts(category: String, cursor: Int, completion: @escaping (Result<CommunityResponseDTO?, NetworkError>) -> Void) {
        requestOptional(target: .getCommunityPosts(category: category, cursor: cursor), decodingType: CommunityResponseDTO.self, completion: completion)
    }
    
    /// 커뮤니티 글 상세 조회 API
    public func getCommunityPost(postId: Int, completion: @escaping (Result<CommunityDetailResponseDTO, NetworkError>) -> Void) {
        request(target: .getCommunityPost(postId: postId), decodingType: CommunityDetailResponseDTO.self, completion: completion)
    }
    
    /// 커뮤니티 댓글 리스트 조회 API
    public func getCommunityComments(postId: Int, cursor: Int, completion: @escaping (Result<CommunityCommentResponseDTO?, NetworkError>) -> Void) {
        requestOptional(target: .getCommunityComments(postId: postId, cursor: cursor), decodingType: CommunityCommentResponseDTO.self, completion: completion)
    }
    
    /// 커뮤니티 글 작성 API
    func postCommunityPost(body: CommunityPostRequestDto, imageList: [UIImage], completion: @escaping (Result<PostPostResponse, Error>) -> Void) {
        
        var multipartData: [MultipartFormData] = []
        
        if let jsonData = try? JSONEncoder().encode(body) {
            multipartData.append(MultipartFormData(provider: .data(jsonData), name: "info", mimeType: "application/json"))
        } else {
            print("🚨 JSON 인코딩 실패")
            return
        }
        
        for (index, image) in imageList.enumerated() {
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                let imagePart = MultipartFormData(provider: .data(imageData), name: "imageList", fileName: "image\(index).jpg", mimeType: "image/jpeg")
                multipartData.append(imagePart)
            }
        }
        
        provider.request(.postCommunityPost(data: body, imageList: imageList)) { result in
            switch result {
            case .success(let response):
                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: response.data, options: []) as? [String: Any]
                    if let resultData = jsonObject?["result"] {
                        let resultJson = try JSONSerialization.data(withJSONObject: resultData, options: [])
                        let responseObject = try JSONDecoder().decode(PostPostResponse.self, from: resultJson)
                        completion(.success(responseObject))
                    } else {
                        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "result 데이터가 없습니다."])))
                    }
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// 커뮤니티 댓글 작성 API
    public func postCommunityComment(body: CommunityCommentRequestDto, completion: @escaping (Result<PostCommentResponse, NetworkError>) -> Void) {
        request(target: .postCommunityComment(data: body), decodingType: PostCommentResponse.self, completion: completion)
    }
    
    /// 커뮤니티 검색 API
    public func searchCommunity(query: String, filter: String = "title", period: String = "all", cursor: Int, completion: @escaping (Result<CommunityResponseDTO?, NetworkError>) -> Void) {
        requestOptional(target: .searchCommunity(query: query, filter: filter, period: period, cursor: cursor), decodingType: CommunityResponseDTO.self, completion: completion)
    }
    
    /// 커뮤니티 인기 검색어 API
    public func getCommunityPopularWords(completion: @escaping (Result<SearchCommunityPopularWordsResponseDTO?, NetworkError>) -> Void) {
        requestOptional(target: .getCommunityPopularWords, decodingType: SearchCommunityPopularWordsResponseDTO.self, completion: completion)
    }
    
    /// 커뮤니티 글 좋아요 API
    public func postCommunityLike(postId: Int, completion: @escaping (Result<String?, NetworkError>) -> Void) {
        requestOptional(target: .postCommunityLike(postId: postId), decodingType: String.self, completion: completion)
    }
    
    /// 커뮤니티 글 좋아요 취소 API
    public func deleteCommunityLike(postId: Int, completion: @escaping (Result<String?, NetworkError>) -> Void) {
        requestOptional(target: .deleteCommunityLike(postId: postId), decodingType: String.self, completion: completion)
    }
    
    /// 게시글 삭제
    public func deleteCommunityPost(postId: Int, completion: @escaping (Result<String?, NetworkError>) -> Void) {
        requestOptional(target: .deleteCommunityPost(postId: postId), decodingType: String.self, completion: completion)
    }
    
    /// 댓글 삭제
    public func deleteCommunityComment(commentId: Int, completion: @escaping (Result<String?, NetworkError>) -> Void) {
        requestOptional(target: .deleteCommunityComment(commentId: commentId), decodingType: String.self, completion: completion)
    }
    
    /// 게시글 좋아요
    func postLike(postId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        provider.request(.postLike(postId: postId)) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// 게시글 좋아요 취소
    func deleteLike(postId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        provider.request(.deleteLike(postId: postId)) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// 댓글 좋아요
    func postCommentLike(commentId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        provider.request(.postCommentLike(commentId: commentId)) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// 댓글 좋아요 취소
    func deleteCommentLike(commentId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        provider.request(.deleteCommentLike(commentId: commentId)) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
