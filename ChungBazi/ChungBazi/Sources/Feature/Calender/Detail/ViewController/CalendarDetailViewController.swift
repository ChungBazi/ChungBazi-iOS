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
