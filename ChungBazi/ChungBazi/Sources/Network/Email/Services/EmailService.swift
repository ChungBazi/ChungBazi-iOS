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
    // 서버: {"isSuccess":true,"code":"COMMON200","message":"성공입니다.","result":"인증번호 전송이 완료되었습니다."}
    // NetworkManager가 ApiResponse<String>을 내부에서 디코딩하고 result(String?)만 반환함
    func requestEmailVerification(email: String,
                                  completion: @escaping (Result<String?, NetworkError>) -> Void) {
        requestOptional(
            target: .postEmailRequest(email: email),
            decodingType: String.self,
            completion: completion
        )
    }

    // 코드 검증
    // 서버: {"isSuccess":true,"code":"COMMON200","message":"성공입니다.","result":"인증에 성공했습니다."}
    // result가 반드시 문자열로 옴 → 필수형(String)으로 요청
    func verifyEmailCode(email: String, code: String,
                         completion: @escaping (Result<String, NetworkError>) -> Void) {
        request(
            target: .postEmailVerification(email: email, authCode: code),
            decodingType: String.self,
            completion: completion
        )
    }
}
