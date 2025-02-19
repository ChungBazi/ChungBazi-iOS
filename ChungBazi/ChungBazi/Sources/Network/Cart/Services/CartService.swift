//
//  CartService.swift
//  ChungBazi
//
//  Created by 이현주 on 1/27/25.
//

import Foundation
import Moya

final class CartService: NetworkManager {
    
    typealias Endpoint = CartEndpoints
    
    // MARK: - Provider 설정
    let provider: MoyaProvider<CartEndpoints>
    
    public init(provider: MoyaProvider<CartEndpoints>? = nil) {
        // 플러그인 추가
        let plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose)) // 로그 플러그인
        ]
        
        // provider 초기화
        self.provider = provider ?? MoyaProvider<CartEndpoints>(plugins: plugins)
    }
    
    // MARK: - DTO funcs
    
    /// DeleteCartRequestDto 데이터 구조 생성
    public func makeDeleteCartDTO(deleteList: [Int]) -> DeleteCartRequestDto {
        return DeleteCartRequestDto(deleteList: deleteList)
    }

    //MARK: - API funcs
    
    /// 장바구니에 담기 API
    public func postCart(policyId: Int, completion: @escaping (Result<String, NetworkError>) -> Void) {
        request(target: .postCart(policyId: policyId), decodingType: String.self, completion: completion)
    }
    
    /// 장바구니 삭제 API
    public func deleteCart(body: DeleteCartRequestDto, completion: @escaping (Result<String, NetworkError>) -> Void) {
        request(target: .deleteCart(data: body), decodingType: String.self, completion: completion)
    }
    
    /// 장바구니 정책 전체 조회 API
    public func fetchCartList(completion: @escaping (Result<[CategoryPolicyList]?, NetworkError>) -> Void) {
        requestOptional(target: .fetchCartList, decodingType: [CategoryPolicyList].self, completion: completion)
    }
}
