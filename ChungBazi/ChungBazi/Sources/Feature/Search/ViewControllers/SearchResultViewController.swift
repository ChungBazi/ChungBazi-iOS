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
    private var sortOrder: String = "latest"
    
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
        $0.contentMode = .scaleAspectFit
        $0.tintColor = .gray500
    }
    
    private let popularSearchLabel = UILabel().then {
        $0.text = "인기 검색어"
        $0.textColor = .gray800
        $0.font = .ptdSemiBoldFont(ofSize: 20)
    }

    private lazy var popularKeywordsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 9
        layout.minimumLineSpacing = 9
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isUserInteractionEnabled = true
        collectionView.delaysContentTouches = false
        collectionView.canCancelContentTouches = false
        collectionView.register(PopularKeywordCell.self, forCellWithReuseIdentifier: PopularKeywordCell.identifier)
        return collectionView
    }()
    
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
    
    private lazy var sortDropdown = CustomDropdown(
        height: 36,
        fontSize: 14,
        title: "최신순",
        hasBorder: false,
        items: Constants.sortItems
    ).then {
        $0.delegate = self
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
        popularKeywordsCollectionView.delegate = self
        popularKeywordsCollectionView.dataSource = self
        popularKeywordsCollectionView.isUserInteractionEnabled = true
        popularKeywordsCollectionView.register(PopularKeywordCell.self, forCellWithReuseIdentifier: PopularKeywordCell.identifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = policyList.isEmpty
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
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(40)
        }

        searchButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }

        popularSearchLabel.snp.makeConstraints { make in
            make.top.equalTo(searchView.snp.bottom).offset(32)
            make.leading.equalToSuperview().offset(18)
        }

        popularKeywordsCollectionView.snp.makeConstraints { make in
            make.top.equalTo(popularSearchLabel.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(100)
        }

        sortDropdown.snp.makeConstraints {
            $0.top.equalTo(searchView.snp.top).offset(60)
            $0.trailing.equalToSuperview().inset(16)
            $0.width.equalTo(91)
            $0.height.equalTo(36 * Constants.sortItems.count + 36 + 8)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(sortDropdown.snp.bottom).inset(65)
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
    
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.bringSubviewToFront(sortDropdown)
        view.bringSubviewToFront(popularKeywordsCollectionView)
    }
    
    @objc private func didTapSearch() {
        executeSearch()
    }

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
                    self.tableView.reloadData()
                    self.tableView.setContentOffset(.zero, animated: true)
                }
            case .failure(let error):
                print("❌ 정책 검색 실패: \(error.localizedDescription)")
            }
        }
    }

    private func fetchPopularSearchText() {
        networkService.fetchPopularSearchText { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                self.popularKeywords = response?.keywords ?? []
                DispatchQueue.main.async {
                    self.popularKeywordsCollectionView.reloadData()
                    self.popularKeywordsCollectionView.setContentOffset(.zero, animated: true)
                }
            case .failure(let error):
                print("❌ 인기 검색어 불러오기 실패: \(error.localizedDescription)")
            }
        }
    }

    private func updateUI() {
        let hasResults = !policyList.isEmpty
        emptyStateLabel.isHidden = hasResults
        tableView.isHidden = !hasResults
        popularSearchLabel.isHidden = true
        popularKeywordsCollectionView.isHidden = true
        popularKeywordsCollectionView.isUserInteractionEnabled = true
        sortDropdown.isHidden = !hasResults
        tableView.reloadData()
        tabBarController?.tabBar.isHidden = !hasResults
    }
    
    private func executeSearch() {
        guard let query = searchTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), query.count >= 2 else {
            showCharacterLimitAlert()
            return
        }
        searchTextField.resignFirstResponder()
        searchPolicy(name: query, cursor: "")
    }
    
    private func showCharacterLimitAlert() {
        let alert = UIAlertController(title: "", message: "검색어를 2자 이상 입력해 주세요.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UITextFieldDelegate
extension SearchResultViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        executeSearch()
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
        cell.selectedBackgroundView = UIView()
        cell.selectedBackgroundView?.backgroundColor = .clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedPolicy = policyList[indexPath.row]
        
        let detailVC = PolicyDetailViewController()
        detailVC.policyId = selectedPolicy.policyId
        
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension SearchResultViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return popularKeywords.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PopularKeywordCell.identifier, for: indexPath) as! PopularKeywordCell
        cell.configure(with: popularKeywords[indexPath.item])
        cell.selectedBackgroundView = UIView()
        cell.selectedBackgroundView?.backgroundColor = .clear
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let keyword = popularKeywords[indexPath.item]
        searchTextField.text = keyword
        tableView.isHidden = false
        DispatchQueue.main.async {
            self.executeSearch()
        }
    }
}

// MARK: - CustomDropdownDelegate
extension SearchResultViewController: CustomDropdownDelegate {
    func dropdown(_ dropdown: CustomDropdown, didSelectItem item: String) {
        sortOrder = (item == "마감순") ? "deadline" : "latest"
        executeSearch()
    }
}

extension SearchResultViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let keyword = popularKeywords[indexPath.item]
        
        let label = UILabel()
        label.text = keyword
        label.font = .systemFont(ofSize: 14)
        label.sizeToFit()
        
        let maxWidth = collectionView.frame.width - 32
        let itemWidth = min(label.frame.width + 24, maxWidth) 
        let itemHeight: CGFloat = 36

        return CGSize(width: itemWidth, height: itemHeight)
    }
}
