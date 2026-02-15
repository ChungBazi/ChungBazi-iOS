//
//  SetPlusViewController.swift
//  ChungBazi
//

import UIKit

class SetPlusViewController: UIViewController {
    
    let userInfoData = UserInfoDataManager.shared
    
    private var checkStatus: [Bool] // 체크 상태를 저장
    
    private lazy var baseSurveyView = BasicSurveyView(title: "추가사항을\n선택해주세요", logo: .thirdPageLogo).then {
        $0.backBtn.addTarget(self, action: #selector(goToback), for: .touchUpInside)
        $0.nextBtn.addTarget(self, action: #selector(goToSetIncome), for: .touchUpInside)
    }
    
    private lazy var checkCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then {
        $0.estimatedItemSize = .init(width: 120, height: 24)
        $0.minimumLineSpacing = 17
    }).then {
        $0.register(CheckCollectionViewCell.self, forCellWithReuseIdentifier: CheckCollectionViewCell.identifier)
        $0.backgroundColor = .clear
        $0.isScrollEnabled = false
        $0.delegate = self
        $0.dataSource = self
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.checkStatus = Array(repeating: false, count: Constants.plusCheckMenu.count) // 초기 체크 상태
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
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(127)
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
    
    @objc private func goToSetIncome() {
        let selectedPlus = Constants.plusCheckMenu.enumerated().compactMap { index, plus in
            checkStatus[index] ? plus : nil
        }
        // 싱글톤에 관심사 저장
        UserInfoDataManager.shared.setAdditionInfo(selectedPlus)
        
        let vc = SetIncomeLevelViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension SetPlusViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Constants.plusCheckMenu.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CheckCollectionViewCell.identifier, for: indexPath) as! CheckCollectionViewCell
        
        let isChecked = checkStatus[indexPath.row]
        cell.configure(contents: Constants.plusCheckMenu[indexPath.row], isChecked: isChecked, indexPath: indexPath, delegate: self)
        
        return cell
    }
}

extension SetPlusViewController: CheckCollectionViewCellDelegate {
    func cell(_ cell: CheckCollectionViewCell, didToggleCheckAt indexPath: IndexPath) {
        // 체크 상태 토글
        checkStatus[indexPath.row].toggle()
        checkCollectionView.reloadItems(at: [indexPath]) // UI 업데이트
        
        updateNextButtonState() // 버튼 활성화 상태 업데이트
    }
}
