//
//  RecommendViewController.swift
//  ChungBazi
//
//  Created by 엄민서 on 1/24/25.
//

import UIKit
import SnapKit
import Then

final class RecommendViewController: UIViewController, CustomDropdownDelegate {
    
    var userName = UserProfileDataManager.shared.getNickname()
    var interest = UserInfoDataManager.shared.getInterests().first ?? "정책"
    private let networkService = PolicyService()
    private var policyList: [PolicyItem] = []
    private var nextCursor: Int?
    private var hasNext: Bool = false
    
    private let categoryMapping: [String: String] = [
        "JOBS": "일자리",
        "HOUSING": "주거",
        "EDUCATION": "교육",
        "WELFARE_CULTURE": "복지,문화",
        "PARTICIPATION_RIGHTS": "참여,권리"
    ]
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "님께 딱 맞는 정책\n추천 리스트를 준비했어요!"
        label.numberOfLines = 2
        label.font = UIFont(name: AppFontName.pSemiBold, size: 20)
        label.textAlignment = .left
        label.textColor = .black
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(PolicyCardViewCell.self, forCellReuseIdentifier: PolicyCardViewCell.identifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.allowsSelection = false
        return tableView
    }()
    
    private lazy var interestDropdown = CustomDropdown(
        height: 36,
        fontSize: 14,
        title: "관심",
        hasBorder: false,
        items: Constants.interestItems
    )
    
    private lazy var sortDropdown = CustomDropdown(
        height: 36,
        fontSize: 14,
        title: "최신순",
        hasBorder: false,
        items: Constants.sortItems
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.gray50

        addCustomNavigationBar(
            titleText: "",
            showBackButton: false,
            showCartButton: true,
            showAlarmButton: true,
            showHomeRecommendTabs: true,
            activeTab: 1,
            backgroundColor: .gray50
        )
        tableView.dataSource = self
        tableView.delegate = self
        
        setupLayout()
        configureDropdowns()
        updateTitleLabel()
        updateUserInfo()
        fetchRecommendPolicies(category: interest, cursor: 0)

    }

    private func setupLayout() {
        view.addSubviews(titleLabel, interestDropdown, sortDropdown, tableView)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(90)
            make.leading.trailing.equalToSuperview().inset(35)
        }
        
        interestDropdown.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(25)
            make.leading.equalToSuperview().offset(160)
            make.width.equalTo(91)
            make.height.equalTo(36 * Constants.interestItems.count + 36 + 8)
        }

        sortDropdown.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(25)
            make.trailing.equalToSuperview().offset(-16)
            make.width.equalTo(91)
            make.height.equalTo(36 * Constants.sortItems.count + 36 + 8)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(sortDropdown.snp.bottom).inset(48)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.bringSubviewToFront(interestDropdown)
        view.bringSubviewToFront(sortDropdown)
    }
    
    private func configureDropdowns() {
        interestDropdown.delegate = self
        sortDropdown.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let updatedUserName = UserProfileDataManager.shared.getNickname()
        if updatedUserName != userName {
            userName = updatedUserName
            updateTitleLabel()
        }
    }
    
    // MARK: - CustomDropdownDelegate
    func dropdown(_ dropdown: CustomDropdown, didSelectItem item: String) {
        if dropdown == interestDropdown {
            print("관심 분야 선택: \(item)")
        } else if dropdown == sortDropdown {
            print("Selected item: \(item)")
        }
    }
    
    private func updateTitleLabel() {
        let text = "\(userName)님께 딱 맞는 \(interest) 정책\n추천 리스트를 준비했어요!"
        
        let attributedText = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        paragraphStyle.alignment = .left
        
        attributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: text.count))
        
        if let range = text.range(of: interest) {
            let nsRange = NSRange(range, in: text)
            attributedText.addAttribute(.foregroundColor, value: AppColor.blue700, range: nsRange)
        }
        
        titleLabel.attributedText = attributedText
        titleLabel.numberOfLines = 2
        titleLabel.sizeToFit()
    }
    
    private func updateUserInfo() {
        let interestList = UserInfoDataManager.shared.getInterests()
        print("📢 저장된 관심 카테고리: \(interestList)")
        
        let validCategories = ["JOBS", "HOUSING", "EDUCATION", "WELFARE_CULTURE", "PARTICIPATION_RIGHTS"]
        if let userInterest = interestList.first, validCategories.contains(userInterest) {
            interest = userInterest
        } else {
            interest = "JOBS"
        }
        
        print("✅ 선택된 관심 카테고리: \(interest)")
    }
    
    private func fetchRecommendPolicies(category: String, cursor: Int) {
        print("📡 API 요청: category = \(category), cursor = \(cursor)")
        
        networkService.fetchRecommendPolicy(category: interest, cursor: cursor, order: "latest") { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                guard let response = response, let recommendContent = response.policies else {
                    print("❌ 추천 정책 데이터 없음")
                    return
                }
                
                let recommendPolicies: [PolicyItem] = recommendContent.compactMap { data in
                    guard let policyId = data.policyId, let policyName = data.policyName else {
                        return nil
                    }
                    return PolicyItem(
                        policyId: policyId,
                        policyName: policyName,
                        startDate: data.startDate ?? "미정",
                        endDate: data.endDate ?? "미정",
                        dday: data.dday ?? 0
                    )
                }
                
                self.policyList = (cursor == 0) ? recommendPolicies : self.policyList + recommendPolicies
                self.nextCursor = response.nextCursor
                self.hasNext = response.hasNext
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            case .failure(let error):
                print("❌ 정책 추천 API 실패: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension RecommendViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return policyList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PolicyCardViewCell.identifier, for: indexPath) as? PolicyCardViewCell else {
            return UITableViewCell()
        }
        let policy = policyList[indexPath.row]
        cell.configure(with: policy, keyword: nil)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedPolicy = policyList[indexPath.row]
        
        let detailVC = PolicyDetailViewController()
        detailVC.policyId = selectedPolicy.policyId
        
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
