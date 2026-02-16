//
//  CustomAlertView.swift
//  ChungBazi
//
//  Created by 엄민서 on 2/8/25.
//

import UIKit
import SnapKit
import Then

final class MultiURLCustomAlertView: UIView {
    
    private var policyId: Int?
    var onDismiss: (() -> Void)?
    var onSelectUrl: ((String) -> Void)?

    private let backgroundView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        $0.alpha = 0
    }

    private let alertContainer = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
    }

    private let messageLabel = UILabel().then {
        $0.font = .ptdMediumFont(ofSize: 16)
        $0.textColor = .gray800
        $0.numberOfLines = 2
        $0.textAlignment = .center
    }

    private let buttonStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.spacing = 10
    }

    var dismissAction: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupTapGesture()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        addSubview(backgroundView)
        addSubview(alertContainer)
        alertContainer.addSubviews(messageLabel, buttonStackView)

        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        alertContainer.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(273)
            make.height.greaterThanOrEqualTo(167)
        }

        messageLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(38)
            make.leading.trailing.equalToSuperview().inset(13)
        }

        buttonStackView.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(13)
            make.bottom.equalToSuperview().offset(-14)
        }
    }

    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissAlert))
        backgroundView.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissAlert() {
        UIView.animate(withDuration: 0.2, animations: {
            self.backgroundView.alpha = 0
            self.alertContainer.alpha = 0
        }) { _ in
            self.removeFromSuperview()
            self.dismissAction?()
        }
    }

    func configure(message: String, urls: [String], policyId: Int) {
        self.policyId = policyId
        
        messageLabel.text = message

        buttonStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for (index, url) in urls.enumerated() {
            let button = UIButton(type: .system).then {
                let buttonTitle = "url\(index + 1)"
                $0.setTitle(buttonTitle, for: .normal)
                $0.titleLabel?.font = .ptdMediumFont(ofSize: 14)
                $0.setTitleColor(.blue700, for: .normal)
                $0.layer.cornerRadius = 10
                $0.layer.borderWidth = 1
                $0.layer.borderColor = UIColor.gray400.cgColor
                $0.backgroundColor = .white
                $0.snp.makeConstraints { make in
                    make.width.equalTo(118)
                    make.height.equalTo(40)
                }
                $0.addTarget(self, action: #selector(urlButtonTapped(_:)), for: .touchUpInside)
            }

            button.tag = index
            button.accessibilityLabel = url 
            buttonStackView.addArrangedSubview(button)
        }
    }

    @objc private func urlButtonTapped(_ sender: UIButton) {
        if let urlString = sender.accessibilityLabel,
            let url = URL(string: urlString),
            let policyId = policyId {
            
            AmplitudeManager.shared.trackExternalApplyLinkOpen(
                policyId: policyId,
                externalUrl: url.absoluteString
            )
            
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            dismissAlert()
        }
    }

    func show(in viewController: UIViewController) {
        guard let window = viewController.view.window else { return }
        frame = window.bounds
        window.addSubview(self)

        UIView.animate(withDuration: 0.2) {
            self.backgroundView.alpha = 1
            self.alertContainer.alpha = 1
        }
    }
}
