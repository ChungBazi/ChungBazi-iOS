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
    
    let provider: MoyaProvider<CalendarEndpoints>
    
    public init(provider: MoyaProvider<CalendarEndpoints>? = nil) {
        let plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
        ]
        
        self.provider = provider ?? MoyaProvider<CalendarEndpoints>(plugins: plugins)
    }
    
    public func getCalendarPolicies(yearMonth: String, completion: @escaping (Result<CalendarResponseDTO, NetworkError>) -> Void) {
        request(target: .getCalendarPolicies(yearMonth: yearMonth), decodingType: CalendarResponseDTO.self, completion: completion)
    }
}
