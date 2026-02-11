//
//  AmplitudeManager.swift
//  ChungBazi
//
//  Created by 이현주 on 2/10/26.
//

import Foundation
import AmplitudeSwift

final class AmplitudeManager {
    static let shared = AmplitudeManager()
    
    private var amplitude: Amplitude?
    
    private init() {}
    
    func initialize(apiKey: String) {
        amplitude = Amplitude(configuration: .init(apiKey: apiKey))
    }
    
    // MARK: - User Management
    func setUserId(_ userId: String?) {
        amplitude?.setUserId(userId: userId)
    }
    
    func setUserProperties(_ properties: [String: Any]) {
        let identify = Identify()
        properties.forEach { key, value in
            if let stringValue = value as? String {
                identify.set(property: key, value: stringValue)
            } else if let intValue = value as? Int {
                identify.set(property: key, value: intValue)
            } else if let doubleValue = value as? Double {
                identify.set(property: key, value: doubleValue)
            } else if let boolValue = value as? Bool {
                identify.set(property: key, value: boolValue)
            }
        }
        amplitude?.identify(identify: identify)
    }
    
    // MARK: - Event Tracking
    private func track(eventName: String, properties: [String: Any]? = nil) {
        amplitude?.track(eventType: eventName, eventProperties: properties)
    }
}

// MARK: - 1. 정책 탐색 퍼널 이벤트
extension AmplitudeManager {
    func trackAppOpen() {
        track(eventName: "app_open")
    }
    
    func trackHomeView() {
        track(eventName: "home_view")
    }
    
    func trackPolicyListView(entryPoint: String) {
        track(eventName: "policy_list_view", properties: [
            "entry_point": entryPoint
        ])
    }
    
    func trackPolicyDetailView(
        policyId: Int,
        policyName: String,
        policyCategory: String,
        entryPoint: String
    ) {
        track(eventName: "policy_detail_view", properties: [
            "policy_id": policyId,
            "policy_name": policyName,
            "policy_category": policyCategory,
            "entry_point": entryPoint
        ])
    }
    
    func trackApplyClick(policyId: String, policyName: String) {
        track(eventName: "apply_click", properties: [
            "policy_id": policyId,
            "policy_name": policyName
        ])
    }
    
    func trackExternalApplyLinkOpen(policyId: String, externalUrl: [String]) {
        track(eventName: "external_apply_link_open", properties: [
            "policy_id": policyId,
            "external_url": externalUrl
        ])
    }
}

// MARK: - 2. 검색 / 필터 이벤트
extension AmplitudeManager {
    func trackFilterApply(
        filterType: String?,
        filterValue: String
    ) {
        track(eventName: "filter_apply", properties: [
            "filter_type": filterType ?? "",
            "filter_value": filterValue
        ])
    }
}

// MARK: - 3. 정책 상세 행동 이벤트
extension AmplitudeManager {
    func trackScrollDepth(policyId: String, depth: Int) {
        track(eventName: "scroll_depth", properties: [
            "policy_id": policyId,
            "depth": depth
        ])
    }
    
    func trackBackClick(
        policyId: String,
        scrollDepth: Int
    ) {
        track(eventName: "back_click", properties: [
            "policy_id": policyId,
            "scroll_depth": scrollDepth
        ])
    }
}

// MARK: - 4. 챗봇 이벤트
extension AmplitudeManager {
    func trackChatbotOpen(sessionId: String) {
        track(eventName: "chatbot_open", properties: [
            "session_id": sessionId
        ])
    }
    
    func trackChatbotMessageSend(
        messageContent: String,
        sessionId: String,
        messageOrder: Int
    ) {
        track(eventName: "chatbot_message_send", properties: [
            "message_content": messageContent,
            "session_id": sessionId,
            "message_order": messageOrder
        ])
    }
    
    func trackChatbotSessionEnd(
        sessionId: String,
        messageCount: Int,
        lastAction: String
    ) {
        track(eventName: "chatbot_session_end", properties: [
            "session_id": sessionId,
            "message_count": messageCount,
            "last_action": lastAction
        ])
    }
}

// MARK: - 5. 이탈 이벤트
extension AmplitudeManager {
    func trackAppExit(lastScreen: String) {
        track(eventName: "app_exit", properties: [
            "last_screen": lastScreen
        ])
    }
}
