//
//  CategoryPolicyViewController.swift
//  ChungBazi
//

import UIKit
import SnapKit
import Then

class CategoryPolicyViewController: UIViewController {
    
    private let sortDropdown: CustomDropdown = CustomDropdown(
        title: "최신순",
        hasBorder: false,
        items: ["최신순", "마감순"]
    )

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(PolicyCardViewCell.self, forCellReuseIdentifier: PolicyCardViewCell.identifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        return tableView
    }()

    private var policies: [PolicyItem] = []
    private var categoryTitle: String = ""

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
        view.addSubview(sortDropdown)
        sortDropdown.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(90)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).offset(-16)
            $0.width.equalTo(91)
            $0.height.equalTo(36 * Constants.sortItems.count + 36 + 8)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(sortDropdown.snp.bottom).offset(-60)
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

    func configure(categoryTitle: String, policies: [PolicyItem] = []) {
        self.categoryTitle = categoryTitle
        self.policies = policies
            tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension CategoryPolicyViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return policies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PolicyCardViewCell.identifier, for: indexPath) as? PolicyCardViewCell else {
            return UITableViewCell()
        }
        let policy = policies[indexPath.row]
        cell.configure(with: policy, keyword: nil)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedPolicy = policies[indexPath.row]
        print("Selected policy: \(selectedPolicy.title)")
    }
}
