//
//  ChatbotService.swift
//  ChungBazi
//
//  Created by 신호연 on 12/11/25.
//

import Foundation
import Moya

final class ChatbotService: NetworkManager {
    
    typealias Endpoint = ChatbotEndpoints
    
    // MARK: - Provider
    let provider: MoyaProvider<ChatbotEndpoints>
    
    let plugins: [PluginType] = [
        NetworkLoggerPlugin(configuration: .init(logOptions: .verbose)),
        TokenRefreshPlugin()
    ]
    
    init(stub: Bool = false) {
        if stub {
            self.provider = MoyaProvider<ChatbotEndpoints>(
                stubClosure: MoyaProvider.immediatelyStub,
                plugins: plugins
            )
        } else {
            self.provider = MoyaProvider<ChatbotEndpoints>(
                plugins: plugins
            )
        }
    }
    
    // MARK: - APIs
    public func getPolicyDetail(
        policyId: Int,
        completion: @escaping (Result<ChatbotPolicyDetail, NetworkError>) -> Void
    ) {
        request(
            target: .getPolicyDetail(policyId: policyId),
            decodingType: ChatbotPolicyDetail.self,
            completion: completion
        )
    }
    
    public func getPolicies(
        category: ChatbotCategory,
        completion: @escaping (Result<[ChatbotPolicySummary], NetworkError>) -> Void
    ) {
        request(
            target: .getPolicies(category: category),
            decodingType: [ChatbotPolicySummary].self,
            completion: completion
        )
    }
    
    public func ask(
        message: String,
        completion: @escaping (Result<ChatbotAskResult, NetworkError>) -> Void
    ) {
        let body = ChatbotAskRequestDto(message: message)
        
        request(
            target: .ask(data: body),
            decodingType: ChatbotAskResult.self,
            completion: completion
        )
    }
}
