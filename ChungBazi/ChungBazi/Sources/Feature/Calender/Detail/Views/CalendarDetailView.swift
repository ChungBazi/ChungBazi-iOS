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
    var accessibleContentView: UIView{
        return contentView
    }
    
    private let policyInfoView = UIView()
    var accessiblePolicyInfoView: UIView {
        return policyInfoView
    }
    private let characterImage = UIImageView(image: .glassBaro)
    private let policyInfoTextView = UIView()
    private let policyName: UILabel = {
        let label = UILabel.createLabel(
            text: "",
            textColor: .black,
            fontSize: 20,
            lineHeightMultiple: 1.4
        )
        return label
    }()
    private let startText = B14_M(text: "시작일", textColor: .gray500)
    private let startDate = B14_M(text: "", textColor: .black)
    private let endText = B14_M(text: "마감일", textColor: .gray500)
    private let endDate = B14_M(text: "", textColor: .black)
    
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
        
        setupPolicyInfoView()
    }
    
    private func setupPolicyInfoView() {
        contentView.addSubview(policyInfoView)
        policyInfoView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(52)
            $0.leading.trailing.equalToSuperview().inset(Constants.gutter)
        }
        
        policyInfoView.addSubviews(characterImage, policyInfoTextView)
        characterImage.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.size.equalTo(112)
        }
        policyInfoTextView.snp.makeConstraints {
            $0.leading.equalTo(characterImage.snp.trailing).offset(7)
            $0.trailing.equalToSuperview()
            $0.centerY.equalTo(characterImage)
        }
        
        policyInfoTextView.addSubviews(policyName, startText, startDate, endText, endDate)
        policyName.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        startText.snp.makeConstraints {
            $0.top.equalTo(policyName.snp.bottom).offset(14)
            $0.leading.equalToSuperview()
        }
        startDate.snp.makeConstraints {
            $0.leading.equalTo(startText.snp.trailing).offset(29)
            $0.centerY.equalTo(startText)
        }
        endText.snp.makeConstraints {
            $0.top.equalTo(startText.snp.bottom).offset(2)
            $0.leading.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        endDate.snp.makeConstraints {
            $0.leading.equalTo(endText.snp.trailing).offset(29)
            $0.centerY.equalTo(endText)
        }
        
        policyInfoView.snp.makeConstraints {
            $0.bottom.greaterThanOrEqualTo(characterImage.snp.bottom)
            $0.bottom.greaterThanOrEqualTo(policyInfoTextView.snp.bottom)
        }
    }
    
    // MARK: - Actions
    
    
    // MARK: - Public Methods
    func update(policy: Policy) {
        policyName.text = policy.policyName.isEmpty ? "정책명 없음" : policy.policyName
        startDate.text = policy.startDate.isEmpty ? "N/A" : policy.startDate
        endDate.text = policy.endDate.isEmpty ? "N/A" : policy.endDate
    }
    
}
