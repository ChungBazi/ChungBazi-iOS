//
//  PolicyTableViewCell.swift
//  ChungBazi
//
//  Created by 엄민서 on 1/24/25.
//

import UIKit
import SnapKit

class PolicyTableViewCell: UITableViewCell {
    private let badgeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let badgeTextLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: AppFontName.pSemiBold, size: 14)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()

    private let regionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: AppFontName.pMedium, size: 14)
        label.textColor = AppColor.gray800
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: AppFontName.pSemiBold, size: 16)
        label.textColor = .black
        label.numberOfLines = 1
        return label
    }()

    private let periodLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: AppFontName.pMedium, size: 14)
        label.textColor = AppColor.gray600
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
            make.width.height.equalTo(50)
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
            make.leading.equalTo(badgeImageView.snp.trailing).offset(10)
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

    func configure(with item: PolicyItem) {
        badgeImageView.image = badgeImage(for: item.badge)
        badgeTextLabel.text = item.badge
        regionLabel.text = item.region
        titleLabel.text = item.title
        periodLabel.text = item.period
    }
}
