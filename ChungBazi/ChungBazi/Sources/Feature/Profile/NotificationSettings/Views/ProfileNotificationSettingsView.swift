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
        NotificationItem(title: "푸시 알림", isOn: false),
        NotificationItem(title: "장바구니 알림", isOn: false),
        NotificationItem(title: "커뮤니티 알림", isOn: false),
        NotificationItem(title: "리워드 알림", isOn: false)
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
        menuItems[1].isOn = settings.policy
        menuItems[2].isOn = settings.community
        menuItems[3].isOn = settings.reward
        
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
                // 모든 알림을 다 변경
                for i in 1..<self.menuItems.count {
                    self.menuItems[i].isOn = isOn
                    if let otherCell = tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? ProfileTableCell {
                        otherCell.setToggleState(isOn)
                    }
                }
            case 1: self.settings.policy = isOn
            case 2: self.settings.community = isOn
            case 3: self.settings.reward = isOn
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
