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
    
    var onLoginSuccess: ((Bool) -> Void)?
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

        guard let fcmToken = KeychainSwift().get("FCMToken") else {
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
                self?.onLoginSuccess?(response.isFirst)
                
                
                print("🔐 JWT accessToken:", response.accessToken)
            case .failure(let error):
                self?.onLoginFailure?("서버 로그인 실패: \(error.localizedDescription)")
            }
        }
    }
}

extension AppleAuthVM: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first { $0.isKeyWindow } ?? UIWindow()
    }
}
