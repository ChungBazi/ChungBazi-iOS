//
//  CustomAlert.swift
//  ChungBazi
//
//  Created by 신호연 on 1/25/25.
//

import UIKit
import SnapKit
import Then

/**
`showCustomAlert`:  커스텀 알럿뷰 띄우는 함수

 ```
 showCustomAlert(
    title: "알림 제목",
    rightButtonText: "확인",
    rightButtonAction: {
        print("확인 버튼 클릭)
    }
 }
 ```
 */

extension UIViewController {
    func showCustomAlert(title: String, rightButtonText: String, rightButtonAction: (() -> Void)?) {
        let alertVC = CustomAlertViewController()
        alertVC.modalPresentationStyle = .overFullScreen
        alertVC.modalTransitionStyle = .crossDissolve
        
        alertVC.configureAlert(title: title, rightButtonText: rightButtonText, rightButtonAction: rightButtonAction)
        
        self.present(alertVC, animated: true, completion: nil)
    }
}

class CustomAlertViewController: UIViewController {
    
    private let dimView = UIView().then {
        $0.backgroundColor = .black.withAlphaComponent(0.35)
    }
    private let alertView = UIView().then {
        $0.backgroundColor = .gray50
        $0.layer.cornerRadius = 10
    }
    private let titleLabel = B16_M(text: "").then {
        $0.textAlignment = .center
    }
    private let leftBtn = CustomButton(backgroundColor: .clear, titleText: "취소", titleColor: .black, borderWidth: 1, borderColor: .gray400)
    private let rightBtn = CustomButton(backgroundColor: .clear, titleText: "", titleColor: .buttonAccent, borderWidth: 1, borderColor: .buttonAccent)
    private var rightButtonAction: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.addSubviews(dimView, alertView)
        dimView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        alertView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(273)
        }
        
        alertView.addSubviews(titleLabel, leftBtn, rightBtn)
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(40)
            $0.leading.trailing.equalToSuperview().inset(14)
        }
        leftBtn.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(27)
            $0.leading.bottom.equalToSuperview().inset(14)
            $0.width.equalTo(118)
        }
        rightBtn.snp.makeConstraints {
            $0.top.equalTo(leftBtn)
            $0.trailing.equalToSuperview().inset(14)
            $0.width.equalTo(118)
        }

        leftBtn.addTarget(self, action: #selector(leftButtonTapped), for: .touchUpInside)
        rightBtn.addTarget(self, action: #selector(rightButtonTapped), for: .touchUpInside)
    }
    
    func configureAlert(title: String, rightButtonText: String, rightButtonAction: (() -> Void)?) {
        self.titleLabel.text = title
        self.rightBtn.setTitle(rightButtonText, for: .normal)
        self.rightButtonAction = rightButtonAction
    }
    
    @objc private func leftButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func rightButtonTapped() {
        dismiss(animated: true) {
            self.rightButtonAction?()
        }
    }
}
