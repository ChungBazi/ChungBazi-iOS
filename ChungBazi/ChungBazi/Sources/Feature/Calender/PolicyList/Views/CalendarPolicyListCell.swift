//
//  CalendarPolicyListCell.swift
//  ChungBazi
//
//  Created by 신호연 on 1/23/25.
//

import UIKit
import SnapKit
import Then

final class CalendarPolicyListCell: UITableViewCell {
    
    private let dotView = UIView()
    private let policyName = B16_M(text: "policyName", textColor: .black)
    private let dateLabel = B14_M(text: "date", textColor: .blue700)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        addSubviews(dotView, policyName, dateLabel)
        layer.cornerRadius = 10
        
        dotView.layer.cornerRadius = 6
        dotView.layer.masksToBounds = true
        dotView.backgroundColor = .blue700
        dotView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(24)
            $0.size.equalTo(12)
        }
        policyName.snp.makeConstraints {
            $0.top.equalToSuperview().offset(18)
            $0.leading.equalTo(dotView.snp.trailing).offset(22)
            $0.trailing.equalToSuperview().inset(18)
        }
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(policyName.snp.bottom).offset(6)
            $0.leading.trailing.equalTo(policyName)
            $0.bottom.equalToSuperview().inset(18)
        }
    }
    
    func configure(with policy: Policy, isStart: Bool) {
        if isStart {
            backgroundColor = .white
            layer.borderColor = UIColor.gray400.cgColor
            layer.borderWidth = 1
            
            dotView.layer.cornerRadius = 6
            dotView.layer.borderWidth = 2
            dotView.layer.borderColor = UIColor.blue700.cgColor
            dotView.backgroundColor = .clear
        } else {
            backgroundColor = .blue100
            layer.borderWidth = 0
            
            dotView.layer.cornerRadius = 6
            dotView.backgroundColor = .blue700
        }

        if let startDate = DateFormatter.yearMonthDay.date(from: policy.startDate),
           let endDate = DateFormatter.yearMonthDay.date(from: policy.endDate) {
            dateLabel.text = "\(DateFormatter.yearMonthDayDot.string(from: startDate)) - \(DateFormatter.yearMonthDayDot.string(from: endDate))"
        } else {
            print("🚨 날짜 변환 실패: \(policy.policyName)")
            return
        }
        policyName.text = policy.policyName
    }
}
