//
//  AuthManager.swift
//  ChungBazi
//
//  Created by 이현주 on 2/19/25.
//

import KeychainSwift
import Foundation

final class AuthManager {
    static let shared = AuthManager()
    private let keychain = KeychainSwift()
    
    private init() {}
    
    private enum KeychainKey {
        static let serverAccessToken = "serverAccessToken"
        static let serverAccessTokenExp = "serverAccessTokenExp"
        static let serverRefreshToken = "serverRefreshToken"
        static let fcmToken = "FCMToken"
        static let loginType = "loginType"
        static let isFirstLaunch = "isFirstLaunch"
        static let lastAppleLoginEmail = "lastAppleLoginEmail"
    }
    
    var accessToken: String? {
        get { keychain.get(KeychainKey.serverAccessToken) }
        set {
            if let token = newValue {
                keychain.set(token, forKey: KeychainKey.serverAccessToken)
            } else {
                keychain.delete(KeychainKey.serverAccessToken)
            }
        }
    }
    
    var refreshToken: String? {
        get { keychain.get(KeychainKey.serverRefreshToken) }
        set {
            if let token = newValue {
                keychain.set(token, forKey: KeychainKey.serverRefreshToken)
            } else {
                keychain.delete(KeychainKey.serverRefreshToken)
            }
        }
    }
    
    var accessTokenExpiration: String? {
        get { keychain.get(KeychainKey.serverAccessTokenExp) }
        set {
            if let exp = newValue {
                keychain.set(exp, forKey: KeychainKey.serverAccessTokenExp)
            } else {
                keychain.delete(KeychainKey.serverAccessTokenExp)
            }
        }
    }
    
    var fcmToken: String? {
        get {
            // FCMToken 또는 fcmToken 모두 확인
            keychain.get(KeychainKey.fcmToken) ?? keychain.get("fcmToken")
        }
        set {
            if let token = newValue {
                keychain.set(token, forKey: KeychainKey.fcmToken)
            } else {
                keychain.delete(KeychainKey.fcmToken)
            }
        }
    }
    
    var loginType: LoginType? {
        get {
            guard let typeString = keychain.get(KeychainKey.loginType) else { return nil }
            return LoginType(rawValue: typeString)
        }
        set {
            if let type = newValue {
                keychain.set(type.rawValue, forKey: KeychainKey.loginType)
            } else {
                keychain.delete(KeychainKey.loginType)
            }
        }
    }
    
    var isFirstLaunch: Bool {
        get {
            // 키가 없으면 첫 실행으로 간주
            guard let value = keychain.get(KeychainKey.isFirstLaunch) else {
                return true
            }
            return value == "true"
        }
        set {
            keychain.set(newValue ? "true" : "false", forKey: KeychainKey.isFirstLaunch)
        }
    }
    
    var lastAppleLoginEmail: String? {
        get { keychain.get(KeychainKey.lastAppleLoginEmail) }
        set {
            if let email = newValue {
                keychain.set(email, forKey: KeychainKey.lastAppleLoginEmail)
            } else {
                keychain.delete(KeychainKey.lastAppleLoginEmail)
            }
        }
    }
    
    /// 온보딩 완료 처리
    func completeOnboarding() {
        isFirstLaunch = false
    }
    
    func isUserLoggedIn() -> Bool {
        guard let token = accessToken, !token.isEmpty else {
            return false
        }
        return true
    }
    
    func saveLoginData(accessToken: String,
                       refreshToken: String,
                       expiresIn: Int,
                       loginType: LoginType,
                       isFirst: Bool) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        
        // 절대 시간으로 변환하여 저장
        let expirationTimestamp = Int(Date().timeIntervalSince1970) + expiresIn
        self.accessTokenExpiration = String(expirationTimestamp)
        
        self.loginType = loginType
        self.isFirstLaunch = isFirst
    }
    
    func updateTokens(accessToken: String,
                      refreshToken: String? = nil,
                      expiresIn: Int) {
        self.accessToken = accessToken
        if let newRefreshToken = refreshToken {
            self.refreshToken = newRefreshToken
        }
        
        // 절대 시간으로 변환하여 저장
        let expirationTimestamp = Int(Date().timeIntervalSince1970) + expiresIn
        self.accessTokenExpiration = String(expirationTimestamp)
    }
    
    func isAccessTokenExpired() -> Bool {
        guard let expString = accessTokenExpiration,
              let expTimestamp = Int(expString) else {
            return true  // 만료 시간 정보 없으면 만료된 것으로 간주
        }
        
        let currentTimestamp = Int(Date().timeIntervalSince1970)
        return currentTimestamp >= expTimestamp
    }
    
    /// accessToken 만료까지 남은 시간 (초)
    func timeUntilExpiration() -> Int? {
        guard let expString = accessTokenExpiration,
              let expTimestamp = Int(expString) else {
            return nil
        }
        
        let currentTimestamp = Int(Date().timeIntervalSince1970)
        let remaining = expTimestamp - currentTimestamp
        return max(0, remaining)
    }
    
    /// 로그아웃 시: 인증 데이터만 삭제
    func clearAuthDataForLogout() {
        accessToken = nil
        refreshToken = nil
        accessTokenExpiration = nil
        loginType = nil
    }
    
    /// 회원탈퇴 시: 모든 데이터 완전 삭제
    func clearAuthDataForWithdrawal() {
        accessToken = nil
        refreshToken = nil
        accessTokenExpiration = nil
        loginType = nil
        isFirstLaunch = true
    }
}
