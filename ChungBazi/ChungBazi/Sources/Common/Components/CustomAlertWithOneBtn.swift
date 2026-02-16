//
//  CustomAlertWithOneBtn.swift
//  ChungBazi
//
//  Created by 이현주 on 2/9/25.
//

import UIKit
import SnapKit
import Then

extension UIViewController {
    func showCustomAlert(headerTitle: String? = nil, title: String,  buttonText: String, image: UIImage? = nil, buttonAction: (() -> Void)? = nil) {
        let alertVC = CustomAlertViewWithOneBtnController()
        alertVC.modalPresentationStyle = .overFullScreen
        alertVC.modalTransitionStyle = .crossDissolve
        
        alertVC.configureAlert(headerTitle: headerTitle, title: title, ButtonText:  buttonText, image: image, buttonAction: buttonAction)
        
        self.present(alertVC, animated: true, completion: nil)
    }
}

class CustomAlertViewWithOneBtnController: UIViewController {
    
    private let dimView = UIView().then {
        $0.backgroundColor = .black.withAlphaComponent(0.35)
    }
    private let alertView = UIView().then {
        $0.backgroundColor = .gray50
        $0.layer.cornerRadius = 10
    }
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.isHidden = true // 처음에는 숨김 처리
    }
    private let headerLabel = B16_SB(text: "", textColor: .buttonAccent).then {
        $0.textAlignment = .center
    }
    private let titleLabel = B16_M(text: "").then {
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    private let Btn = CustomButton(backgroundColor: .clear, titleText: "", titleColor: .black, borderWidth: 1, borderColor: .gray400)
    
    private var titleLabelTopConstraint: Constraint?
    
    private var buttonAction: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()

        headerLabel.snp.remakeConstraints { make in
            if let headerText = headerLabel.text, !headerText.isEmpty {
                make.top.equalToSuperview().offset(38)
                make.centerX.equalToSuperview()
            }
        }
        
        titleLabel.snp.remakeConstraints { make in
            if let headerText = headerLabel.text, !headerText.isEmpty {
                make.top.equalTo(headerLabel.snp.bottom).offset(21)
            } else {
                make.top.equalToSuperview().offset(38)
            }
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(14)
        }
    }
    
    private func setupUI() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissAlert))
        dimView.addGestureRecognizer(tapGesture)
        
        view.addSubviews(dimView, alertView, imageView)
        dimView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        alertView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(273)
        }
        
        imageView.snp.makeConstraints {
            $0.bottom.equalTo(alertView.snp.bottom).offset(-25)
            $0.centerX.equalToSuperview()
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(34)
        }
        
        alertView.addSubviews(headerLabel, titleLabel, Btn)

        headerLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(40)
            $0.leading.trailing.equalToSuperview().inset(14)
        }

        titleLabel.snp.makeConstraints {
            titleLabelTopConstraint = $0.top.equalTo(alertView.snp.top).inset(38).constraint
            $0.leading.trailing.equalToSuperview().inset(14)
        }

        Btn.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(27)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(14)
            $0.width.equalTo(118)
        }

        Btn.addTarget(self, action: #selector(ButtonTapped), for: .touchUpInside)
    }
    
    func configureAlert(headerTitle: String?, title: String, ButtonText: String, image: UIImage?, buttonAction: (() -> Void)?) {
        self.headerLabel.text = headerTitle
        self.headerLabel.setLineSpacing()
        self.titleLabel.text = title
        self.titleLabel.setLineSpacing()
        self.Btn.setTitle(ButtonText, for: .normal)
        if let image = image {
            self.imageView.image = image
            self.imageView.isHidden = false // 이미지가 있으면 표시
        }
        self.buttonAction = buttonAction
    }
    
    @objc private func ButtonTapped() {
        dismiss(animated: true) {
            self.buttonAction?()
        }
    }
    
    @objc private func dismissAlert() {
        dismiss(animated: true, completion: nil)
    }
}
