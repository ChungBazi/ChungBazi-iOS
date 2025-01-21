//
//  CalendarDocumentReferenceViewController.swift
//  ChungBazi
//
//  Created by 신호연 on 1/21/25.
//

import UIKit

final class CalendarDocumentReferenceViewController: UIViewController {
    
    private let calendarDoucmnetReferenceView = CalendarDocumentReferenceView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(calendarDoucmnetReferenceView)
        calendarDoucmnetReferenceView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
