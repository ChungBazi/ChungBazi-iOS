//
//  PolicyView.swift
//  ChungBazi
//
//  Created by 엄민서 on 2/3/25.
//

import UIKit
import SnapKit
import Then

final class PolicyView: UIView {

    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
    }
    private let contentView = UIView()

    private let categoryLabel = UILabel().then {
        $0.font = .ptdMediumFont(ofSize: 14)
        $0.textAlignment = .center
        $0.backgroundColor = .blue100
        $0.textColor = .black
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
    }

    private let titleLabel = UILabel().then {
        $0.font = .ptdSemiBoldFont(ofSize: 20)
        $0.textColor = .gray800
        $0.numberOfLines = 0
    }

    private let policyInfoStack = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 16
    }

    private let detailInfoStack = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 16
    }

    private let detailSubtitleLabel = UILabel().then {
        $0.font = .ptdSemiBoldFont(ofSize: 16)
        $0.textColor = .gray800
        $0.text = "상세정보"
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubviews(categoryLabel, titleLabel, policyInfoStack, detailSubtitleLabel, detailInfoStack)

        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }

        categoryLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(8)
            make.width.equalTo(45)
            make.height.equalTo(31)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(8)
        }

        policyInfoStack.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(8)
        }

        addDivider()

        detailSubtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(policyInfoStack.snp.bottom).offset(64)
            make.leading.equalToSuperview().inset(8)
        }

        detailInfoStack.snp.makeConstraints { make in
            make.top.equalTo(detailSubtitleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().offset(-16)
        }
    }

    func configure(with policy: PolicyModel) {
        categoryLabel.text = policy.category
        let firstWord = policy.policyName.components(separatedBy: " ").first ?? ""
        titleLabel.text = "\(firstWord)<\(policy.policyName)>"
            
        addPolicyInfo(title: "정책소개", value: policy.intro)
        addPolicyInfo(title: "신청기간", value: "\(policy.startDate) ~ \(policy.endDate)")
        addPolicyInfo(title: "신청대상", value: """
        - \(policy.target.age)
        - \(policy.target.residenceIncome)
        - \(policy.target.education)
        """)
        addPolicyInfo(title: "심사결과", value: policy.result)
        addPolicyInfo(title: "참고링크", value: policy.referenceUrls.compactMap { $0 }.joined(separator: "\n"))

        addDetailInfo(title: "지원내용", value: policy.content)
        addDetailInfo(title: "신청절차", value: policy.applyProcedure)
        addDetailInfo(title: "구비서류", value: policy.document)
    }

    private func addPolicyInfo(title: String, value: String) {
        let titleLabel = UILabel().then {
            $0.text = title
            $0.font = .ptdMediumFont(ofSize: 14)
            $0.textColor = .gray500
            $0.setContentHuggingPriority(.defaultHigh, for: .horizontal) 
            $0.widthAnchor.constraint(equalToConstant: 80).isActive = true
        }

        let valueLabel = UILabel().then {
            $0.text = value
            $0.font = .ptdMediumFont(ofSize: 14)
            $0.textColor = .gray800
            $0.numberOfLines = 0
            $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        }

        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel]).then {
            $0.axis = .horizontal
            $0.alignment = .top
            $0.spacing = 8
        }
        policyInfoStack.addArrangedSubview(stack)
    }
    private func addDetailInfo(title: String, value: String) {
        let titleLabel = UILabel().then {
            $0.text = title
            $0.font = .ptdMediumFont(ofSize: 14)
            $0.textColor = .gray500
            $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            $0.widthAnchor.constraint(equalToConstant: 80).isActive = true
        }

        let valueLabel = UILabel().then {
            $0.text = value
            $0.font = .ptdMediumFont(ofSize: 14)
            $0.textColor = .gray500
            $0.numberOfLines = 0
            $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        }

        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel]).then {
            $0.axis = .horizontal
            $0.alignment = .leading
            $0.spacing = 8
        }
        detailInfoStack.addArrangedSubview(stack)
    }

    private func addDivider() {
        let divider = UIView().then {
            $0.backgroundColor = .gray50
        }
        contentView.addSubview(divider)
        divider.snp.makeConstraints { make in
            make.top.equalTo(policyInfoStack.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(8)
        }
    }
}
