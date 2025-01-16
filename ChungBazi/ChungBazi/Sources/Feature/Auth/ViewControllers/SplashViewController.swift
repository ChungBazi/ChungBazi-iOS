//
//  SplashViewController.swift
//  ChungBazi
//
//  Created by 이현주 on 1/16/25.
//

import UIKit
import Then
import UIKit

class SplashViewController: UIViewController {
    
    private let splashLabel = UILabel().then {
        $0.text = "정책도 쉽고 간편하게"
        $0.textColor = .white
        $0.font = UIFont.ptdSemiBoldFont(ofSize: 28)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue700
        addComponents()
        setConstraints()
        updateLabelText()
    }
    
    private func addComponents() {
        view.addSubview(splashLabel)
    }
    
    private func setConstraints() {
        splashLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    private func updateLabelText() {
        // 텍스트 업데이트
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.splashLabel.text = "청바지"
            
            // 2초 후 메인 화면으로 전환
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                let vc = SelectLoginTypeViewController()
                let navController = UINavigationController(rootViewController: vc)
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true, completion: nil)
            }
        }
    }
}
