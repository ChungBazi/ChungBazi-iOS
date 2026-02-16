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
    
    public lazy var checkImageView = UIImageView().then {
        $0.backgroundColor = .clear
        $0.image = .checkboxUnchecked
        $0.contentMode = .scaleAspectFit
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
        self.checkImageView.image = .checkboxUnchecked
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addComponents() {
        [checkImageView, contents].forEach { self.addSubview($0)}
    }
    
    private func setConstraints() {
        checkImageView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.verticalEdges.equalToSuperview()
        }
        
        contents.snp.makeConstraints {
            $0.centerY.equalTo(checkImageView)
            $0.leading.equalTo(checkImageView.snp.trailing).offset(12)
        }
    }
    
    public func configure(contents: String, isChecked: Bool) {
        self.contents.text = contents
        checkImageView.image = isChecked ? .checkboxChecked : .checkboxUnchecked
    }
}
