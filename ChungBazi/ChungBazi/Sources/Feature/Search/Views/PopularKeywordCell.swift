//
//  PopularKeywordCell.swift
//  ChungBazi
//
//  Created by 엄민서 on 1/28/25.
//

import UIKit
import SnapKit

class PopularKeywordCell: UICollectionViewCell {
    static let identifier = "PopularKeywordCell"

    private let keywordLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: AppFontName.pMedium, size: 14)
        label.textColor = AppColor.gray800
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
        contentView.isUserInteractionEnabled = true
        setupLayout()
        setupStyle()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        contentView.addSubview(keywordLabel)
        keywordLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10))
        }
    }

    private func setupStyle() {
        contentView.layer.cornerRadius = 10
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = AppColor.gray400?.cgColor
        contentView.snp.makeConstraints { make in
            make.height.equalTo(36)
        }
    }

    func configure(with keyword: String) {
        keywordLabel.text = keyword
    }
}
