//
//  FinishRegisterViewController.swift
//  ChungBazi
//
//  Created by 엄민서 on 9/30/25.
//

import UIKit

class FinishRegisterViewController: UIViewController {
    
    private let finishRegisterView = LogoWithTitleView(image: "lightBaro", title: "회원가입이 완료되었습니다!\n이제 청바지에 로그인해보세요!")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        self.view = finishRegisterView
        goToSelectLoginView()
    }
    
    private func goToSelectLoginView() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let vc = SelectLoginTypeViewController()
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController = vc
                UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
            }
        }
    }
}
