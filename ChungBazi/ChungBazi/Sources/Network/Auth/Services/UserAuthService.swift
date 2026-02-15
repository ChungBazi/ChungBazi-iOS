//
//  UserAuthService.swift
//  ChungBazi
//
//  Created by 이현주 on 2/15/26.
//

import Moya
import Foundation

/// 인증이 필요한 사용자 관련 API
final class UserAuthService: NetworkManager {
    typealias Endpoint = AuthEndpoints
    
    let provider: MoyaProvider<AuthEndpoints>

    init(provider: MoyaProvider<AuthEndpoints>? = nil) {
        let plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose)),
            TokenRefreshPlugin()
        ]
        self.provider = provider ?? MoyaProvider<AuthEndpoints>(plugins: plugins)
    }
    
    // MARK: - API funcs
    
    /// 로그아웃 API
    public func logout(completion: @escaping (Result<String, NetworkError>) -> Void) {
        request(target: .postLogout, decodingType: String.self, completion: completion)
    }
    
    /// 회원 탈퇴 API
    public func deleteUser(completion: @escaping (Result<String, NetworkError>) -> Void) {
        request(target: .deleteUser, decodingType: String.self, completion: completion)
    }
    
    /// 비밀번호 재설정 API
    public func resetPassword(data: ResetPasswordRequestDto, completion: @escaping (Result<String, NetworkError>) -> Void) {
        request(target: .postResetPassword(data: data), decodingType: String.self, completion: completion)
    }
}
