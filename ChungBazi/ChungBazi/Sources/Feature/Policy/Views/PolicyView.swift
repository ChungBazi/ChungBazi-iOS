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

    private let contentView = UIView()

    private let categoryLabel = PaddedLabel().then {
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
        addSubview(contentView)
        contentView.addSubviews(categoryLabel, titleLabel, policyInfoStack, detailSubtitleLabel, detailInfoStack)

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        categoryLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(20)
            make.height.equalTo(31)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        policyInfoStack.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        addDivider()

        detailSubtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(policyInfoStack.snp.bottom).offset(64)
            make.leading.equalToSuperview().inset(20)
        }

        detailInfoStack.snp.makeConstraints { make in
            make.top.equalTo(detailSubtitleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
    
    func configure(with policy: PolicyModel, target: PolicyTarget) {
        categoryLabel.text = policy.categoryName
        titleLabel.text = policy.name
        
        addPolicyInfo(title: "정책소개", value: policy.intro.nilIfBlank ?? "정보 없음")
        addPolicyInfo(title: "신청기간", value: formatDateRange(start: policy.startDate, end: policy.endDate))
        addPolicyInfo(title: "신청대상", value: formatTargetInfo(target))
        addPolicyInfo(title: "심사결과", value: policy.result?.nilIfBlank ?? "-")
        
        let urls = URLHelper.normalizedUrls(from: policy)
        if urls.isEmpty {
            addPolicyInfo(title: "참고링크", value: "참고링크 없음")
        } else {
            addPolicyInfoLinks(title: "참고링크", urls: urls)
        }
        
        addDetailInfo(title: "지원내용", value: policy.content.nilIfBlank ?? "정보 없음")
        addDetailInfo(title: "신청절차", value: policy.applyProcedure?.nilIfBlank ?? "-")
        addDetailInfo(title: "구비서류", value: policy.document?.nilIfBlank ?? "-")
    }
    
    private func formatDateRange(start: String?, end: String?) -> String {
        let formattedStart = formatDate(start)
        let formattedEnd = formatDate(end)
        return "\(formattedStart) ~ \(formattedEnd)"
    }
    
    private func formatDate(_ dateString: String?) -> String {
        guard let dateString = dateString else { return "기간 정보 없음" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "yyyy년 M월 d일"
            return formatter.string(from: date)
        }
        return "기간 정보 없음"
    }
    
    private func formatTargetInfo(_ target: PolicyTarget) -> String {
        let ageInfo = formatAge(min: target.minAge, max: target.maxAge)
        let incomeInfo = target.minIncome != nil ? "소득 기준: \(target.minIncome!) 이상" : "소득 정보 없음"
        let additionCondition = target.additionCondition ?? "추가 신청 자격 없음"
        let restrictionCondition = target.restrictionCondition ?? "참여 제한 대상 없음"
        
        return """
        - \(ageInfo)
        - \(incomeInfo)
        - 추가 자격: \(additionCondition)
        - 제한 대상: \(restrictionCondition)
        """
    }
    
    private func formatAge(min: String?, max: String?) -> String {
        if let min = min, let max = max {
            return "연령: \(min)세 이상 \(max)세 미만"
        } else if let min = min {
            return "연령: \(min)세 이상"
        } else if let max = max {
            return "연령: \(max)세 미만"
        } else {
            return "연령 정보 없음"
        }
    }
    
    private func addPolicyInfoLinks(title: String, urls: [String]) {
        let titleLabel = UILabel().then {
            $0.text = title
            $0.font = .ptdMediumFont(ofSize: 14)
            $0.textColor = .gray500
            $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            $0.widthAnchor.constraint(equalToConstant: 80).isActive = true
        }

        let valueTextView = UITextView().then {
            $0.isEditable = false
            $0.isSelectable = true
            $0.isScrollEnabled = false
            $0.backgroundColor = .clear
            $0.textContainerInset = .zero
            $0.textContainer.lineFragmentPadding = 0
            $0.tintColor = .blue700
            $0.linkTextAttributes = [
                .foregroundColor: UIColor.blue700,
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]
            $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
        }

        let attributed = NSMutableAttributedString()
        for (idx, urlString) in urls.enumerated() {
            let line = NSMutableAttributedString(string: urlString, attributes: [
                .font: UIFont.ptdMediumFont(ofSize: 14),
                .foregroundColor: UIColor.blue700,
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .link: urlString
            ])
            attributed.append(line)
            if idx < urls.count - 1 { attributed.append(NSAttributedString(string: "\n")) }
        }
        valueTextView.attributedText = attributed

        let stack = UIStackView(arrangedSubviews: [titleLabel, valueTextView]).then {
            $0.axis = .horizontal
            $0.alignment = .top
            $0.spacing = 8
        }
        policyInfoStack.addArrangedSubview(stack)
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
            $0.attributedText = setParagraphSpacing(value)
        }

        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel]).then {
            $0.axis = .horizontal
            $0.alignment = .firstBaseline
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

    private func setParagraphSpacing(_ text: String) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.4
        return NSAttributedString(string: text, attributes: [.paragraphStyle: paragraphStyle])
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
