//
//  MyCharacterViewController.swift
//  ChungBazi
//
//  Created by 이현주 on 2/9/25.
//

import UIKit

class MyCharacterViewController: UIViewController, UIScrollViewDelegate {
    
    let networkService = CharacterService()
    var myCharacterList: [MyCharacterList] = []
    
    private lazy var mainCharacterView = MainCharacterView()
    
    private lazy var getCharacterListView = GetCharacterListView().then {
        $0.GetCharacterCollectionView.delegate = self
        $0.GetCharacterCollectionView.dataSource = self
    }
    
    private lazy var scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
    }
    
    private lazy var contentView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue700
        setNavBar()
        addViews()
        setConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        fetchMainCharacter()
        fetchCharacterList()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if myCharacterList.contains { !$0.open } {
            showCustomAlert(
                title: "레벨업 완료!\n새로운 캐릭터가 열렸습니다.\n카드를 눌러 확인해보세요!",
                buttonText: "좋아요",
                image: .confetti
            )
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    private func setNavBar() {
        addCustomNavigationBar(titleText: "마이 캐릭터", tintColor: .white, showBackButton: true, showCartButton: false, showAlarmButton: false, backgroundColor: .blue700)
        fillSafeArea(position: .top, color: .blue700)
    }
    
    private func addViews() {
        scrollView.delegate = self
        scrollView.contentInsetAdjustmentBehavior = .never
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        [mainCharacterView, getCharacterListView].forEach { contentView.addSubview($0) }
    }
    
    private func setConstraints() {
        scrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(Constants.navigationHeight)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView)
            $0.width.equalTo(scrollView.snp.width)
            $0.bottom.equalTo(getCharacterListView.snp.bottom)
        }
        
        mainCharacterView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
        }
        
        getCharacterListView.snp.makeConstraints {
            $0.top.equalTo(mainCharacterView.snp.bottom).offset(-15)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let maxOffsetY = scrollView.contentSize.height - scrollView.bounds.height
        if scrollView.contentOffset.y > maxOffsetY {
            scrollView.contentOffset.y = maxOffsetY
        }
    }
    
    private func fetchMainCharacter() {
        networkService.fetchMainCharacter { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                guard let response = response else { return }
                guard let nowLevel = CharacterImage.levelMapping[response.rewardLevel] else { return }
                guard let nextRewardLevel = response.nextRewardLevel else { return }
                guard let nextLevel = CharacterImage.levelMapping[nextRewardLevel] else { return }
                
                mainCharacterView.updateMyLevel(nickname: response.name, level: nowLevel)
                response.nextRewardLevel == nil ? mainCharacterView.maxLevelState() : ()
                mainCharacterView.updateNextLevel(nextLevel: nextLevel, remainPost: response.posts, remainComment: response.comments)
                mainCharacterView.updateCharacterAndStage(characterImage: response.rewardLevel, stageLevel: nowLevel)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func fetchCharacterList() {
        networkService.fetchCharacterList { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                myCharacterList = response
                    .map { MyCharacterList(rewardLevel: $0.rewardLevel, open: $0.open) }
                DispatchQueue.main.async {
                    self.getCharacterListView.GetCharacterCollectionView.reloadData()
                }
            case .failure(let response):
                print(response)
            }
        }
    }
    
    private func updateOpenCharacter(selectedLevel: String, completion: @escaping (Bool) -> Void) {
        networkService.updateOpenCharacter(selectedLevel: selectedLevel) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self.getCharacterListView.GetCharacterCollectionView.reloadData()
                }
                guard let response = response else { return }
                guard let nowLevel = CharacterImage.levelMapping[response.rewardLevel] else { return }
                guard let nextRewardLevel = response.nextRewardLevel else { return }
                guard let nextLevel = CharacterImage.levelMapping[nextRewardLevel] else { return }
                
                mainCharacterView.updateMyLevel(nickname: response.name, level: nowLevel)
                response.nextRewardLevel == nil ? mainCharacterView.maxLevelState() : ()
                mainCharacterView.updateNextLevel(nextLevel: nextLevel, remainPost: response.posts, remainComment: response.comments)
                mainCharacterView.updateCharacterAndStage(characterImage: response.rewardLevel, stageLevel: nowLevel)
                completion(true)
            case .failure(_):
                completion(false)
            }
        }
    }
}

extension MyCharacterViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GetCharacterCollectionViewCell.identifier, for: indexPath) as! GetCharacterCollectionViewCell
        
        if indexPath.item < myCharacterList.count {
            let characterInfo = myCharacterList[indexPath.item]
            
            if characterInfo.open {
                // 캐릭터가 열려 있으면 해당 이미지 표시
                cell.configure(with: characterInfo.rewardLevel)
                cell.setFullyUnlockedState()
            } else {
                // 리스트에 있지만 `open == false`면 잠금 해제 대기 상태
                cell.setUnlockedState()
            }
        } else {
            // 리스트에 없는 경우, 잠긴 상태로 설정
            cell.setLockedState()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 106, height: 141)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? GetCharacterCollectionViewCell else { return }
        
        if cell.getLockStatus() { // `locked` 상태 → 클릭 막기
            return
        }
        
        let selectLevel = myCharacterList[indexPath.row].rewardLevel
        guard let level = CharacterImage.levelMapping[selectLevel] else { return }
        
        if !cell.getLockStatus() && cell.isUnlockedState { // `unlocked` 상태 → `fullyUnlocked` 상태로 변경후, patch 부르면서 빵빠레
            updateOpenCharacter(selectedLevel: selectLevel) { [weak self] success in
                guard let self = self, success else { return }
                
                DispatchQueue.main.async {
                    self.myCharacterList[indexPath.row].open = true
                    cell.setFullyUnlockedState()
                    self.mainCharacterView.updateCharacterAndStage(characterImage: selectLevel, stageLevel: level)
                    self.mainCharacterView.showConfettiForFiveSeconds()
                }
            }
        } else {
            // `fullyUnlocked` 상태 → 메인캐릭터뷰 stage에 해당 캐릭터 띄우기
            mainCharacterView.updateCharacterAndStage(characterImage: selectLevel, stageLevel: level)
        }
    }
}

