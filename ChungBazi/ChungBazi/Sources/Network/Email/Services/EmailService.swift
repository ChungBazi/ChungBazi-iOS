//
//  EmailService.swift
//  ChungBazi
//
//  Created by 엄민서 on 8/28/25.
//

import Foundation
import Moya

final class EmailService: NetworkManager {
    
    typealias Endpoint = EmailEndpoints

    // MARK: - Provider 설정
    let provider: MoyaProvider<EmailEndpoints>

    public init(provider: MoyaProvider<EmailEndpoints>? = nil) {
        // 플러그인 추가
        let plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose)) // 로그 플러그인
        ]
        
        // provider 초기화
        self.provider = provider ?? MoyaProvider<EmailEndpoints>(plugins: plugins)
    }

    // MARK: - 이메일 인증 요청 
    public func requestEmailVerification(completion: @escaping (Result<ApiResponse<String>, NetworkError>) -> Void) {
        request(target: .postEmailRequest, decodingType: ApiResponse<String>.self, completion: completion)
    }

    // MARK: - 인증 코드 검증
    public func verifyEmailCode(authCode: String, completion: @escaping (Result<ApiResponse<String>, NetworkError>) -> Void) {
        let dto = EmailVerificationRequestDTO(authCode: authCode)
        request(target: .postEmailVerification(data: dto), decodingType: ApiResponse<String>.self, completion: completion)
    }
}
