//
//  UserInfoDataManager.swift
//  ChungBazi
//
//  Created by 이현주 on 2/1/25.
//

import Foundation

// MARK: - User 정보 데이터 모델
public struct UserInfo {
    public var region: String
    public var employment: String
    public var income: String
    public var education: String
    public var interests: [String]
    public var additionInfo: [String]

    // 기본 초기화 값 설정
    public init(region: String = "", employment: String = "", income: String = "", education: String = "", interests: [String] = [], additionInfo: [String] = []) {
        self.region = region
        self.employment = employment
        self.income = income
        self.education = education
        self.interests = interests
        self.additionInfo = additionInfo
    }
}

// MARK: - User 정보 매니저 (싱글톤)
public class UserInfoDataManager {
    
    // 싱글톤 인스턴스
    public static let shared = UserInfoDataManager()
    
    // 관리할 User 정보
    private var userInfo: UserInfo = UserInfo()
    
    // 초기화 방지 (싱글톤)
    private init() {}
    
    // MARK: - User 정보 관리 메서드
    
    /// 현재 User 정보를 반환
    public func getUserInfo() -> UserInfo {
        return userInfo
    }
    
    /// User 정보 업데이트
    public func updateUserInfo(
        region: String? = nil,
        employment: String? = nil,
        income: String? = nil,
        education: String? = nil,
        interests: [String]? = nil,
        additionInfo: [String]? = nil
    ) {
        if let region = region { userInfo.region = region }
        if let employment = employment { userInfo.employment = employment }
        if let income = income { userInfo.income = income }
        if let education = education { userInfo.education = education }
        
        if let interests = interests {
            userInfo.interests.append(contentsOf: interests) // ✅ 기존 값에 추가
        }
        
        if let additionInfo = additionInfo {
            userInfo.additionInfo.append(contentsOf: additionInfo) // ✅ 기존 값에 추가
        }
    }
    
    // MARK: - 개별 필드 설정 및 가져오기
    
    /// 지역 설정
    public func setRegion(_ region: String) {
        userInfo.region = region
    }
    
    /// 직업 설정
    public func setEmployment(_ employment: String) {
        userInfo.employment = employment
    }
    
    /// 소득 설정
    public func setIncome(_ income: String) {
        userInfo.income = income
    }
    
    /// 교육 설정
    public func setEducation(_ education: String) {
        userInfo.education = education
    }
    
    /// 관심사 설정
    public func setInterests(_ interests: [String]) {
        userInfo.interests = interests
    }
    
    /// 추가 정보 설정
    public func setAdditionInfo(_ additionInfo: [String]) {
        userInfo.additionInfo = additionInfo
    }
    
    /// 지역 가져오기
    public func getRegion() -> String {
        return userInfo.region
    }
    
    /// 직업 가져오기
    public func getEmployment() -> String {
        return userInfo.employment
    }
    
    /// 소득 가져오기
    public func getIncome() -> String {
        return userInfo.income
    }
    
    /// 교육 가져오기
    public func getEducation() -> String {
        return userInfo.education
    }
    
    /// 관심사 가져오기
    public func getInterests() -> [String] {
        return userInfo.interests
    }
    
    /// 추가 정보 가져오기
    public func getAdditionInfo() -> [String] {
        return userInfo.additionInfo
    }
    
    /// User 정보 초기화
    public func resetUserInfo() {
        userInfo = UserInfo()
    }
}

