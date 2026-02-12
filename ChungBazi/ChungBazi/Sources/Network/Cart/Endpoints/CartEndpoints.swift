//
//  CartEndpoints.swift
//  ChungBazi
//
//  Created by 이현주 on 1/27/25.
//

import Foundation
import Moya

enum CartEndpoints {
    case postCart(policyId: Int)
    case deleteCart(data: DeleteCartRequestDto)
    case fetchCartList
}

extension CartEndpoints: TargetType {
    
    public var baseURL: URL {
        guard let url = URL(string: API.cartURL) else {
            fatalError("잘못된 URL")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .postCart(let policyId):
            return "/\(policyId)"
        case .deleteCart:
            return "/delete"
        case .fetchCartList:
            return ""
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .postCart:
            return .post
        case .deleteCart:
            return .delete
        case .fetchCartList:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .postCart(_):
            return .requestPlain
        case .deleteCart(let data):
            return .requestJSONEncodable(data)
        case .fetchCartList:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
}
