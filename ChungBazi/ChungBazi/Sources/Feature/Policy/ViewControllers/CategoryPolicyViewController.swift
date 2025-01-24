//
//  CategoryPolicyViewController.swift
//  ChungBazi
//

import UIKit
import SnapKit

class CategoryPolicyViewController: UIViewController {
    var category: CategoryItem?

    private let tableView = UITableView()
    private var policies: [PolicyItem] = [] 

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addCustomNavigationBar(
            titleText: category?.title,
            showBackButton: true,
            showCartButton: false,
            showAlarmButton: false
        )
        setupTableView()
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        tableView.register(PolicyTableViewCell.self, forCellReuseIdentifier: "PolicyTableViewCell")
        tableView.dataSource = self
    }
}

extension CategoryPolicyViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return policies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PolicyTableViewCell", for: indexPath) as? PolicyTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(with: policies[indexPath.row])
        return cell
    }
}
