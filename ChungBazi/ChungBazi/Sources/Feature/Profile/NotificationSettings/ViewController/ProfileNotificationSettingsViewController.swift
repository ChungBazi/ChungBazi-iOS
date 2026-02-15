//
//  ProfileNotificationSettingsViewController.swift
//  ChungBazi
//
//  Created by 신호연 on 2/1/25.
//

import UIKit

final class ProfileNotificationSettingsViewController: UIViewController {
    
    private let profileNotificationSettingsView = ProfileNotificationSettingsView()
    
    private var alarmSettings: NotificationSettingModel = NotificationSettingModel(push: false, policy: false, community: false, reward: false)
    
    let networkService = NotificationService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        profileNotificationSettingsView.onToggleChanged = { [weak self] title, isOn in
            guard let self = self else { return }
            
            switch title {
            case "푸시 알림":
                self.alarmSettings.push = isOn
                self.alarmSettings.policy = isOn
                self.alarmSettings.community = isOn
                self.alarmSettings.reward = isOn
            case "장바구니 알림":
                self.alarmSettings.policy = isOn
            case "커뮤니티 알림":
                self.alarmSettings.community = isOn
            case "리워드 알림":
                self.alarmSettings.reward = isOn
            default:
                break
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        fetchAlarmSetting()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
        patchAlarmSetting(data: alarmSettings)
    }
    
    private func setupUI() {
        view.backgroundColor = .gray50
        addCustomNavigationBar(titleText: "알림 설정", showBackButton: true, showCartButton: false, showAlarmButton: false)
        view.addSubview(profileNotificationSettingsView)
        profileNotificationSettingsView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(Constants.navigationHeight)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.leading.trailing.equalToSuperview()
        }
    }
    
    private func fetchAlarmSetting() {
        self.networkService.fetchAlarmSetting() { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                let pushAlarm = [response.policyAlarm, response.communityAlarm, response.rewardAlarm].allSatisfy { $0 }
                self.alarmSettings = NotificationSettingModel(
                    push: pushAlarm,
                    policy: response.policyAlarm,
                    community: response.communityAlarm,
                    reward: response.rewardAlarm
                )
                
                DispatchQueue.main.async {
                    self.profileNotificationSettingsView.updateData(self.alarmSettings)
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func patchAlarmSetting(data: NotificationSettingModel) {
        let noticeSetting = self.networkService.makeNoticeSettingDTO(policyAlarm: data.policy, communityAlarm: data.community, rewardAlarm: data.reward, noticeAlarm: true)
        self.networkService.patchAlarmSetting(body: noticeSetting) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(_): break
            case .failure(let error):
                print(error)
            }
        }
    }
}
