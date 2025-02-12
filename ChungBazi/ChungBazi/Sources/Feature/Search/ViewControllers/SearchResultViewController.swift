//
//  SearchResultViewController.swift
//  ChungBazi
//

import UIKit
import SnapKit
import Then

final class SearchResultViewController: UIViewController {
    
    private let networkService = PolicyService()
    private var policyList: [PolicyItem] = []
    private var popularKeywords: [String] = []
    private var nextCursor: String = ""
    private var hasNext: Bool = false
    
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
        fetchPopularSearchText()
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
        view.addSubviews(searchView, popularSearchLabel, popularKeywordsCollectionView, tableView, emptyStateLabel)

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

        tableView.snp.makeConstraints { make in
            make.top.equalTo(popularKeywordsCollectionView.snp.bottom).offset(16)
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
        searchPolicy(name: searchTextField.text ?? "", cursor: "")
    }

    // 🔹 정책 검색 API 호출
    private func searchPolicy(name: String, cursor: String) {
        networkService.searchPolicy(name: name, cursor: cursor, order: "latest") { [weak self] result in
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

                if cursor.isEmpty {
                    self.policyList = newPolicies
                } else {
                    self.policyList.append(contentsOf: newPolicies)
                }

                self.nextCursor = response.nextCursor ?? ""
                self.hasNext = response.hasNext

                DispatchQueue.main.async {
                    self.updateUI()
                }
            case .failure(let error):
                print("❌ 정책 검색 실패: \(error.localizedDescription)")
            }
        }
    }

    // 🔹 인기 검색어 API 호출
    private func fetchPopularSearchText() {
        networkService.fetchPopularSearchText { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                self.popularKeywords = response?.keywords ?? []
                DispatchQueue.main.async {
                    self.popularKeywordsCollectionView.reloadData()
                }
            case .failure(let error):
                print("❌ 인기 검색어 불러오기 실패: \(error.localizedDescription)")
            }
        }
    }

    private func updateUI() {
        emptyStateLabel.isHidden = !policyList.isEmpty
        tableView.isHidden = policyList.isEmpty
        tableView.reloadData()
    }

    // 🔹 스크롤 하단 도착 시 다음 페이지 불러오기
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.frame.size.height

        if position > contentHeight - scrollViewHeight, hasNext {
            searchPolicy(name: searchTextField.text ?? "", cursor: nextCursor)
        }
    }

    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
}

//// MARK: - Collection View Delegate & Data Source
//extension SearchResultViewController: UICollectionViewDelegate, UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return popularKeywords.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PopularKeywordCell.identifier, for: indexPath) as? PopularKeywordCell else {
//            return UICollectionViewCell()
//        }
//        cell.configure(with: popularKeywords[indexPath.item])
//        return cell
//    }
//}

// MARK: - UITextFieldDelegate
extension SearchResultViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchPolicy(name: textField.text ?? "", cursor: "")
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension SearchResultViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return policyList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PolicyCardViewCell.identifier, for: indexPath) as? PolicyCardViewCell else {
            return UITableViewCell()
        }
        let policy = policyList[indexPath.row]
        cell.configure(with: policy, keyword: searchTextField.text)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension SearchResultViewController: UICollectionViewDataSource, UICollectionViewDelegate {
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
