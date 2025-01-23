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

protocol CalendarViewDelegate: AnyObject {
    func presentPolicyListViewController()
}

final class CalendarView: UIView {

    // MARK: - Properties
    weak var delegate: CalendarViewDelegate?

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
    private var events: [Date: [String]] = [:]

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
        calendar.register(CustomCalendarCell.self, forCellReuseIdentifier: "CustomCalendarCell")
        calendar.snp.makeConstraints {
            $0.top.equalTo(customHeader.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(Constants.gutter)
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(26)
        }
    }

    private func configureCalendarAppearance() {
        calendar.appearance.titleDefaultColor = .black
        calendar.appearance.titleSelectionColor = .white
        calendar.appearance.selectionColor = .clear
        calendar.appearance.todayColor = .clear
        calendar.appearance.titlePlaceholderColor = .gray300
        calendar.appearance.borderRadius = 1.0
        calendar.appearance.weekdayTextColor = .gray800
        calendar.weekdayHeight = 20
        calendar.rowHeight = 70
        calendar.locale = Locale(identifier: "ko_KR")
        calendar.headerHeight = 0
        calendar.placeholderType = .fillHeadTail
        calendar.appearance.eventDefaultColor = .blue700
        calendar.appearance.eventSelectionColor = .blue700
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
    func update(policy: Policy) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let startDate = dateFormatter.date(from: policy.startDate),
              let endDate = dateFormatter.date(from: policy.endDate) else { return }
        
        events[startDate] = ["start"]
        events[endDate] = ["end"]
        
        calendar.reloadData()
    }
}

// MARK: - FSCalendarDelegate
extension CalendarView: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return min(events[date]?.count ?? 0, 3)
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        guard let eventNames = events[date] else { return nil }
        return eventNames.prefix(3).map { _ in .blue700 }
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        updateHeader(for: calendar.currentPage)
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        guard let cell = calendar.cell(for: date, at: monthPosition) as? CustomCalendarCell else { return }
        cell.isSelected = true
        cell.updateCellAppearance()
    }

    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        guard let cell = calendar.cell(for: date, at: monthPosition) as? CustomCalendarCell else { return }
        cell.isSelected = false
        cell.updateCellAppearance()
    }
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        guard let cell = calendar.dequeueReusableCell(withIdentifier: "CustomCalendarCell", for: date, at: position) as? CustomCalendarCell else {
            return FSCalendarCell()
        }
        cell.date = date
        return cell
    }
}

// MARK: - Custom Calendar Cell
final class CustomCalendarCell: FSCalendarCell {
    var date: Date? {
        didSet {
            updateCellAppearance()
        }
    }

    private let customShapeLayer = CAShapeLayer()
    private let today = Date()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.insertSublayer(customShapeLayer, below: titleLabel.layer)

        titleLabel.textAlignment = .center
        titleLabel.font = .ptdMediumFont(ofSize: 14)
        titleLabel.textColor = .black
        titleLabel.addCharacterSpacing(0.01)
        titleLabel.setLineSpacing(ratio: 1.4)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutTitleLabel()
        layoutShapeLayer()
    }

    private func layoutTitleLabel() {
        titleLabel.frame = CGRect(
            x: 0,
            y: 0,
            width: contentView.bounds.width,
            height: 20
        )
    }

    private func layoutShapeLayer() {
        guard let titleFrame = titleLabel.frame as CGRect? else { return }

        let shapeLayerSize: CGFloat = 27
        let shapeLayerX = titleFrame.midX - shapeLayerSize / 2
        let shapeLayerY = titleFrame.midY - shapeLayerSize / 2

        customShapeLayer.frame = CGRect(
            x: shapeLayerX,
            y: shapeLayerY,
            width: shapeLayerSize,
            height: shapeLayerSize
        )
        customShapeLayer.cornerRadius = 10
    }

    func updateCellAppearance() {
        guard let date = date else { return }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let cellDate = dateFormatter.string(from: date)
        let todayDate = dateFormatter.string(from: today)

        if isSelected {
            customShapeLayer.backgroundColor = UIColor.blue700.cgColor
        } else if cellDate == todayDate {
            customShapeLayer.backgroundColor = UIColor.green300.cgColor
        } else {
            customShapeLayer.backgroundColor = UIColor.clear.cgColor
        }
    }
}
