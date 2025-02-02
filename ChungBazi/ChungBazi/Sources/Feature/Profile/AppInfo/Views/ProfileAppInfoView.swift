//
//  ProfileAppInfoView.swift
//  ChungBazi
//
//  Created by 신호연 on 2/1/25.
//

import UIKit
import SnapKit

final class ProfileAppInfoView: UIView {
    
    private let tableView = UITableView()
    private let menuItems = ["서비스 이용약관", "개인정보 처리방침"]
    
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
        tableView.register(ProfileTableCell.self, forCellReuseIdentifier: "ProfileAppInfoTableCell")
    }
}

extension ProfileAppInfoView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileAppInfoTableCell", for: indexPath) as! ProfileTableCell
        cell.configure(with: menuItems[indexPath.row])
        cell.backgroundColor = .gray50
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
