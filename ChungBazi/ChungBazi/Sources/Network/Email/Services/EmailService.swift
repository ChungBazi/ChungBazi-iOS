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

    // NetworkManager 프로토콜 요구사항
    let provider: MoyaProvider<EmailEndpoints>

    init(provider: MoyaProvider<EmailEndpoints>? = nil) {
        self.provider = provider ?? MoyaProvider<EmailEndpoints>(plugins: [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
        ])
    }

    // 인증번호 전송
    func requestEmailVerification(email: String,
                                  completion: @escaping (Result<String?, NetworkError>) -> Void) {
        requestOptional(
            target: .postEmailRequest(email: email),
            decodingType: String.self,
            completion: completion
        )
    }
    
    // 로그인 없이 인증번호 전송
    func requestEmailVerificationNoAuth(email: String,
                                        completion: @escaping (Result<String?, NetworkError>) -> Void) {
        requestOptional(target: .postEmailRequestNoAuth(email: email),
                        decodingType: String.self,
                        completion: completion)
    }
    
    // 코드 검증
    func verifyEmailCode(email: String, code: String,
                         completion: @escaping (Result<String, NetworkError>) -> Void) {
        request(
            target: .postEmailVerification(email: email, authCode: code),
            decodingType: String.self,
            completion: completion
        )
    }
    
    private func isLikelyJWT(_ s: String) -> Bool {
        let parts = s.split(separator: ".")
        return parts.count == 3 && parts.allSatisfy { !$0.isEmpty } && s.count > 30
    }
}
