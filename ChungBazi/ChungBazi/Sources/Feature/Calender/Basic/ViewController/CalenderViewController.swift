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
    
    
    // MARK: - Actions
    
    
}
