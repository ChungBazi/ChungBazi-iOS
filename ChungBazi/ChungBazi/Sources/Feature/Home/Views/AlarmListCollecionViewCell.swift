//
//  AlarmListCollecionViewCell.swift
//  ChungBazi
//
//  Created by 이현주 on 1/27/25.
//

import UIKit
import Then

class AlarmListCollecionViewCell: UICollectionViewCell {
    
    static let identifier = "AlarmListCollecionViewCell"
    
    private lazy var image = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var title = UILabel().then {
        $0.numberOfLines = 2
        $0.font = UIFont.ptdMediumFont(ofSize: 16)
        $0.textColor = .black
    }
    
    private lazy var time = UILabel().then {
        $0.font = UIFont.ptdMediumFont(ofSize: 14)
        $0.textColor = UIColor.gray400
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        addComponents()
        setConstraints()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.title.text = nil
        self.time.text = nil
        self.image.image = nil
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addComponents() {
        [image, title, time].forEach { self.addSubview($0)}
    }
    
    private func setConstraints() {
        image.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(21)
            $0.width.height.equalTo(24)
        }
        
        title.snp.makeConstraints {
            $0.top.equalToSuperview().offset(18)
            $0.leading.equalTo(image.snp.trailing).offset(15)
            $0.trailing.equalToSuperview().inset(17)
        }
        
        time.snp.makeConstraints {
            $0.leading.equalTo(title.snp.leading)
            $0.top.equalTo(title.snp.bottom).offset(9)
        }
    }
    
    public func configure(_ model: AlarmModel) {
        title.text = model.message
        time.text = model.sentTime
        image.image = model.type.image
    }
}
