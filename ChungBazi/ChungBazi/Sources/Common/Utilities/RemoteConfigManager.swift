//
//  RemoteConfigManager.swift
//  ChungBazi
//
//  Created by 이현주 on 2/16/26.
//

import Foundation
import FirebaseRemoteConfig

final class RemoteConfigManager {
    
    // MARK: - Singleton
    static let shared = RemoteConfigManager()
    
    // MARK: - Properties
    private let remoteConfig: RemoteConfig
    
    // MARK: - RemoteConfig Keys
    enum ConfigKey: String {
        case isServerCheck = "is_server_check"
        case minimumVersion = "minimum_version"
        case serverCheckMessage = "server_check_message"
    }
    
    // MARK: - Init
    private init() {
        remoteConfig = RemoteConfig.remoteConfig()
        
        // RemoteConfig 설정
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        
        // 기본값 설정
        setDefaultValues()
    }
    
    // MARK: - Default Values
    private func setDefaultValues() {
        let defaults: [String: Any] = [
            ConfigKey.isServerCheck.rawValue: false,
            ConfigKey.minimumVersion.rawValue: "1.0.0",
            ConfigKey.serverCheckMessage.rawValue: "현재 서버 점검 중이에요.\n잠시 후 다시 이용해주세요."
        ]
        remoteConfig.setDefaults(defaults as! [String : NSObject] as [String: NSObject])
    }
    
    // MARK: - Fetch Config
    func fetchConfig(completion: @escaping (Bool) -> Void) {
        remoteConfig.fetch { [weak self] status, error in
            guard let self = self else {
                completion(false)
                return
            }
            
            if status == .success {
                self.remoteConfig.activate { _, error in
                    if let error = error {
                        completion(false)
                    } else {
                        completion(true)
                    }
                }
            } else {
                completion(false)
            }
        }
    }
    
    // MARK: - Get Config Values
    
    /// 서버 점검 여부 확인
    func isServerCheck() -> Bool {
        return remoteConfig.configValue(forKey: ConfigKey.isServerCheck.rawValue).boolValue
    }
    
    /// 최소 지원 버전 가져오기
    func getMinimumVersion() -> String {
        return remoteConfig.configValue(forKey: ConfigKey.minimumVersion.rawValue).stringValue
    }
    
    /// 서버 점검 메시지 가져오기
    func getServerCheckMessage() -> String {
        let raw = remoteConfig
            .configValue(forKey: ConfigKey.serverCheckMessage.rawValue)
            .stringValue

        let formatted = raw.replacingOccurrences(of: "\\n", with: "\n")

        return formatted
    }
    
    // MARK: - Version Check
    
    /// 앱 버전이 최소 지원 버전보다 낮은지 확인
    func isUpdateRequired() -> Bool {
        guard let appVersion = getCurrentAppVersion() else {
            return false
        }
        
        let minimumVersion = getMinimumVersion()
        return compareVersions(appVersion, minimumVersion) == .orderedAscending
    }
    
    /// 현재 앱 버전 가져오기
    private func getCurrentAppVersion() -> String? {
        guard let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return nil
        }
        return appVersion
    }
    
    /// 버전 비교
    private func compareVersions(_ version1: String, _ version2: String) -> ComparisonResult {
        let v1Components = version1.split(separator: ".").compactMap { Int($0) }
        let v2Components = version2.split(separator: ".").compactMap { Int($0) }
        
        let maxLength = max(v1Components.count, v2Components.count)
        
        for i in 0..<maxLength {
            let v1Value = i < v1Components.count ? v1Components[i] : 0
            let v2Value = i < v2Components.count ? v2Components[i] : 0
            
            if v1Value < v2Value {
                return .orderedAscending
            } else if v1Value > v2Value {
                return .orderedDescending
            }
        }
        
        return .orderedSame
    }
}











