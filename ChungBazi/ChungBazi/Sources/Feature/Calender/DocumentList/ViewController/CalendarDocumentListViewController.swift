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
        view?.backgroundColor = .red
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(calendarDocumentListView)
        calendarDocumentListView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
