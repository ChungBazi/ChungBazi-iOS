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
    
    // MARK: - 토큰 재발급 상태 관리
    private static var isRefreshingToken = false
    private static var refreshCallbacks: [(Bool) -> Void] = []
    
    // MARK: - Provider 설정
    let provider: MoyaProvider<AuthEndpoints>
    
    public init(provider: MoyaProvider<AuthEndpoints>? = nil) {
        // 플러그인 추가
        let plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose)), // 로그 플러그인
            TokenRefreshPlugin() // 토큰 재발급 플러그인
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
    
    /// 닉네임 등록 DTO
    public func makeRegisterNicknameDTO(name: String, email: String) -> RegisterNicknameRequestDto {
        return RegisterNicknameRequestDto(name: name, email: email)
    }

    //MARK: - API funcs
    /// 카카오 로그인 API
    public func kakaoLogin(data: KakaoLoginRequestDto, completion: @escaping (Result<LoginResponseDto?, NetworkError>) -> Void) {
        requestOptional(target: .postKakaoLogin(data: data), decodingType: LoginResponseDto.self, completion: completion)
    }
    
    /// Apple 로그인 API
    public func appleLogin(data: AppleLoginRequestDto, completion: @escaping (Result<LoginResponseDto?, NetworkError>) -> Void) {
        requestOptional(target: .postAppleLogin(data: data), decodingType: LoginResponseDto.self, completion: completion)
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
    
    /// 비밀번호 재설정 API
    public func resetPassword(data: ResetPasswordRequestDto, completion: @escaping (Result<String, NetworkError>) -> Void) {
        request(target: .postResetPassword(data: data), decodingType: String.self, completion: completion)
    }
    
    /// 로그인 없이 비밀번호 재설정 API
    public func resetPasswordNoAuth(email: String, authCode: String, newPassword: String,
                                    completion: @escaping (Result<String, NetworkError>) -> Void) {
        let dto = ResetPasswordNoAuthRequestDto(
            email: email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
            authCode: authCode.trimmingCharacters(in: .whitespacesAndNewlines),
            newPassword: newPassword
        )
        request(target: .postResetPasswordNoAuth(data: dto), decodingType: String.self, completion: completion)
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
    public func login(data: LoginRequestDto, completion: @escaping (Result<LoginResponseDto?, NetworkError>) -> Void) {
        requestOptional(target: .postLogin(data: data), decodingType: LoginResponseDto.self, completion: completion)
    }
}

extension AuthService {
    /// 토큰 재발급 API 함수
    public func reIssueAccesToken(completion: @escaping (Bool) -> Void) {
        // 중복 재발급 방지
        if Self.isRefreshingToken {
            Self.refreshCallbacks.append(completion)
            return
        }
        
        // Refresh Token 확인
        guard let refreshToken = AuthManager.shared.refreshToken else {
            completion(false)
            return
        }
        
        // 재발급 시작
        Self.isRefreshingToken = true
        Self.refreshCallbacks.append(completion)
        
        print("토큰 재발급 시작 (대기 중인 요청: \(Self.refreshCallbacks.count)개)")
        
        let reIssueDto = makeReIssueDTO(refreshToken: refreshToken)
        
        reissueToken(data: reIssueDto) { result in
            Self.isRefreshingToken = false
            
            switch result {
            case .success(let response):
                AuthManager.shared.updateTokens(
                    accessToken: response.accessToken,
                    refreshToken: response.refreshToken,
                    expiresIn: response.accessExp
                )
            
                print("\(Self.refreshCallbacks.count)개의 대기 요청에 성공 알림")
                Self.refreshCallbacks.forEach { $0(true) }
                Self.refreshCallbacks.removeAll()
                
            case .failure(let error):
                AuthManager.shared.clearAuthDataForLogout()
                
                print("\(Self.refreshCallbacks.count)개의 대기 요청에 실패 알림")
                Self.refreshCallbacks.forEach { $0(false) }
                Self.refreshCallbacks.removeAll()
            }
        }
    }
}
