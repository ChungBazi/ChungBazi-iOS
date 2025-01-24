//
//  ProfileTableCell.swift
//  ChungBazi
//
//  Created by 신호연 on 1/25/25.
//

import UIKit
import SnapKit
import Then

final class ProfileTableCell: UITableViewCell {
    
    private let titleLabel = B16_M(text: "")
    private let arrowImg = UIImageView().then {
        $0.image = .moveIcon
        $0.contentMode = .scaleAspectFit
    }
    
    override init (style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubviews(titleLabel, arrowImg)
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(32)
            $0.centerY.equalToSuperview()
        }
        arrowImg.snp.makeConstraints {
            $0.trailing.equalTo(-26)
            $0.centerY.equalToSuperview()
        }
    }
    
    func configure(with title: String) {
        titleLabel.text = title
    }
}
