//
//  ProfileMyRewardView.swift
//  ChungBazi
//
//  Created by 신호연 on 1/25/25.
//

import UIKit
import SnapKit
import Then

extension UIViewController {
    func showProfileMyRewardView() {
        let profileMyRewardVC = ProfileMyRewardViewController()
        profileMyRewardVC.modalPresentationStyle = .overFullScreen
        profileMyRewardVC.modalTransitionStyle = .crossDissolve
        
        self.present(profileMyRewardVC, animated: true, completion: nil)
    }
}

class ProfileMyRewardViewController: UIViewController {
    private let dimView = UIView().then {
        $0.backgroundColor = .black.withAlphaComponent(0.35)
    }
    private let profileMyRewardView = UIView().then {
        $0.backgroundColor = .gray50
        $0.layer.cornerRadius = 10
    }
    private let titleLabel = B16_SB(text: "마이 리워드")
    private let separateView = UIView().then {
        $0.backgroundColor = .gray100
    }
    private let rewardStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.spacing = 15
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addRewardItems()
    }
    
    private func setupUI() {
        view.addSubviews(dimView, profileMyRewardView)
        
        /// 배경 탭 -> 닫힘
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        dimView.addGestureRecognizer(tapGesture)
        
        dimView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        profileMyRewardView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(253)
        }
        
        profileMyRewardView.addSubviews(titleLabel, separateView, rewardStackView)
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(23)
            $0.centerX.equalToSuperview()
        }
        separateView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.height.equalTo(2)
        }
        rewardStackView.snp.makeConstraints {
            $0.top.equalTo(separateView.snp.bottom).offset(25)
            $0.bottom.equalToSuperview().inset(35)
            $0.leading.equalToSuperview().inset(46)
        }
    }
    
    private func createRewardSet(title: String) -> UIView {
        let container = UIStackView().then {
            $0.axis = .horizontal
            $0.alignment = .leading
            $0.spacing = 7
        }
        let imageView = UIImageView(image: UIImage.rewardColorIcon).then {
            $0.contentMode = .scaleAspectFit
            $0.snp.makeConstraints {
                $0.size.equalTo(24)
            }
        }
        let textLabel = B16_M(text: title)
        
        container.addArrangedSubview(imageView)
        container.addArrangedSubview(textLabel)
        return container
    }
    
    private func addRewardItems() {
        let currentReward = createRewardSet(title: "현재 리워드:")
        let myPosts = createRewardSet(title: "내가 쓴 글:")
        let myComments = createRewardSet(title: "내가 쓴 댓글:")
        
        rewardStackView.addArrangedSubview(currentReward)
        rewardStackView.addArrangedSubview(myPosts)
        rewardStackView.addArrangedSubview(myComments)
    }
    
    @objc private func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
}
