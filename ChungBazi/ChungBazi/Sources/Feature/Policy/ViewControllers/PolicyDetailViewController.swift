//
//  PolicyDetailViewController.swift
//  ChungBazi
//

import UIKit
import SnapKit

class PolicyDetailViewController: UIViewController {

    var policyId: Int?
    
    private let posterView = PosterView()
    private let policyView = PolicyView()
    
    private let expandButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "expand_icon"), for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 19.5
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.1
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 4
        button.addTarget(self, action: #selector(handleExpandButtonTap), for: .touchUpInside)
        return button
    }()

    private let bottomBackgroundView = UIView()
    private lazy var cartButton = CustomButton(
        backgroundColor: .white,
        titleText: "장바구니",
        titleColor: .gray800,
        borderWidth: 1,
        borderColor: .gray400
    )
    
    private lazy var registerButton = CustomActiveButton(
        title: "담당기관 바로가기",
        isEnabled: true
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addCustomNavigationBar(
            titleText: "",
            showBackButton: true,
            showCartButton: false,
            showAlarmButton: false,
            showShareButton: true,
            backgroundColor: .white
        )
        setupLayout()
        loadPolicyData()
        configureBottomBackgroundView()
        setupActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    private func setupLayout() {
        view.addSubviews(posterView, expandButton, policyView, bottomBackgroundView)
        bottomBackgroundView.addSubviews(cartButton, registerButton)

        posterView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(65)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(207)
        }
        
        expandButton.snp.makeConstraints { make in
            make.bottom.equalTo(posterView).offset(-8)
            make.trailing.equalTo(posterView).offset(-10)
            make.width.height.equalTo(39)
        }

        policyView.snp.makeConstraints { make in
            make.top.equalTo(posterView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(bottomBackgroundView.snp.top).offset(-16)
        }

        bottomBackgroundView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(92 + view.safeAreaInsets.bottom)
        }

        cartButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.centerY.equalToSuperview().offset(-view.safeAreaInsets.bottom / 2 - 7)
            make.width.equalTo(view.frame.width / 2 - 24)
            make.height.equalTo(48)
        }

        registerButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview().offset(-view.safeAreaInsets.bottom / 2 - 7)
            make.width.equalTo(view.frame.width / 2 - 24)
            make.height.equalTo(48)
        }
    }

    private func configureBottomBackgroundView() {
        bottomBackgroundView.layer.cornerRadius = 10
        bottomBackgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        bottomBackgroundView.layer.shadowColor = UIColor.black.withAlphaComponent(0.18).cgColor
        bottomBackgroundView.layer.shadowOffset = CGSize(width: 0, height: -1)
        bottomBackgroundView.layer.shadowRadius = 5
        bottomBackgroundView.layer.shadowOpacity = 1
        bottomBackgroundView.backgroundColor = .white
    }

    private func loadPolicyData() {
        let examplePolicy = PolicyModel(
            policyId: 1,
            policyName: "노원구 1인가구 안심홈 3종 세트",
            category: "주거",
            startDate: "2024년 12월 11일",
            endDate: "2025년 1월 31일",
            intro: "소득 근로자가 일·생활 균형을 위해 유연근무제를 활용하게 하는 중소, 중견기업에게 장려금 지원",
            content: "재택 근무자 원격근무 비용 지원",
            target: PolicyTarget(
                age: "연령: 20세 이상 40세 미만",
                major: nil,
                employment: nil,
                residenceIncome: "소득: 9분위",
                education: "추가신청자격: 없음"
            ),
            document: "서류내용\n1. 주민등록 등본\n2. 건강보험증 사본",
            applyProcedure: "접수처: 신청서 본인 주민등록지 주소 주민센터(방문접수)",
            result: "합격자 발표 : 2024. 12. 12.(목)한 ☞ 선발 및 연수기관(부서) 매칭결과 개별안내",
            referenceUrls: ["https://example.com"],
            registerUrl: "https://example.com"
        )

        posterView.configure(with: UIImage(named: "poster_example"))
        policyView.configure(with: examplePolicy)
    }

    private func setupActions() {
        cartButton.addTarget(self, action: #selector(handleCartButtonTap), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(handleRegisterButtonTap), for: .touchUpInside)
    }

    @objc private func handleExpandButtonTap() {
        let expandImageVC = ExpandImageViewController()
        expandImageVC.image = UIImage(named: "poster_example")
        expandImageVC.modalPresentationStyle = .overFullScreen
        present(expandImageVC, animated: true, completion: nil)
    }

    @objc private func handleCartButtonTap() {
        let cartVC = CartViewController()
        navigationController?.pushViewController(cartVC, animated: true)
    }

    @objc private func handleRegisterButtonTap() {
        guard let policy = PolicyDataManager.shared.getPolicy(by: policyId ?? 0),
              let firstUrlString = policy.referenceUrls.compactMap({ $0 }).first,
              let url = URL(string: firstUrlString) else {
            print("Error: URL을 열 수 없음")
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
