//
//  SearchResultViewController.swift
//  ChungBazi
//

import UIKit
import SnapKit

class SearchResultViewController: UIViewController {
        
    private let searchView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        return view
    }()

    private let searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "검색어를 입력하세요"
        textField.font = UIFont(name: AppFontName.pMedium, size: 16)
        textField.textColor = AppColor.gray800
        textField.returnKeyType = .search
        return textField
    }()
    
    private let searchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "search_icon"), for: .normal)
        button.tintColor = AppColor.gray800
        return button
    }()
    
    private let popularSearchLabel: UILabel = {
        let label = UILabel()
        label.text = "인기 검색어"
        label.textColor = AppColor.gray800
        label.font = UIFont(name: AppFontName.pSemiBold, size: 20)
        return label
    }()

    private lazy var popularKeywordsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.itemSize = CGSize(width: UICollectionViewFlowLayout.automaticSize.width, height: 36)
        layout.minimumLineSpacing = 10
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PopularKeywordCell.self, forCellWithReuseIdentifier: PopularKeywordCell.identifier)
        return collectionView
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(PolicyCardViewCell.self, forCellReuseIdentifier: PolicyCardViewCell.identifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        return tableView
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "검색 결과가 없습니다."
        label.textAlignment = .center
        label.textColor = AppColor.gray600
        label.font = UIFont(name: AppFontName.pMedium, size: 16)
        label.isHidden = true
        return label
    }()
    
    private let popularKeywords = ["일자리", "주거", "교육", "진로", "창업", "금융"]

    private var policies: [PolicyItem] = []
    private let allPolicies: [PolicyItem] = [
        PolicyItem(title: "<청년 신체 건강 챌린지! 운동 비용 지원>", region: "서초구", period: "2024.12.11 - 2025.01.31", badge: "D-21"),
        PolicyItem(title: "<청년 신체 건강 회복을 위한 피트니스 수강 지원>", region: "양천구", period: "2024.12.11 - 2025.01.31", badge: "D-17"),
        PolicyItem(title: "<청년 신체 건강 증진을 위한 피트니스 지원 프로그램>", region: "강남구", period: "2024.12.11 - 2025.01.31", badge: "마감")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.gray50
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
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    private func setupLayout() {
        view.addSubview(searchView)
        searchView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(90)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(40)
        }
        
        searchView.addSubview(searchTextField)
        searchTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-40)
        }
        
        searchView.addSubview(searchButton)
        searchButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        view.addSubview(popularSearchLabel)
        popularSearchLabel.snp.makeConstraints { make in
            make.top.equalTo(searchView.snp.bottom).offset(32)
            make.leading.equalToSuperview().offset(18)
        }
            
        view.addSubview(popularKeywordsCollectionView)
        popularKeywordsCollectionView.snp.makeConstraints { make in
            make.top.equalTo(popularSearchLabel.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(36)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchView.snp.bottom).offset(16)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        view.addSubview(emptyStateLabel)
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
        updateUI()
    }
    
    private func updateUI() {
        emptyStateLabel.isHidden = !policies.isEmpty
        tableView.isHidden = policies.isEmpty
        tableView.reloadData()
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
        print("Selected Policy: \(policies[indexPath.row].title)")
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
