//
//  MyCharacterViewController.swift
//  ChungBazi
//
//  Created by 이현주 on 2/9/25.
//

import UIKit

class MyCharacterViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue700
        setNavBar()

        showCustomAlert(
            title: "레벨업 완료!\n새로운 캐릭터가 열렸습니다.\n카드를 눌러 확인해보세요!",
            ButtonText: "좋아요",
            image: .confetti
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    private func setNavBar() {
        addCustomNavigationBar(titleText: "캐릭터 설정", tintColor: .white, showBackButton: true, showCartButton: false, showAlarmButton: false, backgroundColor: .blue700)
        fillSafeArea(position: .top, color: .blue700)
    }

}
