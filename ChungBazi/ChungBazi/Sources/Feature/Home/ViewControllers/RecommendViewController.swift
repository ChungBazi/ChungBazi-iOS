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
    
    private var userName: String = ""
    private var interest: String = ""
    private var policyList: [PolicyItem] = []
    private var nextCursor: String = ""
    private var hasNext: Bool = false
    private var sortOrder: String = "latest"
    private var interestList: [String] = []
    private var readAllNotifications: Bool = false
    private var isInitialLoad: Bool = true
    private var isLoadingMore: Bool = false
    
    private let networkService = PolicyService()
    
    private let categoryMapping: [String: String] = [
        "JOBS": "일자리",
        "HOUSING": "주거",
        "EDUCATION": "교육",
        "WELFARE_CULTURE": "복지,문화",
        "PARTICIPATION_RIGHTS": "참여,권리"
    ]
    
    private let titleLabel: UILabel = {
        let label = UILabel()
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
        tableView.contentInset.bottom = 20
        return tableView
    }()
    
    private let emptyStateLabel = UILabel().then {
        $0.text = "정책이 존재하지 않습니다."
        $0.textAlignment = .center
        $0.textColor = .gray600
        $0.font = .ptdMediumFont(ofSize: 16)
        $0.isHidden = true
    }
    
    private lazy var interestDropdown = CustomDropdown(
        height: 36,
        fontSize: 14,
        title: "관심",
        hasBorder: false,
        items: []
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
        fetchInitialSetting()
    }

    private func setupLayout() {
        view.addSubviews(titleLabel, interestDropdown, sortDropdown, tableView, emptyStateLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(90)
            make.leading.trailing.equalToSuperview().inset(35)
        }
        
        interestDropdown.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(25)
            make.trailing.equalTo(sortDropdown.snp.leading).offset(-8)
            make.width.equalTo(105)
            make.height.equalTo(36)
        }

        sortDropdown.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(25)
            make.trailing.equalToSuperview().offset(-16)
            make.width.equalTo(91)
            make.height.equalTo(36)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(sortDropdown.snp.bottom).offset(16)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        emptyStateLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
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
    
    private func updateTitleLabel() {
        let localizedInterest = categoryMapping[interest] ?? interest
        let text = "\(userName)님께 딱 맞는 \(localizedInterest) 정책\n추천 리스트를 준비했어요!"
        
        
        let attributedText = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        paragraphStyle.alignment = .left
        
        attributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: text.count))
        
        if let range = text.range(of: localizedInterest) {
            let nsRange = NSRange(range, in: text)
            attributedText.addAttribute(.foregroundColor, value: AppColor.blue700!, range: nsRange)
        }
        
        titleLabel.attributedText = attributedText
        titleLabel.numberOfLines = 2
        titleLabel.sizeToFit()
    }
    
    private func fetchInitialSetting() {
        networkService.fetchRecommendPolicy(category: "JOBS", cursor: "", order: sortOrder) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                guard let response = response else { return  }
                
                self.readAllNotifications = response.readAllNotifications
                self.updateAlarmButtonIcon(isUnread: !response.readAllNotifications)
                
                self.userName = response.username ?? "사용자"
                
                self.interestList = response.interests ?? ["JOBS"]
                
                if let firstInterest = self.interestList.first {
                    self.interest = firstInterest
                }
                
                let localizedInterests = self.interestList.compactMap { self.categoryMapping[$0] ?? $0 }
                
                DispatchQueue.main.async {
                    self.interestDropdown.setItems(localizedInterests)
                    
                    // 첫 번째 아이템을 드롭다운 title로 설정
                    if !localizedInterests.isEmpty {
                        self.interestDropdown.setSelectItemForIndex(at: 0)
                    }
                    
                    self.updateTitleLabel()
                }
                
                self.isInitialLoad = false
                self.fetchRecommendPolicies(interest: self.interest, cursor: "", order: self.sortOrder)
                
            case .failure(let error):
                print("정책 추천 초기 세팅 API 실패: \(error.localizedDescription)")
            }
        }
    }
    
    private func fetchRecommendPolicies(interest: String, cursor: String, order: String) {
        if isLoadingMore && !cursor.isEmpty {
            return
        }
        
        if !cursor.isEmpty {
            isLoadingMore = true
        }
        
        networkService.fetchRecommendPolicy(category: interest, cursor: cursor, order: order) { [weak self] result in
            guard let self = self else { return }
            self.isLoadingMore = false
            
            switch result {
            case .success(let response):
                guard let response = response,
                      let policyContent = response.policies else { return }
                
                self.updateTitleLabel()
                
                let policies: [PolicyItem] = policyContent.compactMap { policy -> PolicyItem? in
                    guard let policyId = policy.policyId else { return nil }

                    return PolicyItem(
                        policyId: policyId,
                        policyName: policy.policyName ?? "제목 없음",
                        startDate: policy.startDate ?? "상시",
                        endDate: policy.endDate ?? "상시",
                        dday: policy.dday
                    )
                }
                
                self.policyList = (cursor == "") ? policies : self.policyList + policies
                self.nextCursor = response.nextCursor ?? ""
                self.hasNext = response.hasNext
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    let hasResults = self.policyList.isEmpty
                    self.emptyStateLabel.isHidden = !hasResults
                }
                
            case .failure(let error):
                print("❌ 정책 추천 API 실패: \(error.localizedDescription)")
            }
        }
    }
    
    func dropdown(_ dropdown: CustomDropdown, didSelectItem item: String) {
        if dropdown == interestDropdown {
            if let selectedKey = categoryMapping.first(where: { $0.value == item })?.key {
                if isInitialLoad {
                    return
                }
                
                // 이미 같은 카테고리면 무시
                guard interest != selectedKey else { return }
                
                interest = selectedKey
                
                DispatchQueue.main.async {
                    self.updateTitleLabel()
                    self.tableView.setContentOffset(.zero, animated: true)
                }
                
                AmplitudeManager.shared.trackFilterApply(
                    filterType: interest,
                    filterValue: sortOrder
                )
                
                fetchRecommendPolicies(interest: interest, cursor: "", order: sortOrder)
            }
        } else if dropdown == sortDropdown {
            let order = (item == "마감순") ? "deadline" : "latest"
            if sortOrder != order {
                sortOrder = order
                
                DispatchQueue.main.async {
                    self.tableView.setContentOffset(.zero, animated: true)
                }
                
                AmplitudeManager.shared.trackFilterApply(
                    filterType: interest,
                    filterValue: sortOrder
                )
                
                fetchRecommendPolicies(interest: interest, cursor: "", order: order)
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
        cell.selectedBackgroundView = UIView()
        cell.selectedBackgroundView?.backgroundColor = .clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedPolicy = policyList[indexPath.row]
        
        let detailVC = PolicyDetailViewController()
        detailVC.configureEntryPoint(.recommend)
        detailVC.policyId = selectedPolicy.policyId
        
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !isLoadingMore else { return }
        
        let contentOffsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.frame.size.height
        
        if contentOffsetY > contentHeight - scrollViewHeight - 100 {
            guard hasNext else { return }
            fetchRecommendPolicies(interest: interest, cursor: nextCursor, order: sortOrder)
        }
    }
}
