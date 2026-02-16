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
    func presentPolicyListViewController(for date: Date)
    func calendarCurrentPageDidChange(to date: Date)
}

final class CalendarView: UIView {
    
    // MARK: - Properties
    weak var delegate: CalendarViewDelegate?
    private var events: [Date: [String]] = [:]
    var selectedDate: Date?
    
    private let customHeader = createCustomHeader()
    private let customMonth = UILabel().then {
        $0.textAlignment = .center
        $0.textColor = .black
        $0.font = .ptdSemiBoldFont(ofSize: 20)
    }
    private let customYear = UILabel().then {
        $0.textAlignment = .center
        $0.textColor = .gray500
        $0.font = .ptdMediumFont(ofSize: 14)
    }
    private let previousBtn = UIButton.createWithImage(
        image: .arrowLeft,
        target: self,
        action: #selector(prevPage),
        touchAreaInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    ).then {
        $0.tintColor = .gray500
    }
    private let nextBtn = UIButton.createWithImage(
        image: .arrowRight,
        target: self,
        action: #selector(nextPage),
        touchAreaInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    ).then {
        $0.tintColor = .gray500
    }
    
    var currentPage: Date?
    private let today = Date()
    private let dateFormatter = DateFormatter().then {
        $0.locale = Locale(identifier: "ko_KR")
    }
    private let linkedView = UIView().then {
        $0.backgroundColor = .white
    }
    private let calendar = FSCalendar().then {
        $0.backgroundColor = .white
        $0.clipsToBounds = true
        $0.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        $0.scope = .month
    }
    
    private static func createCustomHeader() -> UIView {
        return UIView().then {
            $0.backgroundColor = .white
            $0.clipsToBounds = true
        }
    }
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        calendar.dataSource = self
        calendar.delegate = self
        self.currentPage = calendar.currentPage
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
            $0.top.equalToSuperview().offset(6)
            $0.leading.trailing.equalToSuperview().inset(Constants.gutter)
            $0.height.equalTo(94)
        }
        previousBtn.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(54)
            $0.centerY.equalToSuperview()
        }
        nextBtn.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(54)
            $0.centerY.equalToSuperview()
        }
        customMonth.snp.makeConstraints {
            $0.top.equalToSuperview().offset(23)
            $0.centerX.equalToSuperview()
        }
        customYear.snp.makeConstraints {
            $0.top.equalTo(customMonth.snp.bottom)
            $0.centerX.equalToSuperview()
        }
    }
    
    private func setupCalendar() {
        addSubview(linkedView)
        linkedView.snp.makeConstraints {
            $0.top.equalTo(customHeader.snp.bottom)
            $0.leading.trailing.equalTo(customHeader)
            $0.height.equalTo(2)
        }
        addSubview(calendar)
        configureCalendarAppearance()
        calendar.register(CustomCalendarCell.self, forCellReuseIdentifier: "CustomCalendarCell")
        calendar.snp.makeConstraints {
            $0.top.equalTo(linkedView.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(Constants.gutter)
            $0.bottom.equalToSuperview().inset(34)
        }
    }
    
    private func configureCalendarAppearance() {
        calendar.appearance.titleDefaultColor = .gray800
        calendar.appearance.titleSelectionColor = .gray800
        calendar.appearance.selectionColor = .clear
        calendar.appearance.todayColor = .clear
        calendar.appearance.titlePlaceholderColor = .gray300
        calendar.appearance.borderRadius = 1.0
        calendar.appearance.weekdayTextColor = .gray800
        calendar.weekdayHeight = 24
        calendar.rowHeight = 70
        calendar.locale = Locale(identifier: "ko_KR")
        calendar.headerHeight = 0
        calendar.placeholderType = .fillHeadTail
    }
    
    // MARK: - UI Update
    private func updateHeader(for date: Date) {
        customMonth.text = DateFormatter.monthFullName.string(from: date)
        customYear.text = DateFormatter.year.string(from: date)
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
    func update(policy: SortedPolicy) {
        events[policy.startDate, default: []].append("start")
        events[policy.endDate, default: []].append("end")
        calendar.reloadData()
    }
    
    func clearPolicies() {
        events.removeAll()
        calendar.reloadData()
    }
}

// MARK: - FSCalendarDelegate
extension CalendarView: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        self.currentPage = calendar.currentPage
        print("✅ currentPage 업데이트됨: \(String(describing: currentPage))")
        updateHeader(for: calendar.currentPage)
        calendar.reloadData()
        delegate?.calendarCurrentPageDidChange(to: calendar.currentPage)
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let normalizedDate = Calendar.current.startOfDay(for: date)
        
        if selectedDate == normalizedDate {
            if let eventsForDate = events[date], !eventsForDate.isEmpty {
                delegate?.presentPolicyListViewController(for: date)
            }
            return
        }
        
        if let previousDate = selectedDate {
            calendar.deselect(previousDate)
        }
        
        selectedDate = normalizedDate
        calendar.reloadData()
        
        if let eventsForDate = events[date], !eventsForDate.isEmpty {
            delegate?.presentPolicyListViewController(for: date)
        }
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDate = nil
        calendar.reloadData()
    }
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        guard let cell = calendar.dequeueReusableCell(withIdentifier: "CustomCalendarCell", for: date, at: position) as? CustomCalendarCell else {
            return FSCalendarCell()
        }
        cell.calendarView = self
        cell.date = date
        cell.isSelected = calendar.selectedDates.contains(date)
        cell.events = events
        cell.updateCellAppearance()
        return cell
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        return events[date] != nil
    }
}

// MARK: - Custom Calendar Cell
final class CustomCalendarCell: FSCalendarCell {
    weak var calendarView: CalendarView?
    
    var date: Date? {
        didSet {
            updateCellAppearance()
        }
    }
    
    var events: [Date: [String]] = [:]
    
    private let customShapeLayer = CAShapeLayer()
    private var eventLayers: [CAShapeLayer] = []
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
        layoutEventMarkers()
        
        updateCellAppearance()
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
        guard let calendarView = self.calendarView else {
            print("❌ updateCellAppearance: calendarView가 nil입니다.")
            customShapeLayer.backgroundColor = UIColor.clear.cgColor
            titleLabel.textColor = UIColor.gray500
            return
        }
        
        guard let currentPage = calendarView.currentPage else {
            print("❌ updateCellAppearance: currentPage가 nil입니다.")
            return
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let cellDate = calendar.startOfDay(for: date ?? Date())
        
        let isSelectedDate = calendarView.selectedDate == cellDate
        
        if calendar.isDate(cellDate, inSameDayAs: today) {
            customShapeLayer.backgroundColor = isSelectedDate ? UIColor.blue700.cgColor : UIColor.green300.cgColor
            titleLabel.textColor = isSelectedDate ? UIColor.white : UIColor.gray800
            return
        }
        
        if isSelectedDate {
            customShapeLayer.backgroundColor = UIColor.blue700.cgColor
            titleLabel.textColor = UIColor.white
            return
        }
        
        let currentComponents = calendar.dateComponents([.year, .month], from: currentPage)
        let dateComponents = calendar.dateComponents([.year, .month], from: date ?? Date())
        
        if dateComponents.year == currentComponents.year && dateComponents.month == currentComponents.month {
            customShapeLayer.backgroundColor = UIColor.clear.cgColor
            titleLabel.textColor = UIColor.gray800
        } else {
            customShapeLayer.backgroundColor = UIColor.clear.cgColor
            titleLabel.textColor = UIColor.gray300
        }
    }
    
    private func layoutEventMarkers() {
        let titleFrame = titleLabel.frame
        
        eventLayers.forEach { $0.removeFromSuperlayer() }
        eventLayers.removeAll()
        
        guard let date = date, var eventTypes = events[date] else { return }
        
        eventTypes.sort { $0 < $1 }
        
        let markerSize: CGFloat = 5
        let spacing: CGFloat = 3
        let maxVisibleMarkers = 3
        let visibleEventCount = min(eventTypes.count, maxVisibleMarkers)
        let totalWidth = CGFloat(visibleEventCount) * markerSize + CGFloat(visibleEventCount - 1) * spacing
        var offsetX: CGFloat = titleFrame.midX - totalWidth / 2
        
        for (index, eventType) in eventTypes.enumerated() {
            guard index < maxVisibleMarkers else { break }
            
            let markerLayer = CAShapeLayer()
            let markerRect = CGRect(x: offsetX, y: titleFrame.maxY + 5, width: markerSize, height: markerSize)
            markerLayer.frame = markerRect
            
            if eventType == "start" {
                markerLayer.path = UIBezierPath(ovalIn: CGRect(origin: .zero, size: markerRect.size)).cgPath
                markerLayer.strokeColor = UIColor.blue700.cgColor
                markerLayer.lineWidth = 1
                markerLayer.fillColor = UIColor.clear.cgColor
            } else if eventType == "end" {
                markerLayer.path = UIBezierPath(ovalIn: CGRect(origin: .zero, size: markerRect.size)).cgPath
                markerLayer.fillColor = UIColor.blue700.cgColor
            }
            
            contentView.layer.addSublayer(markerLayer)
            eventLayers.append(markerLayer)
            offsetX += markerSize + spacing
        }
        
        if eventTypes.count > maxVisibleMarkers {
            let remainingCount = eventTypes.count - maxVisibleMarkers
            let label = UILabel()
            label.text = "+\(remainingCount)"
            label.font = .ptdMediumFont(ofSize: 14)
            label.textColor = .gray300
            label.textAlignment = .center
            label.frame = CGRect(
                x: titleFrame.midX - 15,
                y: titleFrame.maxY + 10 + markerSize,
                width: 30,
                height: 20
            )
            contentView.addSubview(label)
        }
    }
}
