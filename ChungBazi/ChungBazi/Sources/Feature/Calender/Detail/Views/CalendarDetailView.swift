//
//  CalendarDetailView.swift
//  ChungBazi
//
//  Created by 신호연 on 1/20/25.
//

import UIKit
import SnapKit
import Then

final class CalendarDetailView: UIView {
    
    // MARK: - Properties
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let policyInfoView = UIView()
    private let characterImage = UIImageView(image: .character06)
    private let policyName = T20_M(text: "", textColor: .black)
    private let startText = B12_M(text: "시작일", textColor: .gray500)
    private let startDate = B12_M(text: "", textColor: .black)
    private let endText = B12_M(text: "마감일", textColor: .gray500)
    private let endDate = B12_M(text: "", textColor: .black)
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.edges.width.equalToSuperview()
        }
        
        setupPolicyInfo()
    }
    
    private func setupPolicyInfo() {
        contentView.addSubview(policyInfoView)
        policyInfoView.addSubviews(characterImage, policyName, startText, startDate, endText, endDate)
        policyInfoView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(30)
            $0.leading.trailing.equalToSuperview().inset(Constants.gutter)
        }
        characterImage.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.size.equalTo(112)
        }
        policyName.snp.makeConstraints {
            $0.top.equalToSuperview().offset(17)
            $0.leading.equalTo(characterImage.snp.trailing).offset(7)
            $0.height.equalTo(28)
        }
        startText.snp.makeConstraints {
            $0.top.equalTo(policyName.snp.bottom).offset(14)
            $0.leading.equalTo(policyName)
        }
        startDate.snp.makeConstraints {
            $0.top.equalTo(startText)
            $0.leading.equalTo(startText.snp.trailing).offset(29)
        }
        endText.snp.makeConstraints {
            $0.top.equalTo(startText.snp.bottom).offset(2)
            $0.leading.equalTo(policyName)
        }
        endDate.snp.makeConstraints {
            $0.top.equalTo(endText)
            $0.leading.equalTo(startText.snp.trailing).offset(29)
        }
    }
    
    // MARK: - Actions
    
    
    // MARK: - Public Methods
    func update(policy: Policy) {
        updatePolicyInfo(with: policy)
    }

    private func updatePolicyInfo(with policy: Policy) {
        policyName.text = policy.policyName
        startDate.text = policy.startDate
        endDate.text = policy.endDate
    }
    
}
