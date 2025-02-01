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
    private let menuItems = ["푸시 알림", "장바구니 알림", "커뮤니티 알림", "리워드 알림"]
    
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
}

extension ProfileNotificationSettingsView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileNotificationSettingsTableCell", for: indexPath) as! ProfileTableCell
        
        let title = menuItems[indexPath.row]
        cell.configure(with: title, isToggle: true)
        cell.backgroundColor = .gray50

        cell.toggleChangedHandler = { [weak self] isOn in
            guard let self = self else { return }
            print("\(title) 설정 변경됨: \(isOn)")
            
            if indexPath.row == 0 {
                for i in 1..<self.menuItems.count {
                    if let otherCell = tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? ProfileTableCell {
                        otherCell.setToggleState(isOn)
                    }
                }
            }
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
