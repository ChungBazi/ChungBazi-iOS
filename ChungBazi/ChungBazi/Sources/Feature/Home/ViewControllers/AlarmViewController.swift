//
//  AlarmViewController.swift
//  ChungBazi
//

import UIKit

class AlarmViewController: UIViewController {
    
    private lazy var entireBtn = createAlarmKindButton(title: "전체", action: #selector(alarmKindButtonTapped))
    
    private lazy var calendarBtn = createAlarmKindButton(title: "캘린더", action: #selector(alarmKindButtonTapped))
    
    private lazy var communityBtn = createAlarmKindButton(title: "커뮤니티", action: #selector(alarmKindButtonTapped))
    
    private lazy var buttonStackView = UIStackView(arrangedSubviews: [entireBtn, calendarBtn, communityBtn]).then {
        $0.axis = .horizontal // 가로 방향으로 정렬
        $0.spacing = 11       // 버튼 간 간격
        $0.alignment = .leading  // 버튼의 크기를 동일하게
        $0.distribution = .equalSpacing // 균등한 간격 분배
    }
    
    private lazy var alarmListCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then {
        $0.scrollDirection = .vertical
        $0.minimumLineSpacing = 12
        $0.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)
        $0.estimatedItemSize = .zero
    }).then {
        $0.register(AlarmListCollecionViewCell.self, forCellWithReuseIdentifier: AlarmListCollecionViewCell.identifier)
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 10
        $0.layer.masksToBounds = true
        $0.delegate = self
        $0.dataSource = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray50
        addCustomNavigationBar(titleText: "알림", showBackButton: true, showCartButton: false, showAlarmButton: false)
        addComoponents()
        setConstraints()
        alarmKindButtonTapped(entireBtn)
    }
    
    private func createAlarmKindButton(
        title: String,
        target: Any? = self,
        action: Selector? = nil
    ) -> UIButton {
        return UIButton(type: .system).then {
            // 타이틀 설정
            $0.setTitle(title, for: .normal)
            $0.setTitleColor(UIColor.gray800, for: .normal)
            $0.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 14)
            
            // 배경색 및 코너 반경
            $0.backgroundColor = .clear
            $0.layer.cornerRadius = 10
            
            // 테두리 설정
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.gray400.cgColor
            
            $0.sizeToFit() // 타이틀 크기에 맞게 버튼 크기 조정
            $0.contentEdgeInsets = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
            
            // 액션 추가
            if let action = action {
                $0.addTarget(target, action: action, for: .touchUpInside)
            }
            
            $0.snp.makeConstraints {
                $0.height.equalTo(36)
            }
        }
    }
    
    @objc private func alarmKindButtonTapped(_ sender: UIButton) {
        let buttons = [entireBtn, calendarBtn, communityBtn]
        buttons.forEach { button in
            button.backgroundColor = .clear
            button.setTitleColor(UIColor.gray800, for: .normal)
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.gray400.cgColor
        }
        
        // 클릭된 버튼 활성화
        sender.backgroundColor = UIColor.blue700
        sender.setTitleColor(.white, for: .normal)
        sender.layer.borderWidth = 0
        sender.layer.borderColor = nil
    }
    
    private func addComoponents() {
        [buttonStackView, alarmListCollectionView].forEach { view.addSubview($0) }
    }
    
    private func setConstraints() {
        buttonStackView.snp.makeConstraints {
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(Constants.navigationHeight + 23)
        }
        
        alarmListCollectionView.snp.makeConstraints {
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.top.equalTo(buttonStackView.snp.bottom).offset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension AlarmViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlarmListCollecionViewCell.identifier, for: indexPath) as! AlarmListCollecionViewCell
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 106)
    }
}
