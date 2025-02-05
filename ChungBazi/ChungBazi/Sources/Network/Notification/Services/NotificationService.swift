//
//  NotificationService.swift
//  ChungBazi
//
//  Created by 이현주 on 1/27/25.
//

import Foundation
import Moya

final class NotificationService: NetworkManager {
    
    typealias Endpoint = NotificationEndpoints
    
    // MARK: - Provider 설정
    let provider: MoyaProvider<NotificationEndpoints>
    
    public init(provider: MoyaProvider<NotificationEndpoints>? = nil) {
        // 플러그인 추가
        let plugins: [PluginType] = [
            CookiePlugin(),
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose)) // 로그 플러그인
        ]
        
        // provider 초기화
        self.provider = provider ?? MoyaProvider<NotificationEndpoints>(plugins: plugins)
    }
    
    // MARK: - DTO funcs
    
    /// NoticeSetting 데이터 구조 생성
    public func makeNoticeSettingDTO(policyAlarm: Bool, communityAlarm: Bool, rewardAlarm: Bool, noticeAlarm: Bool) -> NoticeSettingRequestDto {
        return NoticeSettingRequestDto(policyAlarm: policyAlarm, communityAlarm: communityAlarm, rewardAlarm: rewardAlarm, noticeAlarm: noticeAlarm)
    }

    //MARK: - API funcs
    /// 알림 리스트 조회 API
    public func fetchAlarmList(type: String, cursor: Int, completion: @escaping (Result<NoticeListResponseDto, NetworkError>) -> Void) {
        request(target: .fetchAlarmList(type: type, cursor: cursor), decodingType: NoticeListResponseDto.self, completion: completion)
    }
    
    /// 알림 수신 설정 조회 API
    public func fetchAlarmSetting(completion: @escaping (Result<NoticeSettingResponseDto, NetworkError>) -> Void) {
        request(target: .fetchAlarmSetting, decodingType: NoticeSettingResponseDto.self, completion: completion)
    }
    
    /// 알림 수신 설정 API
    public func patchAlarmSetting(body: NoticeSettingRequestDto, completion: @escaping (Result<NoticeSettingResponseDto, NetworkError>) -> Void) {
        request(target: .patchAlarmSetting(data: body), decodingType: NoticeSettingResponseDto.self, completion: completion)
    }
}
