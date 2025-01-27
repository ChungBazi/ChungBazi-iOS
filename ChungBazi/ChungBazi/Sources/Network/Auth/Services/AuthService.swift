//
//  AuthService.swift
//  ChungBazi
//
//  Created by 이현주 on 1/27/25.
//

import Foundation
import Moya

final class AuthService: NetworkManager {
    
    typealias Endpoint = AuthEndpoints
    
    // MARK: - Provider 설정
    let provider: MoyaProvider<AuthEndpoints>
    
    public init(provider: MoyaProvider<AuthEndpoints>? = nil) {
        // 플러그인 추가
        let plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose)) // 로그 플러그인
        ]
        
        // provider 초기화
        self.provider = provider ?? MoyaProvider<AuthEndpoints>(plugins: plugins)
    }
    
    // MARK: - DTO funcs
    
    /// 카카오 로그인 데이터 구조 생성
    public func makeKakaoDTO(name: String, email: String) -> KakaoLoginRequestDto {
        return KakaoLoginRequestDto(name: name, email: email)
    }

    //MARK: - API funcs
    /// 카카오 로그인 API
    public func kakaoLogin(data: KakaoLoginRequestDto, completion: @escaping (Result<KakaoLoginResponseDto, NetworkError>) -> Void) {
        request(target: .postKakaoLogin(data: data), decodingType: KakaoLoginResponseDto.self, completion: completion)
    }
    
    /// 로그아웃 API
    public func logout(completion: @escaping (Result<Void, NetworkError>) -> Void) {
        provider.request(.postLogout) { result in
            switch result {
            case .success(let response):
                if response.statusCode == 200 {
                    completion(.success(()))
                } else {
                    let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: response.data)
                    let finalMessage = errorResponse?.message ?? "에러 메세지 없음"
                    return completion(.failure(.serverError(statusCode: response.statusCode, message: finalMessage)))
                }
                
            case .failure(let error):
                let networkError = self.handleNetworkError(error)
                completion(.failure(networkError))
            }
        }
    }
    
    /// 토큰 재발급 API
    public func reissueToken(completion: @escaping (Result<KakaoLoginResponseDto, NetworkError>) -> Void) {
        request(target: .postReIssueToken, decodingType: KakaoLoginResponseDto.self, completion: completion)
    }
    
    /// 회원 탈퇴 API 해야함
}
