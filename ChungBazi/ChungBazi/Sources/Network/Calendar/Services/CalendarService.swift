//
//  CalendarService.swift
//  ChungBazi
//
//  Created by 이현주 on 1/27/25.
//

import Foundation
import Moya

final class CalendarService: NetworkManager {
    
    typealias Endpoint = CalendarEndpoints
    
    // MARK: - Provider 설정
    let provider: MoyaProvider<CalendarEndpoints>
    
    public init(provider: MoyaProvider<CalendarEndpoints>? = nil) {
        // 플러그인 추가
        let plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
        ]
        
        // provider 초기화
        self.provider = provider ?? MoyaProvider<CalendarEndpoints>(plugins: plugins)
    }
    
    // MARK: - DTO funcs
    /// UpdateDocuments 데이터 구조 생성
    public func makeUpdateDocuments(documentId: Int, content: String) -> UpdateDocuments {
        return UpdateDocuments(documentId: documentId, content: content)
    }
    
    ///UpdateCheck 데이터 구조 생성
    public func makeUpdateCheck(documentId: Int, checked: Bool) -> UpdateCheck {
        return UpdateCheck(documentId: documentId, checked: checked)
    }
    
    /// PostDocumentsRequestDto 데이터 구조 생성
    public func makePostDocumentsRequestDto(documents: [String]) -> PostDocumentsRequestDto {
        return PostDocumentsRequestDto(documents: documents)
    }
    
    //MARK: - API funcs
    
    public func getCalendarPolicies(yearMonth: String, completion: @escaping (Result<[CalendarResponseDTO]?, NetworkError>) -> Void) {
        requestOptional(target: .getCalendarPolicies(yearMonth: yearMonth), decodingType: [CalendarResponseDTO].self, completion: completion)
    }
    
    /// 캘린더 서류 수정 API
    public func updateCalendarDocumentsDetail(cartId: Int, body: [UpdateDocuments], completion: @escaping (Result<String, NetworkError>) -> Void) {
        request(target: .updateCalendarDocumentsDetail(cartId: cartId, data: body), decodingType: String.self, completion: completion)
    }
    
    /// 캘린더 서류 추가 API
    public func postpostCalendarDocuments(cartId: Int, body: PostDocumentsRequestDto, completion: @escaping (Result<String, NetworkError>) -> Void) {
        request(target: .postCalendarDocuments(cartId: cartId, data: body), decodingType: String.self, completion: completion)
    }
    
    /// 캘린더 서류 체크 API
    public func updateCalendarDocumentsCheck(cartId: Int, body: [UpdateCheck], completion: @escaping (Result<String, NetworkError>) -> Void) {
        request(target: .updateCalendarDocumentsCheck(cartId: cartId, data: body), decodingType: String.self, completion: completion)
    }
}
