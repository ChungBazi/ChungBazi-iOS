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
    private let dateLabel = B12_M(text: "date", textColor: .blue700)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubviews(dotView, policyName, dateLabel)
        dotView.tintColor = .blue700
        dotView.layer.cornerRadius = 7
        dotView.layer.masksToBounds = true
        dotView.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(25)
            $0.size.equalTo(14)
        }
        policyName.snp.makeConstraints {
            $0.top.equalToSuperview().offset(19)
            $0.leading.equalTo(dotView.snp.trailing).offset(15)
            $0.trailing.equalToSuperview().inset(17)
        }
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(policyName.snp.bottom).offset(6)
            $0.leading.trailing.equalTo(policyName)
            $0.bottom.equalToSuperview().inset(17)
        }
    }
    
    func configure(with policy: Policy) {
        policyName.text = policy.policyName
        dateLabel.text = "\(policy.startDate) ~ \(policy.endDate)"
    }
}
