//
//  AuthManager.swift
//  ChungBazi
//
//  Created by 이현주 on 2/19/25.
//

import KeychainSwift

class AuthManager {
    static let shared = AuthManager()
    private let keychain = KeychainSwift()
    
    func isUserLoggedIn() -> Bool {
        if let token = keychain.get("serverAccessToken") {
            return !token.isEmpty // 토큰이 존재하면 로그인된 상태
        }
        return false // 토큰이 없으면 로그아웃 상태
    }
}
