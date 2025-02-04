//
//  PosterView.swift
//  ChungBazi
//
//  Created by 엄민서 on 2/2/25.
//

import UIKit
import SnapKit

class PosterView: UIView {
    
    private let blurBackgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        addSubview(blurBackgroundImageView)
        addSubview(posterImageView)
        
        blurBackgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        posterImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(207) 
        }
    }
    
    func configure(with image: UIImage?) {
        posterImageView.image = image
        blurBackgroundImageView.image = image?.applyBlurEffect()
    }
}
