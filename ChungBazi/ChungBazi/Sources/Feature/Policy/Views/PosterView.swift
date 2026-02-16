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
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
    }

    private let posterContainerView = UIView()

    let posterImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
        $0.isHidden = true
    }

    private let placeholderPosterView = PolicyDetailPlaceholderPosterView().then {
        $0.isHidden = true
        $0.clipsToBounds = true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupLayout() {
        addSubviews(blurBackgroundImageView, posterContainerView)

        blurBackgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        posterContainerView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.height.equalTo(207)
        }

        posterContainerView.addSubviews(posterImageView, placeholderPosterView)

        posterImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        placeholderPosterView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    /// 서버 포스터 이미지 사용
    func configure(with image: UIImage?) {
        blurBackgroundImageView.backgroundColor = .clear
        blurBackgroundImageView.image = image?.applyBlurEffect()

        posterImageView.image = image
        posterImageView.isHidden = (image == nil)
        placeholderPosterView.isHidden = (image != nil)
    }

    /// posterUrl == nil 일 때 호출
    func configureFallback(categoryName: String, title: String) {
        blurBackgroundImageView.image = nil
        blurBackgroundImageView.backgroundColor = .gray50

        placeholderPosterView.configure(categoryName: categoryName, title: title)

        posterImageView.isHidden = true
        placeholderPosterView.isHidden = false
    }
}
