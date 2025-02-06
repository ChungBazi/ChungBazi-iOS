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

    var selectionHandler: ((Bool) -> Void)?
    var deleteHandler: (() -> Void)?

    var showControls: Bool = false {
        didSet {
            checkBoxButton.isHidden = !showControls
            deleteButton.isHidden = !showControls

            containerView.snp.updateConstraints { make in
                make.height.equalTo(showControls ? 131 : 94)
            }
        }
    }

    private let checkBoxButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "checkbox_unchecked"), for: .normal)
        button.setImage(UIImage(named: "checkbox_checked"), for: .selected)
        button.isHidden = true
        return button
    }()

    private let deleteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "x_icon"), for: .normal)
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
        containerView.addSubview(checkBoxButton)
        containerView.addSubview(deleteButton)
        containerView.addSubview(badgeImageView)
        containerView.addSubview(badgeTextLabel)
        containerView.addSubview(titleLabel)
        containerView.addSubview(periodLabel)

        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview().inset(8)
            make.height.equalTo(showControls ? 131 : 94)
        }
        
        checkBoxButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(8)
            make.width.height.equalTo(24)
        }

        deleteButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(8)
            make.width.height.equalTo(24)
        }

        badgeImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(checkBoxButton.snp.bottom).offset(8)
            make.width.equalTo(52)
            make.height.equalTo(60)
        }

        badgeTextLabel.snp.makeConstraints { make in
            make.center.equalTo(badgeImageView)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(badgeImageView.snp.trailing).offset(12)
            make.trailing.equalTo(deleteButton.snp.leading).offset(-12)
            make.top.equalTo(badgeImageView.snp.top)
        }

        periodLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
        }

        updateLayoutForControls()
    }

    private func updateLayoutForControls() {
        checkBoxButton.isHidden = !showControls
        deleteButton.isHidden = !showControls

        containerView.snp.updateConstraints { make in
            make.height.equalTo(showControls ? 131 : 94)
        }
    }

    private func configureActions() {
        checkBoxButton.addTarget(self, action: #selector(handleCheckBoxTap), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(handleDeleteButtonTap), for: .touchUpInside)
    }

    @objc private func handleCheckBoxTap() {
        checkBoxButton.isSelected.toggle()
        selectionHandler?(checkBoxButton.isSelected)
    }

    @objc private func handleDeleteButtonTap() {
        deleteHandler?()
    }

    func setCheckBoxState(isSelected: Bool) {
        checkBoxButton.isSelected = isSelected
    }

    func configure(with item: PolicyItem, keyword: String?) {
        badgeImageView.image = badgeImage(for: item.badge)
        badgeTextLabel.text = item.badge
        badgeTextLabel.textColor = badgeTextColor(for: item.badge)
        
        titleLabel.text = "\(item.region) \(item.title)"
        periodLabel.text = item.period
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
}
