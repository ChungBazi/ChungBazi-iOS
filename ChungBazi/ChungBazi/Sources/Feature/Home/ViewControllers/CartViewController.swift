//
//  CartViewController.swift
//  ChungBazi
//

import UIKit
import SnapKit

final class CartViewController: UIViewController {
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private var cartItems: [String: [PolicyItem]] = [:]
    private var selectedItems: Set<IndexPath> = []

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
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "trash_icon"), for: .normal)
        button.addTarget(self, action: #selector(handleDeleteSelectedItems), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray50
        setupNavigationBar()
        setupHeaderView()
        setupTableView()
        loadCartData()
    }

    private func setupNavigationBar() {
        addCustomNavigationBar(
            titleText: "장바구니",
            showBackButton: true,
            showCartButton: false,
            showAlarmButton: false,
            backgroundColor: .clear
        )
    }

    private func setupHeaderView() {
        headerView.backgroundColor = .clear
        view.addSubview(headerView)
        headerView.addSubviews(allSelectButton, deleteButton)

        headerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(65)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(48)
        }

        allSelectButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }

        deleteButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PolicyCardViewCell.self, forCellReuseIdentifier: PolicyCardViewCell.identifier)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none

        tableView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }

    private func loadCartData() {
        cartItems = [
            "일자리": [
                PolicyItem(title: "<노원구 1인가구 안심홈 3종 세트>", region: "노원구", period: "2024.12.11 - 2025.01.31", badge: "D-1")
            ],
            "주거": [
                PolicyItem(title: "<노원구 1인가구 안심홈 3종 세트>", region: "노원구", period: "2024.12.11 - 2025.01.31", badge: "D-5"),
                PolicyItem(title: "<노원구 1인가구 안심홈 3종 세트>", region: "노원구", period: "2024.12.11 - 2025.01.31", badge: "D-11")
            ]
        ]
        tableView.reloadData()
    }

    @objc private func handleAllSelect() {
        allSelectButton.isSelected.toggle()
        selectedItems.removeAll()

        if allSelectButton.isSelected {
            for section in 0..<cartItems.keys.count {
                for row in 0..<tableView.numberOfRows(inSection: section) {
                    selectedItems.insert(IndexPath(row: row, section: section))
                }
            }
        }
        tableView.reloadData()
    }

    @objc private func handleDeleteSelectedItems() {
        for indexPath in selectedItems.sorted(by: { $0.section > $1.section || ($0.section == $1.section && $0.row > $1.row) }) {
            deleteItem(at: indexPath)
        }
        selectedItems.removeAll()
        allSelectButton.isSelected = false
        tableView.reloadData()
    }

    private func deleteItem(at indexPath: IndexPath) {
        let category = Array(cartItems.keys)[indexPath.section]
        cartItems[category]?.remove(at: indexPath.row)
        if cartItems[category]?.isEmpty == true {
            cartItems.removeValue(forKey: category)
        }
    }
}

extension CartViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return cartItems.keys.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let category = Array(cartItems.keys)[section]
        return cartItems[category]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let category = Array(cartItems.keys)[section]

        let headerView = UIView().then {
            $0.backgroundColor = .clear
        }

        let separatorLine = DottedLineView().then {
            $0.backgroundColor = .clear
        }

        let titleLabel = UILabel().then {
            $0.text = category
            $0.font = UIFont(name: AppFontName.pSemiBold, size: 20)
            $0.textColor = .black
        }

        headerView.addSubview(separatorLine)
        separatorLine.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(8)
            make.height.equalTo(1)
        }

        headerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(32)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(separatorLine.snp.bottom).offset(16)
            make.bottom.equalToSuperview().offset(-8)
        }

        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PolicyCardViewCell.identifier, for: indexPath) as? PolicyCardViewCell else {
            return UITableViewCell()
        }

        let category = Array(cartItems.keys)[indexPath.section]
        if let item = cartItems[category]?[indexPath.row] {
            cell.configure(with: item, keyword: nil)
            cell.setCheckBoxState(isSelected: selectedItems.contains(indexPath))

            cell.selectionHandler = { [weak self] isSelected in
                guard let self = self else { return }
                if isSelected {
                    self.selectedItems.insert(indexPath)
                } else {
                    self.selectedItems.remove(indexPath)
                }
            }

            cell.deleteHandler = { [weak self] in
                guard let self = self else { return }
                self.deleteItem(at: indexPath)
                self.tableView.reloadData()
            }
            cell.showControls = true 
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 134
    }
}
