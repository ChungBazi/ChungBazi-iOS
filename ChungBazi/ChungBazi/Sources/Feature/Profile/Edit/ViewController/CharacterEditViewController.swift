//
//  CharacterEditViewController.swift
//  ChungBazi
//
//  Created by 이현주 on 2/9/25.
//

import UIKit
import SnapKit
import Then

class CharacterEditViewController: UIViewController {
    
    var selectedIndexPath: IndexPath?
    let userInfoData = UserProfileDataManager.shared
    
    private let myCharacterTitle = UILabel().then {
        $0.text = "마이 캐릭터"
        $0.font = UIFont.ptdSemiBoldFont(ofSize: 20)
        $0.textColor = .black
    }
    
    private lazy var myCharacterCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then {
        $0.scrollDirection = .vertical
        $0.minimumLineSpacing = 18
        $0.minimumInteritemSpacing = 25
        //$0.sectionInset = UIEdgeInsets(top: 3, left: 10, bottom: 3, right: 10)
        $0.estimatedItemSize = .zero
    }).then {
        $0.register(CharacterEditCollectionViewCell.self, forCellWithReuseIdentifier: CharacterEditCollectionViewCell.identifier)
        $0.backgroundColor = .clear
        $0.delegate = self
        $0.dataSource = self
    }
    
    private let completeBtn = CustomButton(backgroundColor: .blue700, titleText: "캐릭터 설정 완료", titleColor: .white)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray50
        setNavBar()
        addComoponents()
        setConstraints()
        setAction()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        //selectedIndexPath?.item = userInfoData.getCharacterNum() - 1
        selectedIndexPath = IndexPath(item: 0, section: 0)
        DispatchQueue.main.async {
            if let selectedIndexPath = self.selectedIndexPath {
                self.myCharacterCollectionView.reloadItems(at: [selectedIndexPath])
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    private func setNavBar() {
        addCustomNavigationBar(titleText: "캐릭터 설정", showBackButton: true, showCartButton: false, showAlarmButton: false, backgroundColor: .white)
        fillSafeArea(position: .top, color: .white)
    }
    
    private func addComoponents() {
        [myCharacterTitle, myCharacterCollectionView, completeBtn].forEach { view.addSubview($0) }
    }
    
    private func setConstraints() {
        myCharacterTitle.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(Constants.navigationHeight + 21)
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(24)
        }
        
        completeBtn.snp.makeConstraints {
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
        }
        
        myCharacterCollectionView.snp.makeConstraints {
            $0.top.equalTo(myCharacterTitle.snp.bottom).offset(22)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(30)
            $0.bottom.equalTo(completeBtn.snp.top).offset(-22)
        }
    }
    
    private func setAction() {
        completeBtn.addTarget(self, action: #selector(didCompleteCharacterEditing), for: .touchUpInside)
    }
    
    @objc private func didCompleteCharacterEditing() {
        guard let selectCharacter = selectedIndexPath?.item else { return }
        userInfoData.setCharacterNum(selectCharacter + 1)
        navigationController?.popViewController(animated: true)
    }
}

extension CharacterEditViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CharacterEditCollectionViewCell.identifier, for: indexPath) as! CharacterEditCollectionViewCell
        
        //cell.configure()
        
        if indexPath == selectedIndexPath {
            cell.layer.borderColor = UIColor.blue700.cgColor
            cell.layer.borderWidth = 3
        } else {
            cell.layer.borderColor = UIColor.clear.cgColor
            cell.layer.borderWidth = 0
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 88, height: 88)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let previousSelectedIndexPath = selectedIndexPath
        selectedIndexPath = indexPath
        
        // 이전에 선택된 셀이 있으면 리로드해서 border 초기화
        var indexPathsToReload: [IndexPath] = [indexPath]
        if let previous = previousSelectedIndexPath {
            indexPathsToReload.append(previous)
        }
        
        collectionView.reloadItems(at: indexPathsToReload)
    }
}
