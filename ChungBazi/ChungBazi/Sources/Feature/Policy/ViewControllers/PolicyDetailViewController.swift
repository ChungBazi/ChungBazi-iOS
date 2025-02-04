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
            backgroundColor: .white
        )
        setupLayout()
        loadPolicyData()
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
        view.addSubview(posterView)
        view.addSubview(expandButton)
        view.addSubview(policyView)
        view.addSubview(cartButton)
        view.addSubview(registerButton)

        posterView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(60)
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
        }

        cartButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
            make.width.equalTo(view.frame.width / 2 - 24)
            make.height.equalTo(48)
        }

        registerButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
            make.width.equalTo(view.frame.width / 2 - 24)
            make.height.equalTo(48)
        }
    }

    private func loadPolicyData() {
        let examplePolicy = PolicyModel(
            policyId: 1,
            policyName: "노원구 1인가구 안심홈 3종 세트",
            category: "주거",
            startDate: "2024년 12월 11일",
            endDate: "2025년 1월 31일",
            intro: "소득 근로자가 일·생활 균형을 위해 유연근무제를 활용...",
            content: "재택 근무자 원격근무 비용 지원...",
            target: PolicyTarget(
                age: "20세 이상 40세 미만",
                major: nil,
                employment: nil,
                residenceIncome: "소득: 9분위",
                education: "추가신청자격: 없음"
            ),
            document: "서류내용\n1. 주민등록 등본\n2. 건강보험증 사본",
            applyProcedure: "접수처: 신청서 본인 주민등록지 주소 주민센터 방문접수",
            result: "합격자 발표: 2024년 12월 12일 (목)",
            referenceUrls: ["https://example.com"],
            registerUrl: "https://example.com"
        )
        
        posterView.configure(with: UIImage(named: "poster_example"))
        policyView.configure(with: examplePolicy)

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
