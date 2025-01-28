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
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchData()
        configureCalendarViewDelegate()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(calendarView)
        calendarView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        addCustomNavigationBar(titleText: "캘린더", showBackButton: false, showCartButton: false, showAlarmButton: true)
    }
    
    // MARK: - Data
    private func fetchData() {
        let samplePolicies = createSamplePolicy()
        policies = samplePolicies.map { policy in
            SortedPolicy(
                startDate: DateFormatter.yearMonthDay.date(from: policy.startDate) ?? Date(),
                endDate: DateFormatter.yearMonthDay.date(from: policy.endDate) ?? Date(),
                policyName: policy.policyName)
        }
        policies = sortMarkers(policies: policies)
        bindPolicyData(policies)
    }
    
    private func createSamplePolicy() -> [Policy] {
        return [
            Policy(
                policyId: 1,
                policyName: "양진구청 마라톤 참가자 모집",
                startDate: "2025-01-12",
                endDate: "2025-01-23",
                documentText: "1단계: 홈페이지 수강신청 -> 2단계: 자기소개서 작성 후 제출",
                userDocuments: [
                    Document(documentId: 1, name: "주민등록본", isChecked: true),
                    Document(documentId: 2, name: "학생증", isChecked: false)
                ]
            ),
            Policy(
                policyId: 2,
                policyName: "청바지 동아리 회원 모집",
                startDate: "2025-01-15",
                endDate: "2025-02-01",
                documentText: "1단계: 동아리 홈페이지 지원서 작성 -> 2단계: 인터뷰 진행 후 결과 통보",
                userDocuments: [
                    Document(documentId: 3, name: "졸업증명서", isChecked: true),
                    Document(documentId: 4, name: "이력서", isChecked: false)
                ]
            ),
            Policy(
                policyId: 3,
                policyName: "지역 사회봉사단 모집",
                startDate: "2025-01-12",
                endDate: "2025-01-15",
                documentText: "1단계: 지원서 제출 -> 2단계: 간단한 면접 진행",
                userDocuments: [
                    Document(documentId: 5, name: "주민등록초본", isChecked: true),
                    Document(documentId: 6, name: "면허증", isChecked: false)
                ]
            ),
            Policy(
                policyId: 4,
                policyName: "공공 미술 프로젝트 지원",
                startDate: "2025-01-15",
                endDate: "2025-01-23",
                documentText: "1단계: 프로젝트 계획서 제출 -> 2단계: 현장 실사 후 최종 발표",
                userDocuments: [
                    Document(documentId: 7, name: "프로젝트 계획서", isChecked: true),
                    Document(documentId: 8, name: "포트폴리오", isChecked: false)
                ]
            ),
            Policy(
                policyId: 5,
                policyName: "학생 창업 지원 모집",
                startDate: "2025-01-12",
                endDate: "2025-01-29",
                documentText: "1단계: 사업 계획서 제출 -> 2단계: 발표 심사 진행",
                userDocuments: [
                    Document(documentId: 9, name: "사업 계획서", isChecked: true),
                    Document(documentId: 10, name: "학생증 사본", isChecked: false)
                ]
            ),
            Policy(
                policyId: 6,
                policyName: "시민 체육대회 참가자 모집",
                startDate: "2025-01-12",
                endDate: "2025-01-29",
                documentText: "1단계: 참가 신청서 작성 -> 2단계: 참가비 납부",
                userDocuments: [
                    Document(documentId: 11, name: "참가 신청서", isChecked: true),
                    Document(documentId: 12, name: "참가비 영수증", isChecked: false)
                ]
            )
        ]
    }
    
    private func bindPolicyData(_ policies: [SortedPolicy]) {
        guard !policies.isEmpty else { return }
        for policy in policies {
            calendarView.update(policy: policy)
        }
    }
}

extension CalenderViewController: CalendarViewDelegate {
    func presentCalendarDetailViewController(for policy: Policy?) {
        guard let policy = policy else { return }
        let detailVC = CalendarDetailViewController(policy: policy)
        
        let navController = UINavigationController(rootViewController: detailVC)
        navController.modalPresentationStyle = .fullScreen
        
        self.present(navController, animated: true, completion: nil)
    }
    
    func presentPolicyListViewController(for date: Date) {
        let policyListVC = CalendarPolicyListViewController()
        policyListVC.modalPresentationStyle = .pageSheet
        policyListVC.selectedDate = DateFormatter.yearMonthDay.string(from: date)
        policyListVC.policies = getPolicies(for: date)

        let navigationController = UINavigationController(rootViewController: policyListVC)
        navigationController.modalPresentationStyle = .pageSheet

        if let sheet = navigationController.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.selectedDetentIdentifier = .medium
            sheet.largestUndimmedDetentIdentifier = .large
            sheet.prefersGrabberVisible = false
            sheet.delegate = self
        }

        navigationController.view.layer.masksToBounds = false
        navigationController.view.clipsToBounds = false

        policyListVC.view.layer.cornerRadius = 20
        policyListVC.view.layer.shadowColor = UIColor.black.cgColor
        policyListVC.view.layer.shadowOpacity = 0.16
        policyListVC.view.layer.shadowOffset = CGSize(width: 0, height: 3)
        policyListVC.view.layer.shadowRadius = 15
        policyListVC.view.layer.masksToBounds = false

        navigationController.isModalInPresentation = false

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissModal))
        view.addGestureRecognizer(tapGesture)
        tapGesture.name = "dismissGesture"

        present(navigationController, animated: true, completion: nil)
    }

    @objc private func dismissModal() {
        dismiss(animated: true, completion: nil)

        if let gestures = view.gestureRecognizers {
            for gesture in gestures where gesture.name == "dismissGesture" {
                view.removeGestureRecognizer(gesture)
            }
        }
    }
    
    private func getPolicies(for date: Date) -> [Policy] {
        let filteredPolicies = policies.filter { policy in
            policy.startDate <= date && policy.endDate >= date
        }
        
        let originalPolicies = createSamplePolicy()
        return filteredPolicies.compactMap { sortedPolicy in
            originalPolicies.first { originalPolicy in
                originalPolicy.policyName == sortedPolicy.policyName &&
                originalPolicy.startDate == DateFormatter.yearMonthDay.string(from: sortedPolicy.startDate) &&
                originalPolicy.endDate == DateFormatter.yearMonthDay.string(from: sortedPolicy.endDate)
            }
        }
    }
    
    func configureCalendarViewDelegate() {
        calendarView.delegate = self
    }
    
    private func createPolicy(from date: Date) -> Policy? {
        return nil
    }
}

extension CalendarDetailViewController: UISheetPresentationControllerDelegate {
    
}
