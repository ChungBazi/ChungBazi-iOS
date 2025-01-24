//
//  RecommendViewController.swift
//  ChungBazi
//
//  Created by 엄민서 on 1/24/25.
//

import UIKit
import SnapKit

class RecommendViewController: UIViewController {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "OO님께 딱 맞는 주거 정책\n추천 리스트를 준비했어요!"
        label.numberOfLines = 2
        label.font = UIFont(name: AppFontName.pSemiBold, size: 20)
        label.textAlignment = .left
        label.textColor = .black
        
        let attributedText = NSMutableAttributedString(string: label.text ?? "")
        attributedText.addAttribute(.foregroundColor, value: AppColor.blue700, range: (label.text! as NSString).range(of: "주거"))
        label.attributedText = attributedText
        return label
    }()
    
    private let interestButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("관심", for: .normal)
        button.titleLabel?.font = UIFont(name: AppFontName.pMedium, size: 14)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = AppColor.gray100
        button.layer.cornerRadius = 10
        button.snp.makeConstraints { make in
            make.width.equalTo(91)
            make.height.equalTo(36)
        }
        return button
    }()
    
    private let sortButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("최신순", for: .normal)
        button.titleLabel?.font = UIFont(name: AppFontName.pMedium, size: 14)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = AppColor.gray100
        button.layer.cornerRadius = 10
        button.snp.makeConstraints { make in
            make.width.equalTo(91)
            make.height.equalTo(36)
        }
        return button
    }()
    
    private let tableView = UITableView()

    private var policies: [PolicyItem] = [
        PolicyItem(title: "<청년 주거 안정화 지원 사업>", region: "동작구", period: "2024-12-11 ~ 2025-01-31", badge: "D-3"),
        PolicyItem(title: "<청년 행복주택 입주 지원 프로그램>", region: "마포구", period: "2024-12-11 ~ 2025-01-31", badge: "D-11"),
        PolicyItem(title: "<서울 청년 주거 안전망 지원>", region: "성북구", period: "2024-12-11 ~ 2025-01-31", badge: "D-2"),
        PolicyItem(title: "<청년 주거 문제 해결을 위한 지원 정책>", region: "양천구", period: "2024-12-11 ~ 2025-01-31", badge: "마감")
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
        
        setupLayout()
        configureTableView()
        setupDropdownActions()
    }
    
    private func setupLayout() {
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(90)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        let filterStackView = UIStackView(arrangedSubviews: [interestButton, sortButton])
        filterStackView.axis = .horizontal
        filterStackView.spacing = 8
        filterStackView.alignment = .fill
        filterStackView.distribution = .fillEqually

        view.addSubview(filterStackView)
        filterStackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(40)
        }

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(filterStackView.snp.bottom).offset(16)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    private func configureTableView() {
        tableView.register(PolicyTableViewCell.self, forCellReuseIdentifier: "PolicyTableViewCell")
        tableView.dataSource = self
        tableView.separatorStyle = .none
    }

    private func setupDropdownActions() {
        interestButton.addTarget(self, action: #selector(handleInterestDropdown), for: .touchUpInside)
        sortButton.addTarget(self, action: #selector(handleSortDropdown), for: .touchUpInside)
    }

    @objc private func handleInterestDropdown() {
        let alertController = UIAlertController(title: "관심 카테고리", message: nil, preferredStyle: .actionSheet)
        let categories = ["일자리", "주거", "교육", "복지,문화", "참여,권리"]
        
        categories.forEach { category in
            alertController.addAction(UIAlertAction(title: category, style: .default, handler: { _ in
                print("\(category) 선택됨")
                self.filterPolicies(by: category)
            }))
        }
        
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alertController, animated: true)
    }

    @objc private func handleSortDropdown() {
        let alertController = UIAlertController(title: "정렬 기준", message: nil, preferredStyle: .actionSheet)
        let sortOptions = ["최신순", "마감순"]
        
        sortOptions.forEach { option in
            alertController.addAction(UIAlertAction(title: option, style: .default, handler: { _ in
                print("\(option) 선택됨")
            }))
        }
        
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alertController, animated: true)
    }
    
    private func filterPolicies(by category: String) {
        print("\(category) 카테고리에 따라 필터링")
    }
}

// MARK: - UITableViewDataSource
extension RecommendViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return policies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PolicyTableViewCell", for: indexPath) as? PolicyTableViewCell else {
            return UITableViewCell()
        }
        let policy = policies[indexPath.row]
        cell.configure(with: policy)
        return cell
    }
}
