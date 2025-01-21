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
    private let segmentedControl = CalendarDetailSegmentedControl(items: ["서류 리스트", "서류 참고 내용"])
    
    // MARK: - IBOutlet
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchData()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .gray50
        
        setupCalendarDetailView()
        setupNavigationBar()
        setupSegmentedControl()
        setupPageController()
    }
    
    private func setupCalendarDetailView() {
        view.addSubview(calendarDetailView)
        calendarDetailView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(Constants.navigationHeight)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(Constants.tabBarHeight)
        }
    }
    
    private func setupNavigationBar() {
        fillSafeArea(position: .top, color: .white)
        addCustomNavigationBar(
            titleText: "",
            showBackButton: false,
            showCartButton: true,
            showAlarmButton: true,
            backgroundColor: .white
        )
    }
    
    private func setupSegmentedControl() {
        segmentedControl.addTarget(self, action: #selector(segmentedChanged(_:)), for: .valueChanged)
        segmentedControl.selectedSegmentIndex = 0
        calendarDetailView.navigationView.addSubview(segmentedControl)
        segmentedControl.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(Constants.gutter)
            $0.height.equalTo(33)
        }
    }
    
    private func setupPageController() {
        addChild(pageViewController)
        calendarDetailView.navigationView.addSubview(pageViewController.view)
        pageViewController.view.snp.makeConstraints {
            $0.top.equalTo(segmentedControl.snp.bottom).offset(8)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
        pageViewController.didMove(toParent: self)
        pageViewController.setViewControllers([dataViewControllers.first!], direction: .forward, animated: false)
        
        updatePageViewHeight()
    }
    
    private func updatePageViewHeight() {
        guard let currentViewController = pageViewController.viewControllers?.first else { return }
        
        let targetHeight = currentViewController.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height

        pageViewController.view.snp.remakeConstraints {
            $0.top.equalTo(segmentedControl.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(targetHeight)
        }
        view.layoutIfNeeded()
    }
    
    // MARK: - Actions
    @objc private func segmentedChanged(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        guard index < dataViewControllers.count else { return }

        let direction: UIPageViewController.NavigationDirection =
            (pageViewController.viewControllers?.first.flatMap { dataViewControllers.firstIndex(of: $0) } ?? 0 < index)
            ? .forward
            : .reverse

        pageViewController.setViewControllers([dataViewControllers[index]], direction: direction, animated: true) { [weak self] finished in
            guard finished else { return }
            self?.updatePageViewHeight()
        }
    }
    
    // MARK: - Data
    private func fetchData() {
        let samplePolicy = createSamplePolicy()
        bindPolicyData(samplePolicy)
    }

    private func createSamplePolicy() -> Policy {
        return Policy(
            policyId: 1,
            policyName: "양진구청 마라톤 참가자 모집",
            startDate: "2024-12-12",
            endDate: "2024-12-23",
            documentText: "1단계: 홈페이지 수강신청 -> 2단계: 자기소개서 작성 후 제출",
            userDocuments: [
                Document(documentId: 1, name: "주민등록본", isChecked: true),
                Document(documentId: 2, name: "학생증", isChecked: false)
            ]
        )
    }
    
    private func bindPolicyData(_ policy: Policy?) {
        guard let policy = policy else { return }
        calendarDetailView.update(policy: policy)
    }

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
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            updatePageViewHeight()
        }
    }
}
