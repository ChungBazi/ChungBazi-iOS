//
//  BannerView.swift
//  ChungBazi
//
//  Created by 엄민서 on 1/24/25.
//

import UIKit

class BannerView: UIView {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont(name: AppFontName.pSemiBold, size: 16)
        label.textColor = UIColor.white
        label.text = "청년이라면 누구나\n누릴 수 있는 정부혜택"
        return label
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont(name: AppFontName.pMedium, size: 14)
        label.textColor = UIColor.white
        label.text = "청년이 직접 뽑은 BEST3 알아보기"
        return label
    }()
    
    let iconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "party"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = AppColor.blue700
        layer.cornerRadius = 10
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(iconImageView)
        
        iconImageView.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(8)
            make.trailing.equalToSuperview().inset(16)
            make.width.height.equalTo(90)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(22)
            make.trailing.equalTo(iconImageView.snp.leading).offset(-5)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalTo(titleLabel)
            make.bottom.equalToSuperview().inset(22)
        }
    }
}
