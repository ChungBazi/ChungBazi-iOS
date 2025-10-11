//
//  CartViewController.swift
//  ChungBazi
//

import UIKit
import SnapKit
import Then

final class CartViewController: UIViewController {
    
    private let networkService = CartService()
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
        button.setImage(UIImage(named: "checkbox_unchecked"), for: .normal)
        button.setImage(UIImage(named: "checkbox_checked"), for: .selected)
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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray50
        addCustomNavigationBar(
            titleText: "장바구니",
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
        scrollView.addSubview(contentView)
        contentView.addSubviews(headerView, tableView)
        
        guard let navigationBarView = self.view.subviews.first(where: { $0 is UIView }) else { return }
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(navigationBarView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
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
    
    public func postCart(policyId: Int) {
        networkService.postCart(policyId: policyId) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.fetchCartList()
                case .failure(let error):
                    print("❌ 장바구니 추가 실패: \(error.localizedDescription)")
                }
            }
        }
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
                }
            case .failure(let error):
                print("❌ 네트워크 요청 실패: \(error.localizedDescription)")
            }
        }
    }
    
    private func convertCartResponse(_ response: [CategoryPolicyList]) -> [String: [PolicyItem]] {
        var categorizedItems: [String: [PolicyItem]] = [:]
        
        response.forEach { categoryData in
            guard let categoryName = categoryData.categoryName else {
                print("⚠️ 카테고리 이름이 없습니다.")
                return
            }
            guard let cartPolicies = categoryData.cartPolicies else {
                print("⚠️ \(categoryName) 카테고리에 정책이 없습니다.")
                return
            }
            
            let policies: [PolicyItem] = cartPolicies.compactMap { policy in
                guard let policyId = policy.policyId,
                      let name = policy.name,
                      let startDate = policy.startDate,
                      let endDate = policy.endDate else { return nil }

                return PolicyItem(
                    policyId: policyId,
                    policyName: name,
                    startDate: startDate,
                    endDate: endDate,
                    dday: policy.dday ?? 0
                )
            }

            if !policies.isEmpty {
                categorizedItems[categoryName] = policies
            }
        }
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
    }

    @objc private func handleDeleteSelectedItems() {
        deleteCart()
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension CartViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return cartItems.keys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let category = Array(cartItems.keys)[section]
        return cartItems[category]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PolicyCardViewCell.identifier, for: indexPath) as? PolicyCardViewCell else {
            return UITableViewCell()
        }

        let category = Array(cartItems.keys)[indexPath.section]
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
        let category = Array(cartItems.keys)[section]

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

        let category = Array(cartItems.keys)[indexPath.section]
        guard let item = cartItems[category]?[indexPath.row] else { return }

        let vc = PolicyDetailViewController()
        vc.policyId = item.policyId
        navigationController?.pushViewController(vc, animated: true)
    }
}
