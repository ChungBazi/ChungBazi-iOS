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
    var accessibleContentView: UIView {
        return contentView
    }
    
    private let policyInfoView = UIView()
    var accessiblePolicyInfoView: UIView {
        return policyInfoView
    }
    
    private let dDayPocketContainerView = UIView()
    private let dDayPocketImage = UIImageView()
    private let dDayPocketText = BTN14_SB(text: "")
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
            $0.leading.trailing.equalToSuperview()
        }
        
        policyInfoView.addSubviews(dDayPocketContainerView, policyInfoTextView)
        
        dDayPocketContainerView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(30)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(52)
            $0.height.equalTo(60)
        }
        
        dDayPocketContainerView.addSubviews(dDayPocketImage, dDayPocketText)
        
        dDayPocketImage.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        dDayPocketText.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        policyInfoTextView.snp.makeConstraints {
            $0.leading.equalTo(dDayPocketContainerView.snp.trailing).offset(28)
            $0.trailing.equalToSuperview().inset(34)
            $0.centerY.equalTo(dDayPocketContainerView)
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
            $0.leading.equalTo(startText.snp.trailing).offset(16)
            $0.centerY.equalTo(startText)
        }
        endText.snp.makeConstraints {
            $0.top.equalTo(startText.snp.bottom).offset(1)
            $0.leading.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        endDate.snp.makeConstraints {
            $0.leading.equalTo(endText.snp.trailing).offset(16)
            $0.centerY.equalTo(endText)
        }
        
        policyInfoView.snp.makeConstraints {
            $0.bottom.equalTo(policyInfoTextView.snp.bottom).priority(.high)
            $0.bottom.equalTo(dDayPocketContainerView.snp.bottom).priority(.high)
        }
    }
    
    // MARK: - Public Methods
    func update(policy: Policy) {
        policyName.text = policy.policyName.isEmpty ? "정책명 없음" : policy.policyName
        startDate.text = policy.startDate.isEmpty ? "N/A" : policy.startDate
        endDate.text = policy.endDate.isEmpty ? "N/A" : policy.endDate
        
        if let end = DateFormatter.convertToDate(policy.endDate) {
            let today = Date()
            let daysLeft = Calendar.current.dateComponents([.day], from: today, to: end).day ?? 0
            updateDDay(daysLeft: daysLeft)
        } else {
            print("❌ 날짜 변환 실패: updateDDay 호출 안됨")
        }
    }
    
    func updateDDay(daysLeft: Int) {
        let dDayStyle = DDayStyle.determineStyle(from: daysLeft)
        let imageName = dDayStyle.assetName
        dDayPocketImage.image = UIImage(named: imageName) ?? UIImage(named: "default_d_day_image")
        
        if dDayPocketImage.image == nil {
            print("Error: Image \(imageName) not found. Using default image.")
        }
        
        dDayPocketText.textColor = dDayStyle.textColor
        dDayPocketText.text = dDayStyle.displayText.isEmpty ? "D-\(daysLeft)" : dDayStyle.displayText
        
        setNeedsLayout()
        layoutIfNeeded()
    }
}
