//
//  MyCharacterViewController.swift
//  ChungBazi
//
//  Created by 이현주 on 2/9/25.
//

import UIKit

class MyCharacterViewController: UIViewController, UIScrollViewDelegate {
    
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showCustomAlert(
            title: "레벨업 완료!\n새로운 캐릭터가 열렸습니다.\n카드를 눌러 확인해보세요!",
            ButtonText: "좋아요",
            image: .confetti
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    private func setNavBar() {
        addCustomNavigationBar(titleText: "캐릭터 설정", tintColor: .white, showBackButton: true, showCartButton: false, showAlarmButton: false, backgroundColor: .blue700)
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
}

extension MyCharacterViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GetCharacterCollectionViewCell.identifier, for: indexPath) as! GetCharacterCollectionViewCell
        
//        let alarm = alarmList[indexPath.item]
        //cell.configure()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 106, height: 141)
    }
}

