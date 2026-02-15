//
//  CartViewController.swift
//  ChungBazi
//

import UIKit
import SnapKit
import Then

final class CartViewController: UIViewController {
    
    private let networkService = CartService()
    private var categories: [String] = []
    private var cartItems: [String: [PolicyItem]] = [:]
    private var selectedItems: Set<Int> = []
    private var categoryExpansionState: [String: Bool] = [:]

    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
    }
    private let contentView = UIView()
    private let headerView = UIView()

    private let allSelectButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(resource: .checkboxUnchecked), for: .normal)
        button.setImage(UIImage(resource: .checkboxChecked), for: .selected)
        button.setTitle(" 전체선택", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont(name: AppFontName.pMedium, size: 16)
        button.addTarget(self, action: #selector(handleAllSelect), for: .touchUpInside)
        return button
    }()

    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("선택삭제", for: .normal)
        button.setTitleColor(.gray300, for: .normal)
        button.titleLabel?.font = UIFont(name: AppFontName.pMedium, size: 16)
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleDeleteSelectedItems), for: .touchUpInside)
        return button
    }()

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(PolicyCardViewCell.self, forCellReuseIdentifier: PolicyCardViewCell.identifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.estimatedRowHeight = 200
        tableView.allowsSelection = false
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    private let emptyStateLabel = UILabel().then {
        $0.text = "담은 정책이 없습니다."
        $0.textAlignment = .center
        $0.textColor = .gray600
        $0.font = .ptdMediumFont(ofSize: 16)
        $0.isHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray50
        addCustomNavigationBar(
            titleText: "저장한 정책",
            showBackButton: true,
            showCartButton: false,
            showAlarmButton: false,
            backgroundColor: .clear
        )
        setupScrollView()
        configureTableView()
        fetchCartList()
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubviews(contentView, emptyStateLabel)
        contentView.addSubviews(headerView, tableView)
        
        guard let navigationBarView = self.view.subviews.first(where: { $0 is UIView }) else { return }
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(navigationBarView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        emptyStateLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        setupHeaderView()
        setupTableView()
    }

    private func setupHeaderView() {
        headerView.backgroundColor = .clear
        headerView.addSubviews(allSelectButton, deleteButton)

        headerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(48)
        }

        allSelectButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }

        deleteButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupTableView() {
        tableView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).inset(16)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
            make.bottom.equalToSuperview()
        }
        
        
    }

    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = true
    }
    
    @objc private func handleAllSelect() {
        let allPolicyIds = cartItems.values.flatMap { $0.map { $0.policyId } }
        
        if selectedItems.count == allPolicyIds.count {
            selectedItems.removeAll()
        } else {
            selectedItems = Set(allPolicyIds)
        }
        
        allSelectButton.isSelected = selectedItems.count == allPolicyIds.count
        updateDeleteButtonState()
        tableView.reloadData()
    }
    
    private func updateDeleteButtonState() {
        deleteButton.isEnabled = !selectedItems.isEmpty
        deleteButton.setTitleColor(selectedItems.isEmpty ? .gray300 : .blue700, for: .normal)
    }
    
    public func deleteCart() {
        guard !selectedItems.isEmpty else {
            print("❌ 삭제할 항목이 없습니다.")
            return
        }
        
        let deleteRequest = DeleteCartRequestDto(deleteList: Array(selectedItems))
        
        networkService.deleteCart(body: deleteRequest) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.selectedItems.removeAll()
                    self.updateDeleteButtonState()
                    self.fetchCartList()
                case .failure(let error):
                    print("❌ 장바구니 삭제 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func fetchCartList() {
        networkService.fetchCartList { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                guard let data = response else { return }
                self.cartItems = self.convertCartResponse(data)
                self.categoryExpansionState = self.cartItems.keys.reduce(into: [:]) { $0[$1] = false }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.updateTableViewHeight()
                    let hasResults = self.categories.isEmpty
                    self.emptyStateLabel.isHidden = !hasResults
                }
            case .failure(let error):
                print("❌ 네트워크 요청 실패: \(error.localizedDescription)")
            }
        }
    }
    
    private func convertCartResponse(_ response: [CategoryPolicyList]) -> [String: [PolicyItem]] {
        var categorizedItems: [String: [PolicyItem]] = [:]
        var orderedCategories: [String] = [] // 카테고리 순서 저장 배열
        
        response.forEach { categoryData in
            guard let categoryName = categoryData.categoryName else {
                print("⚠️ 카테고리 이름이 없습니다.")
                return
            }
            guard let cartPolicies = categoryData.cartPolicies else {
                print("⚠️ \(categoryName) 카테고리에 정책이 없습니다.")
                return
            }
            
            let policies: [PolicyItem] = cartPolicies.compactMap { policy -> PolicyItem? in
                guard let policyId = policy.policyId else { return nil }

                return PolicyItem(
                    policyId: policyId,
                    policyName: policy.name ?? "제목 없음",
                    startDate: policy.startDate ?? "상시",
                    endDate: policy.endDate ?? "상시",
                    dday: policy.dday
                )
            }

            if !policies.isEmpty {
                categorizedItems[categoryName] = policies
                orderedCategories.append(categoryName)
            }
        }
        
        self.categories = orderedCategories
        return categorizedItems
    }

    private func updateTableViewHeight() {
        let totalRows = cartItems.values.reduce(0) { $0 + $1.count }
        let rowHeight: CGFloat = 200
        let headerHeight: CGFloat = CGFloat(cartItems.count) * 70
        let totalHeight = CGFloat(totalRows) * rowHeight + headerHeight

        tableView.snp.updateConstraints { make in
            make.height.equalTo(totalHeight)
        }
        
        view.layoutIfNeeded()
    }

    @objc private func handleDeleteSelectedItems() {
        deleteCart()
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension CartViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section < categories.count else { return 0 }
        let category = categories[section]
        return cartItems[category]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PolicyCardViewCell.identifier, for: indexPath) as? PolicyCardViewCell else {
            return UITableViewCell()
        }

        let category = categories[indexPath.section]
        if let item = cartItems[category]?[indexPath.row] {
            cell.configure(with: item, keyword: nil)
            cell.selectedBackgroundView = UIView()
            cell.selectedBackgroundView?.backgroundColor = .clear
            cell.setCheckBoxState(isSelected: selectedItems.contains(item.policyId))

            cell.selectionHandler = { [weak self] isSelected in
                guard let self = self else { return }
                if isSelected {
                    self.selectedItems.insert(item.policyId)
                } else {
                    self.selectedItems.remove(item.policyId)
                }
                self.updateDeleteButtonState()
            }
        }
        cell.showControls = true
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let category = categories[section]

        let categoryView = CartCategoryView()
        categoryView.configure(with: category)

        categoryView.layoutIfNeeded()
        return categoryView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }
}

extension CartViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let category = categories[indexPath.section]
        guard let item = cartItems[category]?[indexPath.row] else { return }

        let vc = PolicyDetailViewController()
        vc.configureEntryPoint(.saved)
        vc.policyId = item.policyId
        navigationController?.pushViewController(vc, animated: true)
    }
}
