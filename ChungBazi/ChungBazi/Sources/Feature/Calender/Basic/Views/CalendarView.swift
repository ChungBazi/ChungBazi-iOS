//
//  CalendarView.swift
//  ChungBazi
//
//  Created by 신호연 on 1/19/25.
//

import UIKit
import SnapKit
import Then
import FSCalendar

final class CalendarView: UIView {
    
    // MARK: - Properties
    private let customHeader = UIView().then {
        $0.backgroundColor = .white
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    private let customMonth = UILabel().then {
        $0.textAlignment = .center
        $0.textColor = .black
        $0.font = .ptdSemiBoldFont(ofSize: 20)
    }
    private let customYear = UILabel().then {
        $0.textAlignment = .center
        $0.textColor = .gray500
        $0.font = .ptdMediumFont(ofSize: 12)
    }
    private let previousBtn = UIButton.createWithImage(
        image: .arrowLeft,
        tintColor: .gray500,
        target: self,
        action: #selector(prevPage),
        touchAreaInsets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    )
    private let nextBtn = UIButton.createWithImage(
        image: .arrowRight,
        tintColor: .gray500,
        target: self,
        action: #selector(nextPage),
        touchAreaInsets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    )
    private var currentPage: Date?
    private let today = Date()
    private let dateFormatter = DateFormatter().then {
        $0.locale = Locale(identifier: "ko_KR")
    }
    
    private let calendar = FSCalendar().then {
        $0.backgroundColor = .white
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
        $0.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        $0.scope = .month
    }
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        calendar.dataSource = self
        calendar.delegate = self
        updateHeader(for: calendar.currentPage)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        setupHeader()
        setupCalendar()
    }

    private func setupHeader() {
        addSubview(customHeader)
        customHeader.addSubviews(previousBtn, nextBtn, customMonth, customYear)
        
        customHeader.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide.snp.top).offset(Constants.navigationHeight + 20)
            $0.leading.trailing.equalToSuperview().inset(Constants.gutter)
            $0.height.equalTo(92)
        }
        
        previousBtn.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(55)
            $0.centerY.equalToSuperview()
        }
        nextBtn.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(55)
            $0.centerY.equalToSuperview()
        }
        customMonth.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.centerX.equalToSuperview()
        }
        customYear.snp.makeConstraints {
            $0.top.equalTo(customMonth.snp.bottom)
            $0.centerX.equalToSuperview()
        }
    }

    private func setupCalendar() {
        addSubview(calendar)
        configureCalendarAppearance()
        calendar.snp.makeConstraints {
            $0.top.equalTo(customHeader.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(Constants.gutter)
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(26)
        }
    }
    
    private func configureCalendarAppearance() {
        calendar.appearance.titleDefaultColor = .black
        calendar.appearance.titleSelectionColor = .white
        calendar.appearance.titlePlaceholderColor = .gray300
        calendar.appearance.selectionColor = .blue700
        calendar.appearance.todayColor = .green300
        calendar.appearance.borderRadius = 0.65
        calendar.appearance.weekdayTextColor = .gray800
        calendar.weekdayHeight = 20
        calendar.rowHeight = 70
        calendar.locale = Locale(identifier: "ko_KR")
        calendar.headerHeight = 0
    }
    
    // MARK: - UI Update
    private func updateHeader(for date: Date) {
        dateFormatter.dateFormat = "MMMM"
        customMonth.text = dateFormatter.string(from: date)
        
        dateFormatter.dateFormat = "yyyy"
        customYear.text = dateFormatter.string(from: date)
    }
    
    // MARK: - Actions
    @objc private func prevPage() {
        moveCurrentPage(by: -1)
    }
    
    @objc private func nextPage() {
        moveCurrentPage(by: 1)
    }
    
    private func moveCurrentPage(by months: Int) {
        guard let newPage = Calendar.current.date(byAdding: .month, value: months, to: calendar.currentPage) else { return }
        calendar.setCurrentPage(newPage, animated: true)
    }
    
    // MARK: - Public Methods
    /// 데이터를 바인딩하거나 업데이트

}

// MARK: - FSCalendarDelegate
extension CalendarView: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        updateHeader(for: calendar.currentPage)
    }
    
    
}
