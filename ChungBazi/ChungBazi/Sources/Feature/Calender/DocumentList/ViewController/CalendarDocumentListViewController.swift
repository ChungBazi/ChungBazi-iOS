//
//  CalendarDocumentListViewController.swift
//  ChungBazi
//
//  Created by 신호연 on 1/21/25.
//

import UIKit

final class CalendarDocumentListViewController: UIViewController {
    
    private let calendarDocumentListView = CalendarDocumentListView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.frame.size = view.superview?.bounds.size ?? .zero
    }
    
    private func setupUI() {
        view.addSubview(calendarDocumentListView)
        calendarDocumentListView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
