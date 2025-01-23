//
//  CalendarPolicyListView.swift
//  ChungBazi
//
//  Created by 신호연 on 1/23/25.
//

import UIKit
import SnapKit
import Then

final class CalendarPolicyListView: UIView {
    
    private let titleLabel = T20_SB(text: "나의 정책")
    private let tableView = UITableView().then {
        $0.separatorInset = UIEdgeInsets(top: 0, left: Constants.gutter, bottom: 0, right: Constants.gutter)
        $0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 12, right: 0)
    }
    private var policies: [Policy] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubviews(titleLabel, tableView)
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(36)
            $0.centerX.equalToSuperview()
        }
        tableView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        tableView.register(CalendarPolicyListCell.self, forCellReuseIdentifier: "PolicyCell")
        tableView.delegate = self
    }
    
    func updateView(with date: String, policies: [Policy]) {
        self.policies = policies
        titleLabel.text = "\(date) 나의 정책"
        tableView.reloadData()
    }
}

extension CalendarPolicyListView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 81
    }
}

extension CalendarPolicyListView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return policies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PolicyCell", for: indexPath) as? CalendarPolicyListCell else {
            return UITableViewCell()
        }
        let policy = policies[indexPath.row]
        cell.configure(with: policy)
        return cell
    }
}
