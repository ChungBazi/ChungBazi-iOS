//
//  ExpandImageViewController.swift
//  ChungBazi
//
//  Created by 엄민서 on 2/3/25.
//

import UIKit
import SnapKit
import Then

final class ExpandImageViewController: UIViewController {

    // MARK: - UI
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("✕", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        button.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        return button
    }()

    private let expandImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()

    /// posterUrl == nil 일 때 보여줄 대체 포스터
    private let placeholderPosterView = PolicyDetailPlaceholderPosterView().then {
        $0.isHidden = true
        $0.clipsToBounds = true
    }

    // MARK: - Public properties

    /// 일반(다운로드된) 포스터 이미지
    var image: UIImage? {
        didSet { updatePresentationMode() }
    }

    /// 포스터가 없을 때 사용
    var fallbackCategoryName: String?
    var fallbackTitle: String?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupLayout()
        setupGesture()
        updatePresentationMode()
    }

    // MARK: - Layout
    private func setupLayout() {
        view.addSubviews(expandImageView, placeholderPosterView, closeButton)

        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            make.leading.equalToSuperview().offset(24)
        }

        // 일반 이미지
        expandImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(expandImageView.snp.width).multipliedBy(1.0)
        }

        // 대체 포스터
        placeholderPosterView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(expandImageView.snp.width).multipliedBy(1.0)
        }
    }

    // MARK: - Gesture
    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        view.addGestureRecognizer(tapGesture)
    }

    // MARK: - Presentation toggle
    private func updatePresentationMode() {
        // 이미지가 있으면 일반 모드
        if let img = image {
            expandImageView.image = img
            expandImageView.isHidden = false
            placeholderPosterView.isHidden = true
            view.backgroundColor = .black
        } else {
            // 이미지 없으면 대체 포스터 모드
            let category = fallbackCategoryName ?? ""
            let title = fallbackTitle ?? ""
            placeholderPosterView.configure(categoryName: category, title: title)

            expandImageView.image = nil
            expandImageView.isHidden = true
            placeholderPosterView.isHidden = false
            view.backgroundColor = .black
        }
    }

    // MARK: - Actions
    @objc private func dismissView() {
        dismiss(animated: true, completion: nil)
    }
}
