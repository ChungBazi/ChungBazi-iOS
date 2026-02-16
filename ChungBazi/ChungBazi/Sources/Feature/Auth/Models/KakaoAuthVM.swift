//
//  KakaoAuthVM.swift
//  ChungBazi
//
//  Created by 이현주 on 1/31/25.
//

import UIKit
import Combine
import KakaoSDKAuth
import KakaoSDKUser

public class KakaoAuthVM: ObservableObject {
    
    public var subscriptions = Set<AnyCancellable>()

    @Published public var isLoggedIn: Bool = false
    @Published public var errorMessage: String?
    
    // 사용자 토큰 저장
    @Published public private(set) var oauthToken: String? {
        didSet {
            isLoggedIn = oauthToken != nil
        }
    }
    
    public init() {
        print("KakaoAuthVM - init() called")
    }
    
    @MainActor
    public func kakaoLogin(completion: @escaping (Bool) -> Void) {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { [weak self] (oauthToken, error) in
                if let error = error {
                    print("카카오톡 로그인 실패: \(error.localizedDescription)")
                    completion(false)
                } else if oauthToken != nil {
                    print("카카오톡 로그인 성공")
                    completion(true)
                } else {
                    completion(false)
                }
            }
        } else {
            UserApi.shared.loginWithKakaoAccount { [weak self] (oauthToken, error) in
                if let error = error {
                    print("카카오 계정 로그인 실패: \(error.localizedDescription)")
                    completion(false)
                } else if oauthToken != nil {
                    print("카카오 계정 로그인 성공")
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
    
    public func kakaoLogout(completion: @escaping (Bool) -> Void) {
        UserApi.shared.logout { [weak self] (error) in
            if let error = error {
                self?.errorMessage = "로그아웃 실패: \(error.localizedDescription)"
                completion(false)
            } else {
                self?.isLoggedIn = false
                completion(true)
            }
        }
    }
    
    //회원 탈퇴 시 unlink
    public func unlinkKakaoAccount(completion : @escaping (Bool) -> Void) {
        UserApi.shared.unlink { error in
            if let error = error {
                print("🔴 카카오 계정 연동 해제 실패: \(error.localizedDescription)")
                completion(false)
            } else {
                print("🟢 카카오 계정 연동 해제 성공")
                completion(true)
            }
        }
    }
}
