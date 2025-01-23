//
//  CalendarPolicyListViewController.swift
//  ChungBazi
//
//  Created by 신호연 on 1/23/25.
//

import UIKit

final class CalendarPolicyListViewController: UIViewController {
    
    private let calendarPolicyListView = CalendarPolicyListView()
    var selectedDate: String = ""
    var policies: [Policy] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(calendarPolicyListView)
        calendarPolicyListView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
 
    private func setupData() {
        calendarPolicyListView.updateView(with: selectedDate, policies: policies)
    }
}
