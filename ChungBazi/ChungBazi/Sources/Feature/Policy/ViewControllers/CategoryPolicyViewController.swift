//
//  CategoryPolicyViewController.swift
//  ChungBazi
//

import UIKit
import SnapKit
import Then

final class CategoryPolicyViewController: UIViewController {
    
    private let networkService = PolicyService()
    private var policyList: [PolicyItem] = []
    private var categoryTitle: String?
    private var nextCursor: String = ""
    private var hasNext: Bool = false
    private var sortOrder: String = "latest"
    private var categoryKey: String?
    private var isLoadingMore: Bool = false

    private lazy var sortDropdown = CustomDropdown(
        height: 36,
        fontSize: 14,
        title: "최신순",
        hasBorder: false,
        items: ["최신순", "마감순"]
    )

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(PolicyCardViewCell.self, forCellReuseIdentifier: PolicyCardViewCell.identifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.contentInset.bottom = 20
        return tableView
    }()
    
    private let emptyView = EmptyBaroWithTitleView(title: "정책이 비어 있어요")

    private let safeAreaBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AmplitudeManager.shared.trackPolicyListView(entryPoint: categoryKey ?? "unknown")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.gray50

        addCustomNavigationBar(
            titleText: categoryTitle,
            showBackButton: true,
            showCartButton: false,
            showAlarmButton: false,
            showHomeRecommendTabs: false,
            backgroundColor: .white
        )
        setupSafeAreaBackground()
        setupLayout()
        configureTableView()
        configureDropdown()
        
        if let categoryKey = categoryKey {
            fetchCategoryPolicy(category: categoryKey, cursor: "", order: sortOrder)
        }
    }

    private func setupSafeAreaBackground() {
        view.addSubview(safeAreaBackgroundView)
        safeAreaBackgroundView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
    }
    
    private func setupLayout() {
        view.addSubviews(sortDropdown, tableView, emptyView)
        
        sortDropdown.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(90)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).offset(-16)
            $0.width.equalTo(91)
            $0.height.equalTo(36)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(sortDropdown.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        emptyView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.bringSubviewToFront(sortDropdown)
    }
    
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }

    private func configureDropdown() {
        sortDropdown.delegate = self
    }
    
    func configure(categoryTitle: String, categoryKey: String) {
        self.categoryTitle = categoryTitle
        self.categoryKey = categoryKey
    }

    func fetchCategoryPolicy(category: String, cursor: String, order: String) {
        if isLoadingMore && !cursor.isEmpty {
            return
        }
        
        if !cursor.isEmpty {
            isLoadingMore = true
        }
        
        networkService.fetchCategoryPolicy(category: category, cursor: cursor, order: order) { [weak self] result in
            guard let self = self else { return }
            self.isLoadingMore = false
            
            switch result {
            case .success(let response):
                guard let response = response,
                      let policyContent = response.policies else { return }
                
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
                
                if cursor.isEmpty {
                    self.policyList = policies
                } else {
                    self.policyList.append(contentsOf: policies)
                }
                
                self.nextCursor = response.nextCursor ?? ""
                self.hasNext = response.hasNext
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    let hasResults = self.policyList.isEmpty
                    self.emptyView.isHidden = !hasResults
                }
                
            case .failure(let error):
                showCustomAlert(title: "정책을 불러오는 데 실패하였습니다.\n다시 시도해주세요.", buttonText: "확인")
            }
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension CategoryPolicyViewController: UITableViewDataSource, UITableViewDelegate {
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
        
        print("Selected policy: \(selectedPolicy.policyName)")

        let detailVC = PolicyDetailViewController()
        detailVC.configureEntryPoint(.category)
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
            if let categoryKey = categoryKey {
                fetchCategoryPolicy(category: categoryKey, cursor: nextCursor, order: sortOrder)
            }
        }
    }
}

// MARK: - CustomDropdownDelegate
extension CategoryPolicyViewController: CustomDropdownDelegate {
    func dropdown(_ dropdown: CustomDropdown, didSelectItem item: String) {
        if dropdown == sortDropdown {
            let order = (item == "마감순") ? "deadline" : "latest"
            if sortOrder != order {
                sortOrder = order
                DispatchQueue.main.async {
                    self.tableView.setContentOffset(.zero, animated: true)
                }
                if let categoryKey = categoryKey {
                    
                    AmplitudeManager.shared.trackFilterApply(
                        filterType: nil,
                        filterValue: sortOrder
                    )
                    
                    fetchCategoryPolicy(category: categoryKey, cursor: "", order: sortOrder)
                }
            }
        }
    }
}
