//
//  PolicyService.swift
//  ChungBazi
//
//  Created by 이현주 on 1/27/25.
//

import Foundation
import Moya

final class PolicyService: NetworkManager {
    
    typealias Endpoint = PolicyEndpoints
    
    // MARK: - Provider 설정
    let provider: MoyaProvider<PolicyEndpoints>
    
    public init(provider: MoyaProvider<PolicyEndpoints>? = nil) {
        // 플러그인 추가
        let plugins: [PluginType] = [
            CookiePlugin(),
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose)) // 로그 플러그인
        ]
        
        // provider 초기화
        self.provider = provider ?? MoyaProvider<PolicyEndpoints>(plugins: plugins)
    }
    
    // MARK: - DTO funcs
    
    ///

    //MARK: - API funcs
    /// 정책 검색 API
    public func searchPolicy(name: String, cursor: String, order: String, completion: @escaping (Result<PolicySearchResponseDto, NetworkError>) -> Void) {
        request(target: .searchPolicy(name: name, cursor: cursor, order: order), decodingType: PolicySearchResponseDto.self, completion: completion)
    }
    
    /// 인기 검색어 API
    public func fetchPopularSearchText(completion: @escaping (Result<PopularSearchTextDto, NetworkError>) -> Void) {
        request(target: .fetchPopularSearchText, decodingType: PopularSearchTextDto.self, completion: completion)
    }
    
    /// more...
}
