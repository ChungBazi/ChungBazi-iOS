//
//  CheckCollectionViewCell.swift
//  ChungBazi
//
//  Created by 이현주 on 1/20/25.
//

import UIKit
import Then

class CheckCollectionViewCell: UICollectionViewCell {
    static let identifier = "CheckCollectionViewCell"
    
    public lazy var checkButton = UIButton().then {
        $0.backgroundColor = .clear
        $0.setImage(.checkboxUnchecked, for: .normal)
    }
    
    public lazy var contents = UILabel().then {
        $0.font = UIFont.ptdMediumFont(ofSize: 16)
        $0.textColor = UIColor.gray800
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addComponents()
        setConstraints()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.contents.text = nil
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addComponents() {
        [checkButton, contents].forEach { self.addSubview($0)}
    }
    
    private func setConstraints() {
        checkButton.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.verticalEdges.equalToSuperview()
        }
        
        contents.snp.makeConstraints {
            $0.centerY.equalTo(checkButton)
            $0.leading.equalTo(checkButton.snp.trailing).offset(12)
        }
    }
}
