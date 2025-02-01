//
//  StartSurveyViewController.swift
//  ChungBazi
//

import UIKit
import SnapKit
import Then

class StartSurveyViewController: UIViewController {

    private let finishLoginView = LogoWithTitleView(image: "glassBaro", title: "더 정확한 추천을 위해\n몇 가지 정보를 알려주세요!")
    
    private lazy var startBtn = UIButton().then {
        $0.setTitle("시작하기", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 16)
        $0.layer.cornerRadius = 10
        $0.layer.borderColor = UIColor.white.cgColor
        $0.layer.borderWidth = 1
        $0.backgroundColor = .clear
        $0.addTarget(self, action: #selector(goToSetEducation), for: .touchUpInside)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = finishLoginView
        addComponents()
        setConstraints()
    }
    
    @objc private func goToSetEducation() {
        let vc = SetEducationViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func addComponents() {
        [startBtn].forEach { view.addSubview($0) }
    }
    
    private func setConstraints() {
        
        startBtn.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(48)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
        }
    }
}
