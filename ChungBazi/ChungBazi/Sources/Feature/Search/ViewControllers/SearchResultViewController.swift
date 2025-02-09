//
//  SearchResultViewController.swift
//  ChungBazi
//

import UIKit
import SnapKit
import Then

final class SearchResultViewController: UIViewController {
    
    private let searchView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
    }

    private let searchTextField = UITextField().then {
        $0.placeholder = "검색어를 입력하세요"
        $0.font = .ptdMediumFont(ofSize: 16)
        $0.textColor = .gray800
        $0.returnKeyType = .search
    }
    
    private let searchButton = UIButton(type: .system).then {
        $0.setImage(UIImage(named: "search_icon"), for: .normal)
        $0.tintColor = .gray800
    }
    
    private let popularSearchLabel = UILabel().then {
        $0.text = "인기 검색어"
        $0.textColor = .gray800
        $0.font = .ptdSemiBoldFont(ofSize: 20)
    }

    private lazy var popularKeywordsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        $0.itemSize = CGSize(width: UICollectionViewFlowLayout.automaticSize.width, height: 36)
        $0.minimumLineSpacing = 10
    }).then {
        $0.showsHorizontalScrollIndicator = false
        $0.backgroundColor = .clear
        $0.delegate = self
        $0.dataSource = self
        $0.register(PopularKeywordCell.self, forCellWithReuseIdentifier: PopularKeywordCell.identifier)
    }
    
    private lazy var sortDropdown = CustomDropdown(
        height: 36,
        fontSize: 14,
        title: "최신순",
        hasBorder: false,
        items: Constants.sortItems
    )

    private let tableView = UITableView().then {
        $0.register(PolicyCardViewCell.self, forCellReuseIdentifier: PolicyCardViewCell.identifier)
        $0.separatorStyle = .none
        $0.backgroundColor = .clear
    }
    
    private let emptyStateLabel = UILabel().then {
        $0.text = "검색 결과가 없습니다."
        $0.textAlignment = .center
        $0.textColor = .gray600
        $0.font = .ptdMediumFont(ofSize: 16)
        $0.isHidden = true
    }
    
    private let popularKeywords = ["일자리", "주거", "교육", "진로", "창업", "금융"]

    private var policies: [PolicyItem] = []
    private let allPolicies: [PolicyItem] = [
        PolicyItem(title: "<청년 신체 건강 챌린지! 운동 비용 지원>", region: "서초구", period: "2024.12.11 - 2025.01.31", badge: "D-21", policyId: 20),
        PolicyItem(title: "<청년 신체 건강 회복을 위한 피트니스 수강 지원>", region: "양천구", period: "2024.12.11 - 2025.01.31", badge: "D-17", policyId: 21),
        PolicyItem(title: "<청년 신체 건강 증진을 위한 피트니스 지원 프로그램>", region: "강남구", period: "2024.12.11 - 2025.01.31", badge: "마감", policyId: 22)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray50
        addCustomNavigationBar(
            titleText: "",
            showBackButton: true,
            showCartButton: true,
            showAlarmButton: true,
            showHomeRecommendTabs: false,
            backgroundColor: .gray50
        )
        setupLayout()
        setupActions()
        configureTableView()
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        sortDropdown.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    private func setupLayout() {
        view.addSubviews(searchView, popularSearchLabel, popularKeywordsCollectionView, sortDropdown, tableView, emptyStateLabel)

        searchView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(80)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(40)
        }

        searchView.addSubviews(searchTextField, searchButton)

        searchTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-40)
        }

        searchButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }

        popularSearchLabel.snp.makeConstraints { make in
            make.top.equalTo(searchView.snp.bottom).offset(32)
            make.leading.equalToSuperview().offset(18)
        }

        popularKeywordsCollectionView.snp.makeConstraints { make in
            make.top.equalTo(popularSearchLabel.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(36)
        }

        sortDropdown.snp.makeConstraints { make in
            make.top.equalTo(searchView.snp.bottom).offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.width.equalTo(91)
            make.height.equalTo(36 * Constants.sortItems.count + 36 + 8)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(sortDropdown.snp.bottom).offset(-70)
            make.leading.trailing.bottom.equalToSuperview()
        }

        emptyStateLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
        
    private func setupActions() {
        searchButton.addTarget(self, action: #selector(didTapSearch), for: .touchUpInside)
        searchTextField.delegate = self
    }

    @objc private func didTapSearch() {
        searchForKeyword(searchTextField.text)
    }

    private func searchForKeyword(_ keyword: String?) {
        guard let keyword = keyword?.trimmingCharacters(in: .whitespacesAndNewlines), !keyword.isEmpty else {
            policies = []
            updateUI()
            return
        }
        
        policies = allPolicies.filter { $0.title.contains(keyword) }
        popularSearchLabel.isHidden = true
        popularKeywordsCollectionView.isHidden = true
        tabBarController?.tabBar.isHidden = false
        sortDropdown.isHidden = policies.isEmpty
        updateUI()
    }
    
    private func updateUI() {
        emptyStateLabel.isHidden = !policies.isEmpty
        tableView.isHidden = policies.isEmpty
        tableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.bringSubviewToFront(sortDropdown)
    }
    
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
}

// MARK: - Collection View Delegate & Data Source
extension SearchResultViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return popularKeywords.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PopularKeywordCell.identifier, for: indexPath) as? PopularKeywordCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: popularKeywords[indexPath.item])
        return cell
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension SearchResultViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return policies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PolicyCardViewCell.identifier, for: indexPath) as? PolicyCardViewCell else {
            return UITableViewCell()
        }
        let policy = policies[indexPath.row]
        cell.configure(with: policy, keyword: searchTextField.text)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension SearchResultViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchForKeyword(textField.text)
        textField.resignFirstResponder()
        return true
    }
}
