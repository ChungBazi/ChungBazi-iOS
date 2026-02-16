//
//  ProfileAppInfoView.swift
//  ChungBazi
//
//  Created by 신호연 on 2/1/25.
//

import UIKit
import SnapKit

protocol ProfileAppInfoViewDelegate: AnyObject {
    func didSelectMenuItem(title: String, content: String)
}

final class ProfileAppInfoView: UIView {
    
    weak var delegate: ProfileAppInfoViewDelegate?
    
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = menuItems[indexPath.row]
        let title: String
        let content: String
        
        switch selectedItem {
        case "서비스 이용약관":
            title = "서비스 이용약관"
            content = Constants.Policy.service
            
        case "개인정보 처리방침":
            title = "개인정보 처리방침"
            content = Constants.Policy.privacy
            
        default:
            return
        }
        
        delegate?.didSelectMenuItem(title: title, content: content)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
