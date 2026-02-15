//
//  Config.swift
//  ChungBazi
//
//  Created by 이현주 on 2/10/26.
//

import Foundation

enum Config {
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Plist 없음")
        }
        return dict
    }()
    
    static let apiBaseURL: String = {
        guard let apiBaseURL = infoDictionary["API_BASE_URL"] as? String else {
            fatalError()
        }
        return apiBaseURL
    }()
    
    static let amplitudeKey: String = {
        guard let amplitudeKey = infoDictionary["AMPLITUDE_KEY"] as? String else {
            fatalError()
        }
        return amplitudeKey
    }()
    
    static let kakaoNativeKey: String = {
        guard let kakaoNativeKey = infoDictionary["KAKAO_NATIVE_APP_KEY"] as? String else {
            fatalError()
        }
        return kakaoNativeKey
    }()
    
    static let appStoreURL: String = {
        guard let appStoreURL = infoDictionary["APPSTORE_URL"] as? String else {
            fatalError()
        }
        return appStoreURL
    }()
    
    static let contactFormURL: String = {
        guard let contactFormURL = infoDictionary["CONTACT_FORM_URL"] as? String else {
            fatalError()
        }
        return contactFormURL
    }()
}
