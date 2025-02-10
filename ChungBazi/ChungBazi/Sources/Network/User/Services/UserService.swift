//
//  UserService.swift
//  ChungBazi
//
//  Created by 이현주 on 1/27/25.
//

import Foundation
import UIKit
import Moya

final class UserService: NetworkManager {
    
    typealias Endpoint = UserEndpoints
    
    // MARK: - Provider 설정
    let provider: MoyaProvider<UserEndpoints>
    
    public init(provider: MoyaProvider<UserEndpoints>? = nil) {
        // 플러그인 추가
        let plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose)) // 로그 플러그인
        ]
        
        // provider 초기화
        self.provider = provider ?? MoyaProvider<UserEndpoints>(plugins: plugins)
    }
    
    // MARK: - DTO funcs
    
    /// UserInfo 데이터 구조 생성
    public func makeUserInfoDTO(region: String, employment: String, income: String, education: String, interests: [String], additionInfo: [String]) -> UserInfoRequestDto {
        return UserInfoRequestDto(region: region, employment: employment, income: income, education: education, interests: interests, additionInfo: additionInfo)
    }
    
    /// UserProfile데이터 구조 생성
    public func makeUserProfileDTO(name: String, characterImg: String) -> ProfileUpdateRequestDto {
        return ProfileUpdateRequestDto(name: name, characterImg: characterImg)
    }

    //MARK: - API funcs
    /// 유저 프로필 조회 API
    public func fetchProfile(completion: @escaping (Result<ProfileResponseDto, NetworkError>) -> Void) {
        request(target: .fetchProfile, decodingType: ProfileResponseDto.self, completion: completion)
    }
    
    /// 사용자 정보 수정 API
    public func updateUserInfo(body: UserInfoRequestDto, completion: @escaping (Result<String, NetworkError>) -> Void) {
        request(target: .updateUserInfo(data: body), decodingType: String.self, completion: completion)
    }
    
    /// 사용자 정보 등록 API
    public func postUserInfo(body: UserInfoRequestDto, completion: @escaping (Result<String, NetworkError>) -> Void) {
        request(target: .postUserInfo(data: body), decodingType: String.self, completion: completion)
    }
    
    /// 프로필 수정 API
    public func updateProfile(body: ProfileUpdateRequestDto, profileImg: String, completion: @escaping (Result<String, NetworkError>) -> Void) {
        request(target: .updateProfile(data: body), decodingType: String.self, completion: completion)
    }
    
    /// 리워드 조회 API
    public func fetchReward(completion: @escaping (Result<RewardResponseDto, NetworkError>) -> Void) {
        request(target: .fetchReward, decodingType: RewardResponseDto.self, completion: completion)
    }
}
