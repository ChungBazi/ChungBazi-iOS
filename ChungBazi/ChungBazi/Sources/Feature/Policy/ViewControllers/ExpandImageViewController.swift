//
//  ExpandImageViewController.swift
//  ChungBazi
//
//  Created by 엄민서 on 2/3/25.
//

import UIKit

final class ExpandImageViewController: UIViewController {
    
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
    
    var image: UIImage? {
        didSet {
            expandImageView.image = image
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        setupLayout()
        setupGesture()
    }

    private func setupLayout() {
        
        view.addSubview(closeButton)
        view.addSubview(expandImageView)

        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            make.leading.equalToSuperview().offset(16)
        }
                
        expandImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(expandImageView.snp.width).multipliedBy(1.0)
        }
    }
    
    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
}
