//
//  AppleAuthVM.swift
//  ChungBazi
//
//  Created by 신호연 on 5/5/25.
//

import Foundation
import AuthenticationServices
import KeychainSwift

final class AppleAuthVM: NSObject {
    
    private let networkService = AuthService()
    var isFirst: Bool?
    
    var onLoginSuccess: ((Bool, String?) -> Void)?
    var onLoginFailure: ((String) -> Void)?

    func startLogin() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
}

extension AppleAuthVM: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let idTokenData = credential.identityToken,
              let idToken = String(data: idTokenData, encoding: .utf8) else {
            self.onLoginFailure?("ID Token 추출 실패")
            return
        }

        // 닉네임 설정 화면에서 이메일 받아오기 위함
        let emailFromCredential = credential.email
        let emailFromIdToken = Self.extractEmailFromIDToken(idToken)
        let emailFromKeychain = KeychainSwift().get("lastAppleLoginEmail")
        let resolvedEmail = emailFromCredential ?? emailFromIdToken ?? emailFromKeychain
        if let e = resolvedEmail, !e.isEmpty {
            KeychainSwift().set(e, forKey: "lastAppleLoginEmail")
        }
        
        guard let fcmToken = KeychainSwift().get("FCMToken") ?? KeychainSwift().get("fcmToken") else {
            self.onLoginFailure?("FCM Token 없음")
            return
        }

        let appleDTO = networkService.makeAppleDTO(idToken: idToken, fcmToken: fcmToken)
        networkService.appleLogin(data: appleDTO) { [weak self] result in
            switch result {
            case .success(let response):
                KeychainSwift().set(response.refreshToken, forKey: "serverRefreshToken")
                KeychainSwift().set(response.accessToken, forKey: "serverAccessToken")
                let expirationTimestamp = Int(Date().timeIntervalSince1970) + response.accessExp
                KeychainSwift().set(String(expirationTimestamp), forKey: "serverAccessTokenExp")
                KeychainSwift().set(String(response.isFirst), forKey: "isFirst")
                self?.isFirst = response.isFirst
                self?.onLoginSuccess?(response.isFirst, resolvedEmail)
                
                print("🔐 JWT accessToken:", response.accessToken)
            case .failure(let error):
                self?.onLoginFailure?("서버 로그인 실패: \(error.localizedDescription)")
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        self.onLoginFailure?("Apple 인증 실패: \(error.localizedDescription)")
    }
    
    private static func extractEmailFromIDToken(_ idToken: String) -> String? {
        let segments = idToken.split(separator: ".")
        guard segments.count >= 2 else { return nil }
        let payloadSegment = String(segments[1])
        
        var base64 = payloadSegment
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let rem = base64.count % 4
        if rem > 0 { base64.append(String(repeating: "=", count: 4 - rem)) }

        guard let data = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            return nil
        }
        if let email = json["email"] as? String, !email.isEmpty {
            return email
        }
        return nil
    }
}

extension AppleAuthVM: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first { $0.isKeyWindow } ?? UIWindow()
    }
}
