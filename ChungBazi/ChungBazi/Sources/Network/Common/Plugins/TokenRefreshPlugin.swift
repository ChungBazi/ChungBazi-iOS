//
//  TokenRefreshPlugin.swift
//  ChungBazi
//
//  Created by 이현주 on 2/12/26.
//

import Moya
import Foundation

class TokenRefreshPlugin: PluginType {
    
    private var isRefreshing = false
    private var requestsToRetry: [(Endpoint, Completion)] = []
    
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var request = request
        
        // 토큰 재발급 API는 제외
        if isTokenRefreshRequest(target) {
            return request
        }
        
        // 로그인/회원가입은 제외
        if isAuthRequest(target) {
            return request
        }
        
        // Access Token 추가
        if let accessToken = AuthManager.shared.accessToken {
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
    
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        // 401 에러 처리
        if case .success(let response) = result, response.statusCode == 401 {
            handleTokenExpiration()
        }
    }
    
    private func handleTokenExpiration() {
        
        let authService = AuthService()
        authService.reIssueAccesToken { success in
            if success {
                // 필요하면 NotificationCenter로 알림 (재시도)
            } else {
                self.forceLogout()
            }
        }
    }
    
    private func forceLogout() {
        DispatchQueue.main.async {
            // 로그인 데이터 정리
            AuthManager.shared.clearAuthDataForLogout()
            
            // 로그인 화면으로 이동
            NotificationCenter.default.post(name: .forceLogout, object: nil)
        }
    }
    
    private func isTokenRefreshRequest(_ target: TargetType) -> Bool {
        return target.path.contains("refresh-token")
    }
    
    private func isAuthRequest(_ target: TargetType) -> Bool {
        let path = target.path.lowercased()
        return path.contains("login") ||
        path.contains("kakao-login") ||
        path.contains("apple-login") ||
        path.contains("register") ||
        path.contains("no-auth")
    }
}

// MARK: - Notification Name
extension Notification.Name {
    static let forceLogout = Notification.Name("forceLogout")
}
