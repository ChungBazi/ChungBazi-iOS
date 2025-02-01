//
//  SetInterestViewController.swift
//  ChungBazi
//

import UIKit

class SetInterestViewController: UIViewController {
    
    let userInfoData = UserInfoDataManager.shared
    let networkService = UserService()
    
    private var checkStatus: [Bool] // 체크 상태를 저장
    
    private lazy var baseSurveyView = BasicSurveyView(title: "관심 있는 분야를\n선택해주세요", logo: "sixthPageLogo").then {
        $0.backBtn.addTarget(self, action: #selector(goToback), for: .touchUpInside)
        $0.nextBtn.addTarget(self, action: #selector(goToFinish), for: .touchUpInside)
    }
    
    private lazy var checkCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then {
        $0.estimatedItemSize = .init(width: 120, height: 24)
        $0.minimumLineSpacing = 17
        $0.minimumInteritemSpacing = 4
    }).then {
        $0.register(CheckCollectionViewCell.self, forCellWithReuseIdentifier: CheckCollectionViewCell.identifier)
        $0.backgroundColor = .clear
        $0.isScrollEnabled = false
        $0.delegate = self
        $0.dataSource = self
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.checkStatus = Array(repeating: false, count: Constants.interestCheckMenu.count) // 초기 체크 상태
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        addComoponents()
        setConstraints()
    }
    
    private func addComoponents() {
        view.addSubview(baseSurveyView)
        baseSurveyView.addSubview(checkCollectionView)
    }
    
    private func setConstraints() {
        baseSurveyView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        checkCollectionView.snp.makeConstraints {
            $0.top.equalTo(baseSurveyView.title.snp.bottom).offset(57.5)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(65)
            $0.height.equalTo(350)
        }
    }
    
    private func updateNextButtonState() {
        let isAnyChecked = checkStatus.contains(true) // 하나라도 true가 있는지 확인
        baseSurveyView.nextBtn.setEnabled(isEnabled: isAnyChecked) // 버튼 활성화 상태 업데이트
    }
    
    @objc private func goToback() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func goToFinish() {
        let selectedInterests = Constants.interestCheckMenu.enumerated().compactMap { index, interest in
            checkStatus[index] ? interest : nil
        }
        // 싱글톤에 관심사 저장
        UserInfoDataManager.shared.setInterests(selectedInterests)
        
        registerUserInfo()
        let vc = FinishSurveyViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func registerUserInfo() {
        let userInfo = userInfoData.getUserInfo()
        let userInfoDTO = self.networkService.makeUserInfoDTO(region: userInfo.region, employment: userInfo.employment, income: userInfo.income, education: userInfo.education, interests: userInfo.interests, additionInfo: userInfo.additionInfo)
        self.networkService.postUserInfo(body: userInfoDTO) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                print(response)
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension SetInterestViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Constants.interestCheckMenu.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CheckCollectionViewCell.identifier, for: indexPath) as! CheckCollectionViewCell
        
        let isChecked = checkStatus[indexPath.row]
        cell.configure(contents: Constants.interestCheckMenu[indexPath.row], isChecked: isChecked, indexPath: indexPath, delegate: self)
        
        return cell
    }
}

extension SetInterestViewController: CheckCollectionViewCellDelegate {
    func cell(_ cell: CheckCollectionViewCell, didToggleCheckAt indexPath: IndexPath) {
        // 체크 상태 토글
        checkStatus[indexPath.row].toggle()
        checkCollectionView.reloadItems(at: [indexPath]) // UI 업데이트
        
        updateNextButtonState() // 버튼 활성화 상태 업데이트
    }
}

