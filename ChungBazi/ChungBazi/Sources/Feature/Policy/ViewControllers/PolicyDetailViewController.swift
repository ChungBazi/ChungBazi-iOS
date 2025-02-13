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
    private let networkService = PolicyService()

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

    private let registerButton = CustomActiveButton(title: "담당기관 바로가기", isEnabled: false).then {
        $0.addTarget(self, action: #selector(handleRegisterButtonTap), for: .touchUpInside)
    }

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
        fetchPolicyDetail()
        setupActions()
//        checkIfButtonCanBeEnabled()
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

    private func fetchPolicyDetail() {
        guard let policyId = policyId else {
            print("⚠️ 정책 ID가 없습니다.")
            return
        }

        networkService.fetchPolicyDetail(policyId: policyId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                guard let data = response else { return }

                self.policy = PolicyModel(
                    policyId: policyId,
                    policyName: data.name,
                    category: data.categoryName,
                    startDate: data.startDate ?? "기간 정보 없음",
                    endDate: data.endDate ?? "기간 정보 없음",
                    intro: data.intro,
                    content: data.content,
                    target: PolicyTarget(
                        age: data.minAge ?? "연령 정보 없음",
                        major: nil,
                        employment: nil,
                        residenceIncome: data.minIncome ?? "소득 정보 없음",
                        education: data.additionCondition ?? "추가 조건 없음"
                    ),
                    document: data.document ?? "제출 서류 정보 없음",
                    applyProcedure: data.applyProcedure ?? "신청 절차 정보 없음",
                    result: data.result ?? "심사 발표 정보 없음",
                    referenceUrls: [data.referenceUrl1, data.referenceUrl2].compactMap { $0 },
                    registerUrl: data.registerUrl ?? ""
                )

                DispatchQueue.main.async {
                    self.updateUI()
                }

            case .failure(let error):
                print("❌ 정책 상세 조회 실패: \(error.localizedDescription)")
            }
        }
    }

//    private func updateUI() {
//        guard let policy = policy else { return }
//
//        policyView.configure(with: policy)
//
//        if let posterUrl = policy.referenceUrls.compactMap({ $0 }).first, let url = URL(string: posterUrl) {
//            downloadImage(from: url) { image in
//                DispatchQueue.main.async {
//                    self.posterView.configure(with: image)
//                }
//            }
//        }
//        let hasRegisterUrl = !(policy.registerUrl.isEmpty)
//        registerButton.isEnabled = hasRegisterUrl
//
//        print("✅ registerUrl: \(policy.registerUrl)")
//        print("✅ registerButton.isEnabled: \(registerButton.isEnabled)")
//    }
    
    private func updateUI() {
            guard let policy = policy else { return }

            policyView.configure(with: policy)

            if let posterUrl = policy.referenceUrls.compactMap({ $0 }).first, let url = URL(string: posterUrl) {
                downloadImage(from: url) { image in
                    DispatchQueue.main.async {
                        self.posterView.configure(with: image)
                    }
                }
            }

            let hasValidUrl = !(policy.registerUrl.isEmpty)
            registerButton.isEnabled = true

            print("✅ registerUrl: \(policy.registerUrl)")
            print("✅ registerButton.isEnabled: \(registerButton.isEnabled)")
        }

    private func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }.resume()
    }

    private func setupActions() {
        expandButton.addTarget(self, action: #selector(handleExpandButtonTap), for: .touchUpInside)
        cartButton.addTarget(self, action: #selector(handleCartButtonTap), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(handleRegisterButtonTap), for: .touchUpInside)
    }

    @objc private func handleExpandButtonTap() {
        let expandImageVC = ExpandImageViewController()
        
        if let image = posterView.posterImageView.image {
            expandImageVC.image = image
        } else {
            expandImageVC.image = UIImage(named: "poster_example")
        }
        
        expandImageVC.modalPresentationStyle = .overFullScreen
        present(expandImageVC, animated: true, completion: nil)
    }

    @objc private func handleCartButtonTap() {
        let cartVC = CartViewController()
        navigationController?.pushViewController(cartVC, animated: true)
    }

//    @objc private func handleRegisterButtonTap() {
//        guard let urls = policy?.referenceUrls.compactMap({ $0 }), !urls.isEmpty else {
//            print("Error: URL 정보가 없습니다.")
//            return
//        }
//
//        if urls.count > 1 {
//            showMultipleUrlsAlert(urls: urls)
//        } else if let urlString = urls.first, let url = URL(string: urlString) {
//            UIApplication.shared.open(url, options: [:], completionHandler: nil)
//        }
//    }

    

//    private func checkIfButtonCanBeEnabled() {
//        let isUrlAvailable = !urls.isEmpty
//        
//        DispatchQueue.main.async {
//            self.actionButton.isEnabled = isUrlAvailable
//        }
//    }
    
    @objc private func handleRegisterButtonTap() {
        guard let urlString = policy?.registerUrl, !urlString.isEmpty, let url = URL(string: urlString) else {
            print("⚠️ Error: URL 정보가 없습니다.")
            return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
//    @objc private func handleRegisterButtonTap() {
//        guard let urlString = policy?.registerUrl, !urlString.isEmpty, let url = URL(string: urlString) else {
//            print("⚠️ Error: URL 정보가 없습니다.")
//            return
//        }
//
//        UIApplication.shared.open(url, options: [:], completionHandler: nil)
//    }
    
    private func showMultipleUrlsAlert(urls: [String]) {
        let customAlert = CustomAlertView()
        customAlert.configure(message: "해당 정책은 담당기관 바로가기 \n링크가 \(urls.count)개 이상입니다.", urls: urls)
        customAlert.show(in: self)
    }
}
