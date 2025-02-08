//
//  PolicyDetailViewController.swift
//  ChungBazi
//

import UIKit
import SnapKit
import Then

final class PolicyDetailViewController: UIViewController {

    var policyId: Int?
    private var policy: PolicyModel?

    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
    }

    private let contentView = UIView()

    private let posterView = PosterView().then {
        $0.backgroundColor = .clear
    }

    private let policyView = PolicyView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.clipsToBounds = true
    }

    private let expandButton = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "expand_icon"), for: .normal)
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 19.5
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.1
        $0.layer.shadowOffset = CGSize(width: 0, height: 4)
        $0.layer.shadowRadius = 4
    }

    private let bottomBackgroundView = UIView().then {
        $0.layer.cornerRadius = 10
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.layer.shadowColor = UIColor.black.withAlphaComponent(0.18).cgColor
        $0.layer.shadowOffset = CGSize(width: 0, height: -1)
        $0.layer.shadowRadius = 5
        $0.layer.shadowOpacity = 1
        $0.backgroundColor = .white
    }

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
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubviews(posterView, expandButton, policyView)

        view.addSubview(bottomBackgroundView)
        bottomBackgroundView.addSubviews(cartButton, registerButton)

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(65)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(bottomBackgroundView.snp.top)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }

        posterView.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(237)
        }
        
        expandButton.snp.makeConstraints { make in
            make.bottom.equalTo(posterView).offset(-40)
            make.trailing.equalTo(posterView).offset(-15)
            make.width.height.equalTo(39)
        }

        policyView.snp.makeConstraints { make in
            make.top.equalTo(posterView.snp.bottom).offset(-30)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(contentView.snp.bottom).offset(-16)
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
            referenceUrls: ["url1", "url2"],
            registerUrl: "https://example.com"
        )

        self.policy = examplePolicy
        posterView.configure(with: UIImage(named: "poster_example"))
        policyView.configure(with: examplePolicy)
    }

    private func setupActions() {
        expandButton.addTarget(self, action: #selector(handleExpandButtonTap), for: .touchUpInside)
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
        guard let urls = policy?.referenceUrls.compactMap({ $0 }), !urls.isEmpty else {
            print("Error: URL 정보가 없습니다.")
            return
        }

        if urls.count > 1 {
            showMultipleUrlsAlert(urls: urls)
        } else if let urlString = urls.first, let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    private func showMultipleUrlsAlert(urls: [String]) {
        let customAlert = CustomAlertView()
        customAlert.configure(message: "해당 정책은 담당기관 바로가기 \n링크가 \(urls.count)개 이상입니다.", urls: urls)
        customAlert.show(in: self)
    }
}
