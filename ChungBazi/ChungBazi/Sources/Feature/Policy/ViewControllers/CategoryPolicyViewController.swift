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
    private var nextCursor: String?
    private var hasNext: Bool = false
    
    private lazy var sortDropdown = CustomDropdown(
        height: 36,
        fontSize: 14,
        title: "최신순",
        hasBorder: false,
        items: Constants.sortItems
    )

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(PolicyCardViewCell.self, forCellReuseIdentifier: PolicyCardViewCell.identifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        return tableView
    }()

    private let safeAreaBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.gray50

        addCustomNavigationBar(
            titleText: categoryTitle,
            showBackButton: true,
            showCartButton: false,
            showAlarmButton: true,
            showHomeRecommendTabs: false,
            backgroundColor: .white
        )
        setupSafeAreaBackground()
        setupLayout()
        configureTableView()
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
        view.addSubviews(sortDropdown, tableView)
        
        sortDropdown.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(90)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).offset(-16)
            $0.width.equalTo(91)
            $0.height.equalTo(36 * Constants.sortItems.count + 36 + 8)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(sortDropdown.snp.bottom).offset(-70)
            $0.leading.trailing.bottom.equalToSuperview()
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

    func configure(categoryTitle: String) {
        self.categoryTitle = categoryTitle
    }

    func fetchCategoryPolicy(category: String, cursor: Int) {
        networkService.fetchCategoryPolicy(category: category, cursor: cursor, order: "latest") { [weak self] result in
        guard let self = self else { return }
        switch result {
        case .success(let response):
            guard let response = response,
                    let policyContent = response.policies else { return }
                    
            let newPolicies: [PolicyItem] = policyContent.compactMap { data in
                guard let policyId = data.policyId,
                        let policyName = data.policyName,
                        let startDate = data.startDate,
                        let endDate = data.endDate,
                        let dday = data.dday else {
                    print("정책이 없습니다.")
                    return nil
                }
                return PolicyItem(policyId: policyId, policyName: policyName, startDate: startDate, endDate: endDate, dday: dday)
            }
                    
            if cursor != 0 {
                self.policyList.append(contentsOf: newPolicies)
            } else {
                self.policyList = newPolicies
            }

            self.nextCursor = response.nextCursor ?? ""
            self.hasNext = response.hasNext
                    
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }

            case .failure(let error):
                print("❌ 카테고리별 정책 조회 실패: \(error.localizedDescription)")
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
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedPolicy = policyList[indexPath.row]
        
        print("Selected policy: \(selectedPolicy.policyName)")

        let detailVC = PolicyDetailViewController()
        detailVC.policyId = selectedPolicy.policyId

        navigationController?.pushViewController(detailVC, animated: true)
    }
}
