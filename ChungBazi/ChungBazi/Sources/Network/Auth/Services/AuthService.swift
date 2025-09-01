//
//  AuthService.swift
//  ChungBazi
//
//  Created by 이현주 on 1/27/25.
//

import Foundation
import Moya
import KeychainSwift

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
    
    /// 애플 로그인 DTO 생성
    public func makeAppleDTO(idToken: String, fcmToken: String) -> AppleLoginRequestDto {
        return AppleLoginRequestDto(idToken: idToken, fcmToken: fcmToken)
    }

    //MARK: - API funcs
    /// 카카오 로그인 API
    public func kakaoLogin(data: KakaoLoginRequestDto, completion: @escaping (Result<KakaoLoginResponseDto, NetworkError>) -> Void) {
        request(target: .postKakaoLogin(data: data), decodingType: KakaoLoginResponseDto.self, completion: completion)
    }
    
    /// Apple 로그인 API
    public func appleLogin(data: AppleLoginRequestDto, completion: @escaping (Result<AppleLoginResponseDto, NetworkError>) -> Void) {
        request(target: .postAppleLogin(data: data), decodingType: AppleLoginResponseDto.self, completion: completion)
    }
    
    /// 로그아웃 API
    public func logout(completion: @escaping (Result<String, NetworkError>) -> Void) {
        request(target: .postLogout, decodingType: String.self, completion: completion)
    }
    
    /// 토큰 재발급 API
    public func reissueToken(data: ReIssueRequestDto, completion: @escaping (Result<ReIssueResponseDto, NetworkError>) -> Void) {
        request(target: .postReIssueToken(data: data), decodingType: ReIssueResponseDto.self, completion: completion)
    }
    
    /// 토큰 재발급 API 함수
    public func reIssueAccesToken(completion: @escaping (Bool) -> Void) {
        guard let refreshToken = KeychainSwift().get("serverRefreshToken") else {
            completion(false)
            return
        }
        
        let reIssueDto = AuthService().makeReIssueDTO(refreshToken: refreshToken)
        AuthService().reissueToken(data: reIssueDto) { result in
            switch result {
            case .success(let response):
                KeychainSwift().set(response.accessToken, forKey: "serverAccessToken")
                let expirationTimestamp = Int(Date().timeIntervalSince1970) + response.accessExp
                KeychainSwift().set(String(expirationTimestamp), forKey: "serverAccessTokenExp")
                completion(true)
            case .failure:
                completion(false)
            }
        }
    }
    
    /// 회원 탈퇴 API
    public func deleteUser(completion: @escaping (Result<String, NetworkError>) -> Void) {
        request(target: .deleteUser, decodingType: String.self, completion: completion)
    }
    
    /// 비밀번호 재설정 API
    public func resetPassword(data: ResetPasswordRequestDto, completion: @escaping (Result<String, NetworkError>) -> Void) {
        request(target: .postResetPassword(data: data), decodingType: String.self, completion: completion)
    }
    
    /// 일반 사용자 회원가입 API
    public func register(data: RegisterRequestDto, completion: @escaping (Result<String, NetworkError>) -> Void) {
        request(target: .postRegister(data: data), decodingType: String.self, completion: completion)
    }
    
    /// 일반 사용자 닉네임 등록 API
    public func registerNickname(data: RegisterNicknameRequestDto, completion: @escaping (Result<String, NetworkError>) -> Void) {
        request(target: .postRegisterNickname(data: data), decodingType: String.self, completion: completion)
    }
    
    /// 일반 사용자 로그인 API
    public func login(data: LoginRequestDto, completion: @escaping (Result<LoginResponseDto, NetworkError>) -> Void) {
        request(target: .postLogin(data: data), decodingType: LoginResponseDto.self, completion: completion)
    }
}
