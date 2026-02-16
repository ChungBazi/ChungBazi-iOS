//
//  PolicyCardViewCell.swift
//  ChungBazi
//
//  Created by 엄민서 on 1/24/25.
//

import UIKit
import SnapKit

final class PolicyCardViewCell: UITableViewCell {
    static let identifier = "PolicyCardViewCell"

    var selectionHandler: ((Bool) -> Void)?
    var deleteHandler: (() -> Void)?

    var showControls: Bool = false {
        didSet {
            checkBoxButton.isHidden = !showControls

            containerView.snp.updateConstraints { make in
                make.height.equalTo(showControls ? 131 : 94)
            }

            badgeImageView.snp.updateConstraints { make in
                make.top.equalToSuperview().offset(showControls ? 46 : 16)
            }
        }
    }

    private let checkBoxButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(resource: .checkboxUnchecked), for: .normal)
        button.setImage(UIImage(resource: .checkboxChecked), for: .selected)
        button.isHidden = true
        return button
    }()
    
    private let badgeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let badgeTextLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: AppFontName.pSemiBold, size: 14)
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: AppFontName.pSemiBold, size: 16)
        label.textColor = .black
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
        return label
    }()

    private let periodLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: AppFontName.pMedium, size: 14)
        label.textColor = AppColor.gray400
        return label
    }()

    private let textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .leading
        return stackView
    }()

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        setupLayout()
        configureActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        contentView.addSubview(containerView)
        containerView.addSubviews(checkBoxButton, badgeImageView, badgeTextLabel, textStackView)

        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(periodLabel)
        
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview().inset(6.5)
            make.height.equalTo(showControls ? 131 : 94)
        }
        
        checkBoxButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(8)
            make.width.height.equalTo(24)
        }
        
        badgeImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(17)
            make.top.equalToSuperview().offset(18)
            make.width.equalTo(52)
            make.height.equalTo(60)
        }

        badgeTextLabel.snp.makeConstraints { make in
            make.center.equalTo(badgeImageView)
        }

        textStackView.snp.makeConstraints { make in
            make.leading.equalTo(badgeImageView.snp.trailing).offset(17)
            make.trailing.equalToSuperview().inset(17)
            make.centerY.equalTo(badgeImageView)
        }
    }
    
    private func configureActions() {
        checkBoxButton.addTarget(self, action: #selector(handleCheckBoxTap), for: .touchUpInside)
    }

    @objc private func handleCheckBoxTap() {
        checkBoxButton.isSelected.toggle()
        selectionHandler?(checkBoxButton.isSelected)
    }

    func setCheckBoxState(isSelected: Bool) {
        checkBoxButton.isSelected = isSelected
    }

    func configure(with item: PolicyItem, keyword: String?) {
        titleLabel.text = item.policyName
        
        let formattedPeriod = formatPeriod(startDate: item.startDate, endDate: item.endDate)
        periodLabel.text = formattedPeriod

        let badgeText = {
            if !item.startDate.isEmpty && item.startDate != "상시" {
                if let startDate = DateFormatter.yearMonthDay.date(from: item.startDate) {
                    let today = Calendar.current.startOfDay(for: Date())
                    let start = Calendar.current.startOfDay(for: startDate)
                    
                    if start > today {
                        return "예정"
                    }
                }
            }
            
            guard let dday = item.dday else { return "상시" }
            
            if dday > 999 {
                return "상시"
            } else if dday < 0 {
                return "마감"
            } else {
                return "D-\(dday)"
            }
        }()
        
        badgeTextLabel.text = badgeText
        badgeTextLabel.textColor = badgeTextColor(for: badgeText)
        badgeImageView.image = badgeImage(for: badgeText)
        
        if let keyword = keyword, !keyword.isEmpty {
            let attributedText = NSMutableAttributedString(string: item.policyName)
            if let range = item.policyName.range(of: keyword) {
                let nsRange = NSRange(range, in: item.policyName)
                attributedText.addAttribute(.foregroundColor, value: AppColor.blue700!, range: nsRange)
            }
            titleLabel.attributedText = attributedText
        }
    }

    private func formatPeriod(startDate: String, endDate: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy.MM.dd"

        if let start = inputFormatter.date(from: startDate),
           let end = inputFormatter.date(from: endDate) {
            let startFormatted = outputFormatter.string(from: start)
            let endFormatted = outputFormatter.string(from: end)
            return "\(startFormatted) - \(endFormatted)"
        }

        return "\(startDate) - \(endDate)"
    }
    
    private func badgeImage(for badge: String) -> UIImage? {
        switch badge {
        case "예정":
            return UIImage(resource: .blue50Pocket)
        case "마감":
            return UIImage(resource: .gray500Pocket)
        case "상시":
            return UIImage(resource: .green300Pocket)
        case let value where value.starts(with: "D-"):
            if let day = Int(value.dropFirst(2)) {
                if day >= 10 {
                    return UIImage(resource: .blue200Pocket)
                } else if day >= 2 {
                    return UIImage(resource: .blue700Pocket)
                } else if day >= 0 {
                    return UIImage(resource: .redPocket)
                }
            }
            return UIImage(resource: .blue200Pocket)
        default:
            return UIImage(resource: .blue200Pocket)
        }
    }

    private func badgeTextColor(for badge: String) -> UIColor? {
        switch badge {
        case "예정":
            return AppColor.gray800
        case "마감":
            return AppColor.gray500
        case "상시":
            return AppColor.gray800
        case let value where value.starts(with: "D-"):
            if let day = Int(value.dropFirst(2)) {
                if day >= 10 {
                    return AppColor.gray800
                } else if day >= 2 {
                    return .white
                } else if day >= 0 {
                    return .white
                }
            }
            return AppColor.gray800
        default:
            return AppColor.gray800
        }
    }
}
