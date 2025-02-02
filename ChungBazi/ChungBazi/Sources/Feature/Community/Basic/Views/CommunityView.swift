//
//  CommunityView.swift
//  ChungBazi
//
//  Created by 신호연 on 2/2/25.
//

import UIKit
import SnapKit
import Then

protocol CommunityViewDelegate: AnyObject {
    func didTapWriteButton()
}

final class CommunityView: UIView {
    
    weak var delegate: CommunityViewDelegate?
    
    private let writeButton = UIButton.createWithImage(
        image: UIImage(named: "writeIcon")?.withRenderingMode(.alwaysOriginal),
        target: self,
        action: #selector(handleWriteButtonTap)
    )
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubviews(writeButton)
        writeButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(18)
            $0.trailing.equalToSuperview().inset(Constants.gutter)
        }
    }
    
    @objc private func handleWriteButtonTap() {
        delegate?.didTapWriteButton()
    }
}
