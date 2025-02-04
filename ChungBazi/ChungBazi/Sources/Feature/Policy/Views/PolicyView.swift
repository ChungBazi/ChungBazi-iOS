//
//  PolicyView.swift
//  ChungBazi
//
//  Created by 엄민서 on 2/3/25.
//

import UIKit
import SnapKit

class PolicyView: UIView {
    private let categoryLabel = UILabel()
    private let titleLabel = UILabel()
    private let introLabel = UILabel()
    private let detailsStackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        categoryLabel.font = UIFont(name: AppFontName.pMedium, size: 14)
        categoryLabel.textAlignment = .center
        categoryLabel.backgroundColor = AppColor.blue100
        categoryLabel.textColor = .black
        categoryLabel.layer.cornerRadius = 10
        categoryLabel.clipsToBounds = true
        addSubview(categoryLabel)

        titleLabel.font = UIFont(name: AppFontName.pSemiBold, size: 20)
        titleLabel.numberOfLines = 0
        addSubview(titleLabel)

        introLabel.font = UIFont(name: AppFontName.pMedium, size: 14)
        introLabel.textColor = .gray500
        introLabel.numberOfLines = 0
        addSubview(introLabel)

        detailsStackView.axis = .vertical
        detailsStackView.spacing = 8
        addSubview(detailsStackView)

        categoryLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(16)
            make.width.equalTo(45)
            make.height.equalTo(31)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        introLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        detailsStackView.snp.makeConstraints { make in
            make.top.equalTo(introLabel.snp.bottom).offset(16)
            make.leading.trailing.bottom.equalToSuperview().inset(16)
        }
    }

    func configure(with policy: PolicyModel) {
        categoryLabel.text = policy.category
        titleLabel.text = policy.policyName
        introLabel.text = "정책 소개: \(policy.intro)"
        detailsStackView.addArrangedSubview(createDetailLabel(title: "신청 기간", value: "\(policy.startDate) ~ \(policy.endDate)"))
        detailsStackView.addArrangedSubview(createDetailLabel(title: "신청 대상", value: "\(policy.target.age), \(policy.target.residenceIncome), \(policy.target.education)"))
        detailsStackView.addArrangedSubview(createDetailLabel(title: "구비 서류", value: policy.document))
        detailsStackView.addArrangedSubview(createDetailLabel(title: "신청 절차", value: policy.applyProcedure))
        detailsStackView.addArrangedSubview(createDetailLabel(title: "결과 발표", value: policy.result))
    }

    private func createDetailLabel(title: String, value: String) -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkGray
        label.numberOfLines = 0
        label.text = "\(title): \(value)"
        return label
    }
}
