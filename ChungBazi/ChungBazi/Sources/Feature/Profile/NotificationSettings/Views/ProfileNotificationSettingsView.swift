//
//  ProfileNotificationSettingsView.swift
//  ChungBazi
//
//  Created by 신호연 on 2/1/25.
//

import UIKit
import SnapKit
import Then

final class ProfileNotificationSettingsView: UIView {
    
    private let tableView = UITableView()
    var menuItems: [NotificationItem] = [
        NotificationItem(title: "푸시 알림", isOn: false)
    ]
    private var settings: NotificationSettingModel = NotificationSettingModel(push: true, policy: true, community: true, reward: true)
    
    
    // `toggle` 변경 이벤트를 뷰컨트롤러로 전달하기 위한 클로저
    var onToggleChanged: ((String, Bool) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(tableView)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        tableView.register(ProfileTableCell.self, forCellReuseIdentifier: "ProfileNotificationSettingsTableCell")
    }
    
    func updateData(_ settings: NotificationSettingModel) {
        self.settings = settings
        
        menuItems[0].isOn = settings.push
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension ProfileNotificationSettingsView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileNotificationSettingsTableCell", for: indexPath) as! ProfileTableCell
        
        let item = menuItems[indexPath.row]
        cell.configure(with: item.title, isToggle: true, isOn: item.isOn)
        cell.backgroundColor = .gray50

        cell.toggleChangedHandler = { [weak self] isOn in
            guard let self = self else { return }
            
            switch indexPath.row {
            case 0: // 푸시 알림 (전체 알림)
                self.settings.push = isOn
                self.settings.policy = isOn
                self.settings.community = isOn
                self.settings.reward = isOn

            default: break
            }
            
            self.onToggleChanged?(menuItems[indexPath.row].title, isOn)
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
