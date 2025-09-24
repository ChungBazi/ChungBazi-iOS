//
//  PolicyDetailPlaceholderPosterView.swift
//  ChungBazi
//
//  Created by 신호연 on 9/24/25.
//

import UIKit
import SnapKit
import Then

/// posterUrl == nil 일 때 보여줄 대체 포스터 뷰
final class PolicyDetailPlaceholderPosterView: UIView {

    private let backgroundImageView = UIImageView(image: UIImage(named: "policyDetail")).then {
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
    }

    private let categoryContainer = UIView().then {
        $0.backgroundColor = .blue100
        $0.layer.cornerRadius = 7.94
        $0.clipsToBounds = true
        $0.isUserInteractionEnabled = false
    }

    private let categoryLabel = UILabel().then {
        $0.font = .ptdMediumFont(ofSize: 11)
        $0.textColor = .black
        $0.textAlignment = .center
        $0.numberOfLines = 1
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        $0.setContentHuggingPriority(.required, for: .horizontal)
    }

    private let nameLabel = UILabel().then {
        $0.font = .ptdBoldFont(ofSize: 20)
        $0.textColor = .gray800
        $0.numberOfLines = 2
        $0.lineBreakMode = .byTruncatingTail
        $0.textAlignment = .center
    }

    func configure(categoryName: String, title: String) {
        categoryLabel.text = categoryName
        nameLabel.text = title
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        addSubview(backgroundImageView)
        addSubview(categoryContainer)
        categoryContainer.addSubview(categoryLabel)
        addSubview(nameLabel)

        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        categoryContainer.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.centerX.equalToSuperview()
        }

        categoryLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4.81, left: 7.94, bottom: 4.81, right: 7.94))
        }

        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryContainer.snp.bottom).offset(16.23)
            make.leading.trailing.equalToSuperview().inset(19.94)
            make.height.equalTo(56)
        }
    }
}
