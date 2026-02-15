//
//  TokenRefreshPlugin.swift
//  ChungBazi
//
//  Created by 이현주 on 2/12/26.
//

import Moya
import Foundation

class TokenRefreshPlugin: PluginType {
    
    // MARK: - Prepare Request
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var request = request
        
        if let authTarget = target as? AuthenticatedTarget {
            if !authTarget.requiresAuthentication {
                return request
            }
        }
        
        // 3. Access Token 추가
        if let accessToken = AuthManager.shared.accessToken {
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
    
    // MARK: - Did Receive Response
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        // 인증이 필요하지 않은 endpoint의 401은 무시
        if let authTarget = target as? AuthenticatedTarget, !authTarget.requiresAuthentication {
            return
        }
        
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
        let authService = AuthService()
        
        authService.reIssueAccesToken { success in
            if !success {
                self.forceLogout()
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
}

// MARK: - Notification Name
extension Notification.Name {
    static let forceLogout = Notification.Name("forceLogout")
    static let tokenRefreshed = Notification.Name("tokenRefreshed")
}
