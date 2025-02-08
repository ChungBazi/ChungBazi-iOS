//
//  AlarmViewController.swift
//  ChungBazi
//

import UIKit

class AlarmViewController: UIViewController {
    
    let networkService = NotificationService()
    var alarmList: [AlarmModel] = []
    var alarmType: String?
    var nextCursor = 0
    var hasNext: Bool = false
    
    private lazy var entireBtn = createAlarmKindButton(title: "전체", action: #selector(alarmKindButtonTapped))
    
    private lazy var calendarBtn = createAlarmKindButton(title: "캘린더", action: #selector(alarmKindButtonTapped))
    
    private lazy var communityBtn = createAlarmKindButton(title: "커뮤니티", action: #selector(alarmKindButtonTapped))
    
    private lazy var rewardBtn = createAlarmKindButton(title: "리워드", action: #selector(alarmKindButtonTapped))
    
    private lazy var buttonStackView = UIStackView(arrangedSubviews: [entireBtn, calendarBtn, communityBtn, rewardBtn]).then {
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
        setBtnTag()
        alarmKindButtonTapped(entireBtn)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
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
        let buttons = [entireBtn, calendarBtn, communityBtn, rewardBtn]
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
        
        let type: AlarmType
        
        switch sender.tag {
        case 0:
            type = .entire
        case 1:
            type = .policy
        case 2:
            type = .community
        case 3:
            type = .reward
        default:
            type = .unknown
        }
        
        DispatchQueue.main.async {
            // 강제로 맨위로 올리기
            self.alarmListCollectionView.setContentOffset(.zero, animated: true)
        }
        
        fetchAlarmList(type: type.rawValue, cursor: 0)
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
    
    private func setBtnTag() {
        entireBtn.tag = 0
        calendarBtn.tag = 1
        communityBtn.tag = 2
        rewardBtn.tag = 3
    }
    
    private func fetchAlarmList(type: String, cursor: Int) {
        self.networkService.fetchAlarmList(type: type, cursor: cursor) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                guard let response = response,
                      let alarmContent = response.notifications else { return }
                // 알림 15개 매핑
                let nextAlarmDatas: [AlarmModel] = alarmContent.compactMap { data in
                    guard let notificationId = data.notificationId,
                          let message = data.message,
                          let typeString = data.type,
                          let sentTime = data.formattedCreatedAt else {
                        print("알림이 없습니다.")
                        return nil
                    }
                    let type = AlarmType.from(typeString)
                    return AlarmModel(notificationId: notificationId, message: message, type: type, sentTime: sentTime)
                }
                
                if cursor != 0 { // 맨 처음 요청한게 아니면, 이전 데이터가 이미 저장이 되어있는 상황이면
                    // 리스트 뒤에다가 넣어준다!
                    self.alarmList.append(contentsOf: nextAlarmDatas)
                } else {
                    // 아니면 리스트 자체에 설정
                    self.alarmList = nextAlarmDatas
                }
                
                self.nextCursor = response.nextCursor ?? 0
                self.hasNext = response.hasNext
                
                DispatchQueue.main.async {
                    self.alarmListCollectionView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension AlarmViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return alarmList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlarmListCollecionViewCell.identifier, for: indexPath) as! AlarmListCollecionViewCell
        
        let alarm = alarmList[indexPath.item]
        cell.configure(alarm)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 106)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            scrollView.contentOffset.y = 0 // 위쪽 바운스 막기
        }
        
        guard let collectionView = scrollView as? UICollectionView else { return }
        
        let contentOffsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.frame.size.height
        
        // Check if user has scrolled to the bottom
        if contentOffsetY > contentHeight - scrollViewHeight { // Trigger when arrive the bottom
            guard hasNext else { return }
            fetchAlarmList(type: alarmType ?? "", cursor: nextCursor)
        }
    }
}
