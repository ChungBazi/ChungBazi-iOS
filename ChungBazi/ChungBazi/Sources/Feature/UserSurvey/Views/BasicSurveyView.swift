//
//  BasicSurveyView.swift
//  ChungBazi
//
//  Created by 이현주 on 1/16/25.
//

import UIKit

class BasicSurveyView: UIView {

    public let title = UILabel().then {
        $0.font = UIFont.ptdMediumFont(ofSize: 24)
        $0.textColor = .black
        $0.numberOfLines = 2
    }
    
    private lazy var pageLogo = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .clear
    }
    
    public lazy var backBtn = CustomButton(backgroundColor: .white, titleText: "이전으로", titleColor: .gray800, borderWidth: 1, borderColor: .gray400)
    
    public lazy var nextBtn = CustomActiveButton(title: "다음으로", isEnabled: false)
    
    private lazy var backBtnPlaceholder = UIView()
    
    private lazy var buttonStackView = UIStackView(arrangedSubviews: [backBtn, nextBtn]).then {
        $0.axis = .horizontal
        $0.spacing = 12
        $0.alignment = .fill
        $0.distribution = .fillEqually
    }

    init(title: String, logo: ImageResource) {
        super.init(frame: .zero)
        self.backgroundColor = .gray50
        self.title.text = title
        self.title.setLineSpacing()
        self.title.textAlignment = .center
        self.pageLogo.image = UIImage(resource: logo)
        addComponents()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func toggleBackButton() {
        backBtn.isHidden = true
        backBtnPlaceholder.isHidden = false
        buttonStackView.insertArrangedSubview(backBtnPlaceholder, at: 0)
    }
    
    private func addComponents() {
        [title, pageLogo, buttonStackView].forEach { self.addSubview($0) }
    }
    
    private func setConstraints() {
        
        title.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Constants.superViewHeight * 0.13)
            $0.centerX.equalToSuperview()
        }
        
        buttonStackView.snp.makeConstraints {
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-20)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        pageLogo.snp.makeConstraints {
            $0.bottom.equalTo(buttonStackView.snp.top).offset(-20)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(Constants.superViewWidth * 0.33)
        }
    }
}
