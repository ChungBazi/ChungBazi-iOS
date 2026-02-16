//
//  CalenderViewController.swift
//  ChungBazi
//
//  Created by 신호연 on 1/19/25.
//

import UIKit

final class CalenderViewController: UIViewController, UISheetPresentationControllerDelegate {
    // MARK: - Properties
    
    private let calendarView = CalendarView()
    private var selectedDate: String?
    private var policies: [SortedPolicy] = []
    private var dimmingView: UIView?
    private var calendarService = CalendarService()
    
    private var lastRequestedYearMonth: String?
    private var debounceWorkItem: DispatchWorkItem?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureCalendarViewDelegate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let initialDate = calendarView.currentPage ?? Date()
        requestCalendar(for: initialDate)
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .gray50
        view.addSubview(calendarView)
        calendarView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(Constants.navigationHeight)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(15)
            $0.leading.trailing.equalToSuperview()
        }
        addCustomNavigationBar(titleText: "캘린더", showBackButton: false, showCartButton: false, showAlarmButton: false, showRightCartButton: true, showLeftSearchButton: false)
    }
    
    // MARK: - Data
    private func fetchData(yearMonth: String) {
        showLoading()
        showLoading()
        
        self.policies = []
        self.calendarView.clearPolicies()
        
        calendarService.getCalendarPolicies(yearMonth: yearMonth) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async { self.hideLoading() }
            
            switch result {
            case .success(let response):
                guard let items = response, !items.isEmpty else {
                    print("(\(yearMonth)) 해당 월 데이터 없음 — 빈 상태 UI")
                    return
                }
                
                self.policies = items.compactMap { policy in
                    guard
                        let startDateStr = policy.startDate,
                        let endDateStr   = policy.endDate,
                        let startDate = DateFormatter.yearMonthDay.date(from: startDateStr),
                        let endDate   = DateFormatter.yearMonthDay.date(from: endDateStr),
                        let cartId    = policy.cartId,
                        let policyId  = policy.policyId
                    else { return nil }
                    
                    return SortedPolicy(
                        cartId: cartId,
                        policyId: policyId,
                        startDate: startDate,
                        endDate: endDate,
                        policyName: policy.name ?? "이름 없음"
                    )
                }
                
                self.policies = self.sortMarkers(policies: self.policies)
                self.bindPolicyData(self.policies)
                
            case .failure(let error):
                showCustomAlert(title: "일정을 불러오는 데 실패하였습니다.\n다시 시도해주세요.", buttonText: "확인")
            }
        }
    }
    
    private func requestCalendar(for date: Date) {
        let yearMonth = DateFormatter.yearMonth.string(from: date)
        
        if lastRequestedYearMonth == yearMonth {
            return
        }
        lastRequestedYearMonth = yearMonth
        
        debounceWorkItem?.cancel()
        let work = DispatchWorkItem { [weak self] in
            self?.fetchData(yearMonth: yearMonth)
        }
        debounceWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: work)
    }
    
    private func bindPolicyData(_ policies: [SortedPolicy]) {
        guard !policies.isEmpty else { return }
        for policy in policies {
            calendarView.update(policy: policy)
        }
    }
    
    private func sortMarkers(policies: [SortedPolicy]) -> [SortedPolicy] {
        return policies.sorted { $0.startDate < $1.startDate }
    }
}

extension CalenderViewController: CalendarViewDelegate {
    
    func configureCalendarViewDelegate() {
        calendarView.delegate = self
    }
    
    func calendarCurrentPageDidChange(to date: Date) {
        requestCalendar(for: date)
    }
    
    func presentCalendarDetailViewController(for policy: Policy?) {
        guard let policy = policy else { return }
        let detailVC = CalendarDetailViewController(policy: policy)
        
        let navController = UINavigationController(rootViewController: detailVC)
        navController.modalPresentationStyle = .fullScreen
        
        self.present(navController, animated: true, completion: nil)
    }
    
    func presentPolicyListViewController(for date: Date) {
        addDimmingView()

        let policyListVC = CalendarPolicyListViewController()
        policyListVC.modalPresentationStyle = .pageSheet
        policyListVC.selectedDate = DateFormatter.yearMonthDay.string(from: date)
        policyListVC.policies = getPolicies(for: date)

        let navigationController = UINavigationController(rootViewController: policyListVC)
        navigationController.modalPresentationStyle = .pageSheet

        if let sheet = navigationController.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.selectedDetentIdentifier = .medium
            sheet.delegate = self
            sheet.largestUndimmedDetentIdentifier = .large
        }

        present(navigationController, animated: true)
    }
    
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        removeDimmingView()
    }
    
    private func getPolicies(for date: Date) -> [Policy] {
        return policies.compactMap { sortedPolicy in
            let startDateString = DateFormatter.yearMonthDay.string(from: sortedPolicy.startDate)
            let endDateString = DateFormatter.yearMonthDay.string(from: sortedPolicy.endDate)
            
            return Policy(
                cartId: sortedPolicy.cartId, policyId: sortedPolicy.policyId,
                policyName: sortedPolicy.policyName,
                startDate: startDateString,
                endDate: endDateString,
                documentText: "",
                userDocuments: []
            )
        }.filter { policy in
            guard let policyStart = DateFormatter.yearMonthDay.date(from: policy.startDate),
                  let policyEnd = DateFormatter.yearMonthDay.date(from: policy.endDate) else { return false }
            return policyStart <= date && policyEnd >= date
        }
    }
    
    private func createPolicy(from date: Date) -> Policy? {
        return nil
    }
}

// MARK: - Dimming View Handling
extension CalenderViewController {
    private func addDimmingView() {
        let dimmingView = UIView(frame: view.bounds)
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        dimmingView.tag = 999
        dimmingView.alpha = 0
        view.addSubview(dimmingView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPresentedController))
        dimmingView.addGestureRecognizer(tapGesture)
        
        UIView.animate(withDuration: 0.2) {
            dimmingView.alpha = 1
        }
        
        self.dimmingView = dimmingView
    }
    
    private func removeDimmingView() {
        if let dimmingView = view.viewWithTag(999) {
            UIView.animate(withDuration: 0.2, animations: {
                dimmingView.alpha = 0
            }) { _ in
                dimmingView.removeFromSuperview()
            }
        }
    }
    
    @objc private func dismissPresentedController() {
        dismiss(animated: true) {
            self.removeDimmingView()
        }
    }
}

extension CalendarDetailViewController: UISheetPresentationControllerDelegate { }
