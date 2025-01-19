//
//  SelectLoginTypeViewController.swift
//  ChungBazi
//

import UIKit

class SelectLoginTypeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = selectLoginView
    }
    
    private lazy var selectLoginView = SelectLoginView().then {
        $0.kakaoBtn.addTarget(self, action: #selector(kakaoLogin), for: .touchUpInside)
    }
    
    @objc private func kakaoLogin() {
        let vc = FinishLoginViewController()
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true, completion: nil)
    }
}
