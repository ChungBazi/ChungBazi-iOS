//
//  CalendarPolicyListView.swift
//  ChungBazi
//
//  Created by 신호연 on 1/23/25.
//

import UIKit
import SnapKit
import Then

protocol CalendarPolicyListViewDelegate: AnyObject {
    func presentCalendarDetailViewController(for policy: Policy)
}

final class CalendarPolicyListView: UIView {
    
    weak var delegate: CalendarPolicyListViewDelegate?
    private var selectedDate: String = ""
    
    private let titleLabel = T20_SB(text: "나의 정책")
    private let tableView = UITableView()
    private var policies: [Policy] = []
    
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
        addSubviews(titleLabel, tableView)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(41)
            $0.centerX.equalToSuperview()
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(26)
            $0.leading.trailing.bottom.equalToSuperview().inset(12)
        }
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 12, right: 0)
        tableView.register(CalendarPolicyListCell.self, forCellReuseIdentifier: "CalendarPolicyListCell")
    }
    
    func updateView(with date: String, policies: [Policy]) {
        self.selectedDate = date
        self.policies = policies
        
        guard let dateObject = DateFormatter.yearMonthDay.date(from: date) else {
            print("🚨 잘못된 날짜 형식: \(date)")
            return
        }

        self.policies = policies.filter {
            guard let start = DateFormatter.yearMonthDay.date(from: $0.startDate),
                  let end = DateFormatter.yearMonthDay.date(from: $0.endDate) else {
                print("🚨 날짜 변환 실패 - 정책: \($0.policyName)")
                return false
            }
            return start == dateObject || end == dateObject
        }

        let monthDayDate = DateFormatter.monthDay.string(from: dateObject)
        titleLabel.text = "\(monthDayDate) 나의 정책"
        tableView.reloadData()
    }
}

extension CalendarPolicyListView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPolicy = policies[indexPath.row]
        delegate?.presentCalendarDetailViewController(for: selectedPolicy)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarPolicyListCell", for: indexPath) as? CalendarPolicyListCell else {
            return UITableViewCell()
        }
        let policy = policies[indexPath.row]
        cell.configure(with: policy, isStart: policy.startDate == selectedDate)
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return policies.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = .clear
        return footerView
    }
}
