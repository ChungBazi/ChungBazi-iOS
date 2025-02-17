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

    //MARK: - API funcs
    /// 정책 검색 API
    public func searchPolicy(name: String, cursor: String, order: String, completion: @escaping (Result<PolicyListResponseDto?, NetworkError>) -> Void) {
        requestOptional(target: .searchPolicy(name: name, cursor: cursor, order: order), decodingType: PolicyListResponseDto.self, completion: completion)
    }
    
    /// 인기 검색어 API
    public func fetchPopularSearchText(completion: @escaping (Result<PopularSearchTextDto?, NetworkError>) -> Void) {
        requestOptional(target: .fetchPopularSearchText, decodingType: PopularSearchTextDto.self, completion: completion)
    }
    
    /// 카테고리별 정책 API
    public func fetchCategoryPolicy(category: String, cursor: Int, order: String, completion: @escaping (Result<PolicyListResponseDto?, NetworkError>) -> Void) {
        requestOptional(target: .fetchCategoryPolicy(category: category, cursor: cursor, order: order), decodingType: PolicyListResponseDto.self, completion: completion)
    }
    
    /// 정책 추천 조회 API
    public func fetchRecommendPolicy(category: String, cursor: Int, order: String, completion: @escaping (Result<RecommendPolicyListResponseDto?, NetworkError>) -> Void) {
        requestOptional(target: .fetchRecommendPolicy(category: category, cursor: cursor, order: order), decodingType: RecommendPolicyListResponseDto.self, completion: completion)
    }
    
    /// 정책 상세 조회 API
    public func fetchPolicyDetail(policyId: Int, completion: @escaping (Result<PolicyDetailResponseDto?, NetworkError>) -> Void) {
        requestOptional(target: .fetchPolicyDetail(policyId: policyId), decodingType: PolicyDetailResponseDto.self, completion: completion)
    }
    
    /// 캘린더 정책 전체 조회 API
    public func fetchCalendarPolicyList(yearMonth: String, completion: @escaping (Result<CalendarPolicyListResponseDto?, NetworkError>) -> Void) {
        requestOptional(target: .fetchCalendarPolicyList(yearMonth: yearMonth), decodingType: CalendarPolicyListResponseDto.self, completion: completion)
    }
    
    /// 캘린더 정책 상세 조회 API
    public func fetchCalendarPolicyDetail(cartId: Int, completion: @escaping (Result<CalendarPolicyDetailResponseDto?, NetworkError>) -> Void) {
        requestOptional(target: .fetchCalendarPolicyDetail(cartId: cartId), decodingType: CalendarPolicyDetailResponseDto.self, completion: completion)
    }
}
