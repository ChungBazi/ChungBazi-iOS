//
//  PosterView.swift
//  ChungBazi
//
//  Created by 엄민서 on 2/2/25.
//

import UIKit
import SnapKit
import Then

final class PosterView: UIView {
    
    private let blurBackgroundImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    private let posterImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        addSubviews(blurBackgroundImageView, posterImageView)
        
        blurBackgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        posterImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.height.equalTo(207)
        }
    }
    
    func configure(with image: UIImage?) {
        posterImageView.image = image
        blurBackgroundImageView.image = image?.applyBlurEffect()
    }
}
