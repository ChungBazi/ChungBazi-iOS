//
//  PolicyCardViewCell.swift
//  ChungBazi
//
//  Created by 엄민서 on 1/24/25.
//

import UIKit
import SnapKit

class PolicyCardViewCell: UITableViewCell {
    static let identifier = "PolicyCardViewCell"

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

    private let regionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: AppFontName.pSemiBold, size: 16)
        label.textColor = .black
        label.numberOfLines = 2
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: AppFontName.pSemiBold, size: 16)
        label.textColor = .black
        label.numberOfLines = 2
        return label
    }()

    private let periodLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: AppFontName.pMedium, size: 14)
        label.textColor = AppColor.gray400
        return label
    }()

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        contentView.addSubview(containerView)
        containerView.addSubview(badgeImageView)
        containerView.addSubview(badgeTextLabel)

        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview().inset(8)
            make.height.equalTo(102)
        }

        badgeImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(17)
            make.centerY.equalToSuperview()
            make.width.equalTo(52)
            make.height.equalTo(60)
        }

        badgeTextLabel.snp.makeConstraints { make in
            make.center.equalTo(badgeImageView)
        }

        let labelStackView = UIStackView(arrangedSubviews: [regionLabel, titleLabel, periodLabel])
        labelStackView.axis = .vertical
        labelStackView.spacing = 4
        labelStackView.alignment = .leading

        containerView.addSubview(labelStackView)
        labelStackView.snp.makeConstraints { make in
            make.leading.equalTo(badgeImageView.snp.trailing).offset(15)
            make.trailing.equalToSuperview().offset(-17)
            make.top.equalToSuperview().offset(19)
            make.bottom.equalToSuperview().offset(-17)
        }
    }

    private func badgeImage(for badge: String) -> UIImage? {
        switch badge {
        case "마감":
            return UIImage(named: "d_day_grayscale200")
        case "D-0":
            return UIImage(named: "d_day_red")
        case let value where value.starts(with: "D-"):
            if let day = Int(value.dropFirst(2)) {
                if day >= 10 {
                    return UIImage(named: "d_day_blue200")
                } else if day >= 2 {
                    return UIImage(named: "d_day_blue700")
                } else if day == 1 {
                    return UIImage(named: "d_day_blue900")
                }
            }
            return UIImage(named: "d_day_blue200")
        default:
            return UIImage(named: "d_day_blue200")
        }
    }

    private func badgeTextColor(for badge: String) -> UIColor? {
        switch badge {
        case "마감":
            return AppColor.gray500
        case "D-0":
            return .white
        case let value where value.starts(with: "D-"):
            if let day = Int(value.dropFirst(2)) {
                if day >= 10 {
                    return AppColor.gray800
                } else if day >= 2 {
                    return .white
                } else if day == 1 {
                    return .white
                }
            }
            return AppColor.gray800
        default:
            return AppColor.gray800
        }
    }
    
    func configure(with item: PolicyItem, keyword: String?) {
        badgeImageView.image = badgeImage(for: item.badge)
        badgeTextLabel.text = item.badge
        badgeTextLabel.textColor = badgeTextColor(for: item.badge)
        regionLabel.text = item.region
        
        let fullText = "\(item.region) \(item.title)"
        if let keyword = keyword, let range = fullText.range(of: keyword) {
            let attributedString = NSMutableAttributedString(string: fullText)
            attributedString.addAttribute(.foregroundColor, value: AppColor.blue700, range: NSRange(range, in: fullText))
            regionLabel.attributedText = attributedString
        } else {
            regionLabel.text = fullText
        }
        periodLabel.text = item.period
    }
}
