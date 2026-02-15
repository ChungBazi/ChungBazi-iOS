//
//  AlarmViewController.swift
//  ChungBazi
//

import UIKit

class AlarmViewController: UIViewController {
    
    let networkService = NotificationService()
    var alarmList: [AlarmModel] = []
    var alarmType: AlarmType = .policy
    var nextCursor = 0
    var hasNext: Bool = false
    var isLoadingMore: Bool = false
    
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
    
    private let emptyStateLabel = UILabel().then {
        $0.text = "알림이 비었습니다."
        $0.textAlignment = .center
        $0.textColor = .gray600
        $0.font = .ptdMediumFont(ofSize: 16)
        $0.isHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray50
        addCustomNavigationBar(titleText: "알림", showBackButton: true, showCartButton: false, showAlarmButton: false)
        addComoponents()
        setConstraints()
        fetchAlarmList(type: alarmType.rawValue, cursor: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    private func addComoponents() {
        [alarmListCollectionView, emptyStateLabel].forEach { view.addSubview($0) }
    }
    
    private func setConstraints() {
        alarmListCollectionView.snp.makeConstraints {
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(Constants.navigationHeight)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        emptyStateLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func fetchAlarmList(type: String, cursor: Int) {
        if isLoadingMore && cursor != 0 {
            return
        }
        
        if cursor != 0 {
            isLoadingMore = true
        }
        
        self.networkService.fetchAlarmList(type: type, cursor: cursor) { [weak self] result in
            guard let self = self else { return }
            
            self.isLoadingMore = false
            
            switch result {
            case .success(let response):
                guard let response = response,
                      let alarmContent = response.items else { return }
                // 알림 15개 매핑
                let nextAlarmDatas: [AlarmModel] = alarmContent.compactMap { data in
                    guard let notificationId = data.notificationId,
                          let message = data.message,
                          let typeString = data.type,
                          let sentTime = data.formattedCreatedAt?.replacingOccurrences(of: "T", with: " ")
                    else {
                        print("알림이 없습니다.")
                        return nil
                    }
                    let type = AlarmType.from(typeString)
                    return AlarmModel(notificationId: notificationId, message: message, type: type, targetId: data.targetId, sentTime: sentTime)
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
                    let hasResults = self.alarmList.isEmpty
                    self.emptyStateLabel.isHidden = !hasResults
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
        return CGSize(width: collectionView.frame.width - 32, height: 106)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let alarm = alarmList[indexPath.item]
        let destinationVC: UIViewController?
        
        switch alarm.type {
        case .policy:
            guard let policyId = alarm.targetId else { return }
            let vc = PolicyDetailViewController()
            vc.configureEntryPoint(.alarm)
            vc.policyId = policyId
            destinationVC = vc
            
        default:
            return
        }
        
        if let destinationVC = destinationVC {
            navigationController?.pushViewController(destinationVC, animated: true)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            scrollView.contentOffset.y = 0 // 위쪽 바운스 막기
        }
        
        guard !isLoadingMore else { return }
        
        guard let collectionView = scrollView as? UICollectionView else { return }
        
        let contentOffsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.frame.size.height
        
        // Check if user has scrolled to the bottom
        if contentOffsetY > contentHeight - scrollViewHeight { // Trigger when arrive the bottom
            guard hasNext else { return }
            fetchAlarmList(type: alarmType.rawValue, cursor: nextCursor)
        }
    }
}
