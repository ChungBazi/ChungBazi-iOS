//
//  PolicyView.swift
//  ChungBazi
//
//  Created by 엄민서 on 2/3/25.
//

import UIKit
import SnapKit

class PolicyView: UIView {

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: AppFontName.pMedium, size: 14)
        label.textAlignment = .center
        label.backgroundColor = AppColor.blue100
        label.textColor = .black
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: AppFontName.pSemiBold, size: 20)
        label.textColor = AppColor.gray800
        label.numberOfLines = 0
        return label
    }()

    private let policyInfoStack = UIStackView()
    private let detailInfoStack = UIStackView()

    private let detailSubtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: AppFontName.pSemiBold, size: 16)
        label.textColor = AppColor.gray800
        label.text = "상세정보"
        return label
    }()

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

        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }

        contentView.addSubview(categoryLabel)
        categoryLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(16)
            make.width.equalTo(45)
            make.height.equalTo(31)
        }

        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        policyInfoStack.axis = .vertical
        policyInfoStack.spacing = 16
        contentView.addSubview(policyInfoStack)
        policyInfoStack.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        addDivider()

        contentView.addSubview(detailSubtitleLabel)
        detailSubtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(policyInfoStack.snp.bottom).offset(64)
            make.leading.equalToSuperview().inset(16)
        }

        detailInfoStack.axis = .vertical
        detailInfoStack.spacing = 16
        contentView.addSubview(detailInfoStack)
        detailInfoStack.snp.makeConstraints { make in
            make.top.equalTo(detailSubtitleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-16)
        }
    }

    func configure(with policy: PolicyModel) {
        categoryLabel.text = policy.category
        titleLabel.text = policy.policyName

        addPolicyInfo(title: "정책 소개", value: policy.intro)
        addPolicyInfo(title: "신청 기간", value: "\(policy.startDate) ~ \(policy.endDate)")
        addPolicyInfo(title: "신청 대상", value: """
        - \(policy.target.age)
        - \(policy.target.residenceIncome)
        - \(policy.target.education)
        """)
        addPolicyInfo(title: "심사 결과", value: policy.result)
        addPolicyInfo(title: "참고 링크", value: policy.referenceUrls.compactMap { $0 }.joined(separator: "\n"))

        addDetailInfo(title: "지원내용", value: policy.content)
        addDetailInfo(title: "신청절차", value: policy.applyProcedure)
        addDetailInfo(title: "구비서류", value: policy.document)
    }

    private func addPolicyInfo(title: String, value: String) {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont(name: AppFontName.pMedium, size: 14)
        titleLabel.textColor = AppColor.gray500

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = UIFont(name: AppFontName.pMedium, size: 14)
        valueLabel.textColor = AppColor.gray800
        valueLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stack.axis = .horizontal
        stack.alignment = .leading
        stack.spacing = 16
        policyInfoStack.addArrangedSubview(stack)
    }

    private func addDetailInfo(title: String, value: String) {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont(name: AppFontName.pMedium, size: 14)
        titleLabel.textColor = AppColor.gray500

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = UIFont(name: AppFontName.pMedium, size: 14)
        valueLabel.textColor = AppColor.gray500
        valueLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stack.axis = .horizontal
        stack.alignment = .leading
        stack.spacing = 16
        detailInfoStack.addArrangedSubview(stack)
    }

    private func addDivider() {
        let divider = UIView()
        divider.backgroundColor = AppColor.gray50
        contentView.addSubview(divider)
        divider.snp.makeConstraints { make in
            make.top.equalTo(policyInfoStack.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(8)
        }
    }
}
