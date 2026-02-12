//
//  BlockService.swift
//  ChungBazi
//
//  Created by 신호연 on 9/18/25.
//

import Foundation
import Moya

final class BlockService: NetworkManager {
    typealias Endpoint = BlockEndpoints

    let provider: MoyaProvider<BlockEndpoints>

    init(provider: MoyaProvider<BlockEndpoints>? = nil) {
        let plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose)),
            TokenRefreshPlugin()
        ]
        self.provider = provider ?? MoyaProvider<BlockEndpoints>(plugins: plugins)
    }

    func postBlockUser(blockedUserId: Int, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        requestOptional(target: .postBlock(blockedUserId: blockedUserId),
                        decodingType: EmptyResponse.self) { (result: Result<EmptyResponse?, NetworkError>) in
            completion(result.map { _ in () })
        }
    }
}
