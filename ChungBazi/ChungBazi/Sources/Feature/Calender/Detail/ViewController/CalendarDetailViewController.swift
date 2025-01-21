//
//  CalendarDetailViewController.swift
//  ChungBazi
//
//  Created by 신호연 on 1/20/25.
//

import UIKit
import SnapKit
import SafeAreaBrush

final class CalendarDetailViewController: UIViewController {
    
    // MARK: - Properties
    private let calendarDetailView = CalendarDetailView()
    private lazy var pageViewController: UIPageViewController = {
        let vc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        vc.dataSource = self
        vc.delegate = self
        return vc
    }()
    private let dataViewControllers = [
        CalendarDocumentListViewController(),
        CalendarDocumentReferenceViewController()
    ]
    
    // MARK: - IBOutlet
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPageController()
        fetchData()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .gray50
        
        view.addSubview(calendarDetailView)
        calendarDetailView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(Constants.navigationHeight)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(Constants.tabBarHeight)
        }
        
        fillSafeArea(position: .top, color: .white)
        addCustomNavigationBar(titleText: "", showBackButton: false, showCartButton: true, showAlarmButton: true, backgroundColor: .white)
    }
    
    private func setupPageController() {
        addChild(pageViewController)
        calendarDetailView.navigationView.addSubview(pageViewController.view)
        pageViewController.view.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(calendarDetailView.navigationView.snp.bottom).inset(20)
        }
        pageViewController.didMove(toParent: self)
        guard let firstVC = dataViewControllers.first else { return }
        pageViewController.setViewControllers([firstVC], direction: .forward, animated: false)
    }
    
    // MARK: - Data
    private func fetchData() {
        let samplePolicy = createSamplePolicy()
        updateUI(with: samplePolicy)
    }

    private func createSamplePolicy() -> Policy {
        return Policy(
            policyId: 1,
            policyName: "양진구청 마라톤 참가자 모집 모모모집",
            startDate: "2024-12-12",
            endDate: "2024-12-23",
            documentText: "1단계: 홈페이지 수강신청 -> 2단계: 자기소개서 작성 후 제출",
            userDocuments: [
                Document(documentId: 1, name: "주민등록본", isChecked: true),
                Document(documentId: 2, name: "학생증", isChecked: false)
            ]
        )
    }
    
    private func updateUI(with policy: Policy?) {
        guard let policy = policy else { return }
        calendarDetailView.update(policy: policy)
    }
    
    // MARK: - Actions
    

}

extension CalendarDetailViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = dataViewControllers.firstIndex(of: viewController), index > 0 else { return nil }
        return dataViewControllers[index - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = dataViewControllers.firstIndex(of: viewController), index < dataViewControllers.count - 1 else { return nil }
        return dataViewControllers[index + 1]
    }
}

extension CalendarDetailViewController: UIPageViewControllerDelegate {
    
}
