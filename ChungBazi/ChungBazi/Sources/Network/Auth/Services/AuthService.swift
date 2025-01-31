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
    public func makeKakaoDTO(name: String, email: String, fcmToken: String) -> KakaoLoginRequestDto {
        return KakaoLoginRequestDto(name: name, email: email, fcmToken: fcmToken)
    }
    
    /// accessToken 재발급 request 데이터 구조 생성
    public func makeReIssueDTO(refreshToken: String) -> ReIssueRequestDto {
        return ReIssueRequestDto(refreshToken: refreshToken)
    }

    //MARK: - API funcs
    /// 카카오 로그인 API
    public func kakaoLogin(data: KakaoLoginRequestDto, completion: @escaping (Result<KakaoLoginResponseDto, NetworkError>) -> Void) {
        request(target: .postKakaoLogin(data: data), decodingType: KakaoLoginResponseDto.self, completion: completion)
    }
    
    /// 로그아웃 API
    public func logout(completion: @escaping (Result<String, NetworkError>) -> Void) {
        request(target: .postLogout, decodingType: String.self, completion: completion)
    }
    
    /// 토큰 재발급 API
    public func reissueToken(data: ReIssueRequestDto, completion: @escaping (Result<ReIssueResponseDto, NetworkError>) -> Void) {
        request(target: .postReIssueToken(data: data), decodingType: ReIssueResponseDto.self, completion: completion)
    }
    
    /// 회원 탈퇴 API
    public func deleteUser(completion: @escaping (Result<String, NetworkError>) -> Void) {
        request(target: .deleteUser, decodingType: String.self, completion: completion)
    }
}
