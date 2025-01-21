//
//  CalenderViewController.swift
//  ChungBazi
//
//  Created by 신호연 on 1/19/25.
//

import UIKit

final class CalenderViewController: UIViewController {
 
    // MARK: - Properties
    private let calendarView = CalendarView()
    
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
        view.addSubview(calendarView)
        calendarView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        addCustomNavigationBar(titleText: "캘린더", showBackButton: false, showCartButton: true, showAlarmButton: true)
    }
    
    // MARK: - Data
    public func fetchData() {
        let samplePolicy = createSamplePolicy()
        bindPolicyData(samplePolicy)
    }
    
    public func createSamplePolicy() -> Policy {
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
    
    private func bindPolicyData(_ policy: Policy?) {
        guard let policy = policy else { return }
        calendarView.update(policy: policy)
    }
    
    // MARK: - Actions
    
    
}
