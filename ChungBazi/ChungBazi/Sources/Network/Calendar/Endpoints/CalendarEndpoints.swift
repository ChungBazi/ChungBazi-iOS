//
//  CalendarEndpoints.swift
//  ChungBazi
//
//  Created by 이현주 on 1/27/25.
//

import Foundation
import Moya

enum CalendarEndpoints {
    case getCalendarPolicies(yearMonth: String)
    case updateCalendarDocumentsDetail(cartId: Int, data: [UpdateDocuments])
    case postCalendarDocuments(cartId: Int, data: PostDocumentsRequestDto)
    case updateCalendarDocumentsCheck(cartId: Int, data: [UpdateCheck])
}

extension CalendarEndpoints: TargetType {
    
    public var baseURL: URL {
        switch self {
        case .getCalendarPolicies:
            guard let url = URL(string: API.baseURL) else {
                fatalError("잘못된 URL")
            }
            return url
        default :
            guard let url = URL(string: API.calendarURL) else {
                fatalError("잘못된 URL")
            }
            return url
        }
    }
    
    var path: String {
        switch self {
        case .getCalendarPolicies:
            return "/policies/calendar"
        case .updateCalendarDocumentsDetail(let cartId, _), .postCalendarDocuments(let cartId, _):
            return "/\(cartId)/documents"
        case .updateCalendarDocumentsCheck(let cartId, _):
            return "/\(cartId)/documents/check"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getCalendarPolicies:
            return .get
        case .updateCalendarDocumentsDetail:
            return .patch
        case .postCalendarDocuments:
            return .post
        case .updateCalendarDocumentsCheck:
            return .put
        }
    }
    
    var task: Task {
        switch self {
        case .getCalendarPolicies(let yearMonth):
            let parameters: [String: Any] = ["yearMonth": yearMonth]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case .updateCalendarDocumentsDetail(_, let data):
            return .requestJSONEncodable(data)
        case .postCalendarDocuments(_, let data):
            return .requestJSONEncodable(data)
        case .updateCalendarDocumentsCheck(_, let data):
            return .requestJSONEncodable(data)
        }
    }
    
    var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
}
