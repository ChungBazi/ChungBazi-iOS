//
//  TokenRefreshPlugin.swift
//  ChungBazi
//
//  Created by 이현주 on 2/12/26.
//

import Moya
import Foundation

class TokenRefreshPlugin: PluginType {
    
    // MARK: - Static Properties (중복 방지)
    private static var isRefreshing = false
    private static var failedRequests: [(TargetType, (Result<Response, MoyaError>) -> Void)] = []
    
    // MARK: - Prepare Request
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var request = request
        
        // 1. 토큰 재발급 API는 제외
        if isTokenRefreshRequest(target) { return request }
        
        // 2. 로그인/회원가입 API는 제외
        if isAuthRequest(target) { return request }
        
        // 3. Access Token 추가
        if let accessToken = AuthManager.shared.accessToken {
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
    
    // MARK: - Did Receive Response
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        switch result {
        case .success(let response):
            
            // 401 에러 감지
            if response.statusCode == 401 {
                handleTokenExpiration()
            }
            
        case .failure(let error):
            print("  - Error: \(error)")
        }
    }
    
    // MARK: - Handle Token Expiration
    private func handleTokenExpiration() {
        
        // 이미 재발급 중이면 대기
        if Self.isRefreshing { return }
        
        Self.isRefreshing = true
        
        let authService = AuthService()
        authService.reIssueAccesToken { [weak self] success in
            Self.isRefreshing = false
        
            if success {
                // 사용자에게 알림 (선택사항)
                // 현재는 사용자가 액션을 다시 수행해야 함
            } else {
                self?.forceLogout()
            }
        }
    }
    
    // MARK: - Force Logout
    private func forceLogout() {
        DispatchQueue.main.async {
            // 로그인 데이터 정리
            AuthManager.shared.clearAuthDataForLogout()
            
            // 로그인 화면으로 이동
            NotificationCenter.default.post(name: .forceLogout, object: nil)
        }
    }
    
    // MARK: - Helper Methods
    private func isTokenRefreshRequest(_ target: TargetType) -> Bool {
        let path = target.path.lowercased()
        let isRefresh = path.contains("refresh-token") ||
                       path.contains("reissue") ||
                       path.contains("refresh")
        
        return isRefresh
    }
    
    private func isAuthRequest(_ target: TargetType) -> Bool {
        let path = target.path.lowercased()
        let isAuth = path.contains("login") ||
                    path.contains("kakao-login") ||
                    path.contains("apple-login") ||
                    path.contains("register") ||
                    path.contains("signup") ||
                    path.contains("no-auth")
        
        return isAuth
    }
}

// MARK: - Notification Name
extension Notification.Name {
    static let forceLogout = Notification.Name("forceLogout")
}
