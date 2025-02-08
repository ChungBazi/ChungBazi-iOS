//
//  Untitled.swift
//  ChungBazi
//
//  Created by 이현주 on 2/9/25.
//

import Foundation

// MARK: - User 프로필 데이터 모델
public struct UserProfile {
    public var nickname: String
    public var character: String

    // 기본 초기화 값 설정
    public init(nickname: String = "", character: String = CharacterImage.default) {
        self.nickname = nickname
        self.character = character
    }
    
    public var characterLevel: Int {
        return CharacterImage.levelMapping[character] ?? 0
    }
}

// MARK: - User 프로필 매니저 (싱글톤)
public class UserProfileDataManager {
    
    // 싱글톤 인스턴스
    public static let shared = UserProfileDataManager()
    
    // 관리할 User 정보
    private var userProfile: UserProfile = UserProfile()
    
    // 초기화 방지 (싱글톤)
    private init() {}
    
    // MARK: - User 프로필 관리 메서드
    
    /// 현재 User 정보를 반환
    public func getUserInfo() -> UserProfile {
        return userProfile
    }
    
    /// User 정보 업데이트
    public func updateProfileInfo(
        nickname: String? = nil,
        character: String? = nil
    ) {
        if let nickname = nickname { userProfile.nickname = nickname }
        if let character = character { userProfile.character = character }
    }
    
    // MARK: - 개별 필드 설정 및 가져오기
    
    /// 닉네임 설정
    public func setNickname(_ nickname: String) {
        userProfile.nickname = nickname
    }
    
    /// 캐릭터 설정
    public func setCharacter(_ character: String) {
        userProfile.character = character
    }
    
    /// 닉네임 가져오기
    public func getNickname() -> String {
        return userProfile.nickname
    }
    
    /// 캐릭터 가져오기
    public func getCharacter() -> String {
        return userProfile.character
    }
    
    /// 캐릭터 단계 가져오기
    public func getCharacterNum() -> Int {
        return userProfile.characterLevel
    }
    
    ///  캐릭터 숫자로 설정 (예: 1 → "LEVEL_1")
    public func setCharacterNum(_ level: Int) {
        if let character = CharacterImage.levelMapping.first(where: { $0.value == level })?.key {
            userProfile.character = character
        }
    }
    
    /// User 프로필 초기화
    public func resetUserProfile() {
        userProfile = UserProfile()
    }
}

