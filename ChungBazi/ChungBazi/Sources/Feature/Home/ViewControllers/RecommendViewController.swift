//
//  RecommendViewController.swift
//  ChungBazi
//
//  Created by 엄민서 on 1/24/25.
//

import UIKit
import SnapKit
import Then

class RecommendViewController: UIViewController, CompactDropdownDelegate {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "바로님께 딱 맞는 주거 정책\n추천 리스트를 준비했어요!"
        label.numberOfLines = 2
        label.font = UIFont(name: AppFontName.pSemiBold, size: 20)
        label.textAlignment = .left
        label.textColor = .black
        
        let attributedText = NSMutableAttributedString(string: label.text ?? "")
        attributedText.addAttribute(.foregroundColor, value: AppColor.blue700, range: (label.text! as NSString).range(of: "주거"))
        label.attributedText = attributedText
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(PolicyCardViewCell.self, forCellReuseIdentifier: PolicyCardViewCell.identifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        return tableView
    }()
    
    private lazy var interestDropdown = CompactDropdown(
        title: "관심",
        hasBorder: false,
        items: Constants.interestItems
    )

    private lazy var sortDropdown = CompactDropdown(
        title: "최신순",
        hasBorder: false,
        items: Constants.sortItems
    )

    private var policies: [PolicyItem] = [
        PolicyItem(title: "<청년 주거 안정화 지원 사업>", region: "동작구", period: "2024.12.11 - 2025.01.31", badge: "D-3", policyId: 10),
        PolicyItem(title: "<청년 행복주택 입주 지원 프로그램>", region: "마포구", period: "2024.12.11 - 2025.01.31", badge: "D-11", policyId: 11),
        PolicyItem(title: "<서울 청년 주거 안전망 지원>", region: "성북구", period: "2024.12.11 - 2025.01.31", badge: "D-2", policyId: 12),
        PolicyItem(title: "<청년 주거 문제 해결을 위한 지원 정책>", region: "양천구", period: "2024.12.11 - 2025.01.31", badge: "마감", policyId: 13)
    ]

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
    }

    private func setupLayout() {
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(90)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        view.addSubview(interestDropdown)
        interestDropdown.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(160)
            make.width.equalTo(91)
            make.height.equalTo(36 * Constants.interestItems.count + 36 + 8)
        }

        view.addSubview(sortDropdown)
        sortDropdown.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.width.equalTo(91)
            make.height.equalTo(36 * Constants.sortItems.count + 36 + 8)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(sortDropdown.snp.bottom).offset(-80)
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

    // MARK: - CustomDropdownDelegate
    func dropdown(_ dropdown: CompactDropdown, didSelectItem item: String) {
        if dropdown == interestDropdown {
            print("관심 분야 선택: \(item)")
            
            guard let categoryPolicy = PolicyData.getPolicies(for: item) else { return }
            
            let categoryVC = CategoryPolicyViewController()
            categoryVC.configure(categoryTitle: categoryPolicy.title, policies: categoryPolicy.policies)
            navigationController?.pushViewController(categoryVC, animated: true)
        } else if dropdown == sortDropdown {
            print("Selected item: \(item)")
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension RecommendViewController: UITableViewDataSource, UITableViewDelegate {
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
        print("Selected policy: \(policies[indexPath.row].title)")
    }
}
