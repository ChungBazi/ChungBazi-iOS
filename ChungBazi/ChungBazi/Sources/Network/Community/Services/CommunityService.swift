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
    
    public func makeCommunityDTO(category: CommunityCategory, lastPostId: Int, size: Int) -> CommunityRequestDTO {
        return CommunityRequestDTO(category: category, lastPostId: lastPostId, size: size)
    }
    
    public func getCommunityPosts(data: CommunityRequestDTO, completion: @escaping (Result<CommunityResponseDTO, NetworkError>) -> Void) {
        request(target: .getCommunityPosts(data: data), decodingType: CommunityResponseDTO.self, completion: completion)
    }
}
