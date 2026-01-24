//
//  CustomDropdown.swift
//  ChungBazi
//
//  Created by 이현주 on 1/25/25.
//

import UIKit
import SnapKit

protocol CustomDropdownDelegate: AnyObject {
    func dropdown(_ dropdown: CustomDropdown, didSelectItem item: String)
}

class CustomDropdown: UIView {
    
    // MARK: - Properties
    weak var delegate: CustomDropdownDelegate?
    
    private var viewHeight: CGFloat = 0
    private var cellHeight: CGFloat = 0
    private var fontSize: CGFloat = 0
    private var hasShadow: Bool
    
    let dropdownView: CustomDropdownView
    
    private lazy var dropdownTableView: UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true
        tableView.layer.cornerRadius = 10
        tableView.layer.masksToBounds = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.backgroundColor = .white
        return tableView
    }()
    
    private lazy var dropdownContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isHidden = true
        if hasShadow {
            applyShadow(to: view)
        }
        return view
    }()
    
    private var dropdownItems: [String] = []
    private var isDropdownOpen = false
    var selectedItem: String?
    private var panGesture: UIPanGestureRecognizer!
    
    // MARK: - Initializer
    init(height: CGFloat, fontSize: CGFloat, title: String, hasBorder: Bool, items: [String], hasShadow: Bool = true) {
        self.viewHeight = height
        self.cellHeight = height
        self.fontSize = fontSize
        self.dropdownItems = items
        self.dropdownView = CustomDropdownView(title: title, fontSize: fontSize, hasBorder: hasBorder)
        self.hasShadow = hasShadow
        super.init(frame: .zero)
        
        setupUI()
        setupGesture()
        configureDropdownView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        // dropdownView만 CustomDropdown에 추가
        addSubview(dropdownView)
        
        // dropdownContainerView에 tableView 추가 (아직 어디에도 추가 안함)
        dropdownContainerView.addSubview(dropdownTableView)
        
        // dropdownView가 CustomDropdown의 크기를 결정
        dropdownView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(viewHeight)
        }
        
        // dropdownTableView는 dropdownContainerView를 채움
        dropdownTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func applyShadow(to view: UIView) {
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 10
        view.layer.masksToBounds = false
    }
    
    private func setupGesture() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        dropdownTableView.addGestureRecognizer(panGesture)
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: dropdownTableView)
        guard let indexPath = dropdownTableView.indexPathForRow(at: location) else { return }
        
        // 하이라이트 처리
        if gesture.state == .changed {
            applyHighlight(to: dropdownTableView, at: indexPath, highlight: true)
        }
        
        if gesture.state == .ended {
            // 선택된 셀 동작 실행
            dropdownTableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            tableView(dropdownTableView, didSelectRowAt: indexPath)
            // 하이라이트 해제
            applyHighlight(to: dropdownTableView, at: indexPath, highlight: false)
        }
    }
    
    private func applyHighlight(to tableView: UITableView, at indexPath: IndexPath, highlight: Bool) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        let visibleIndexPaths = tableView.indexPathsForVisibleRows ?? []
        for visibleIndexPath in visibleIndexPaths {
            if let visibleCell = tableView.cellForRow(at: visibleIndexPath) {
                UIView.animate(withDuration: 0.2) {
                    visibleCell.contentView.backgroundColor = (highlight && visibleIndexPath == indexPath)
                    ? UIColor.gray100
                    : .white
                }
            }
        }
    }
    
    private func configureDropdownView() {
        dropdownView.onDropdownTapped = { [weak self] in
            guard let self = self else { return }
            self.toggleDropdown()
        }
    }
    
    // MARK: - Actions
    private func toggleDropdown() {
        isDropdownOpen.toggle()
        let iconName = isDropdownOpen ? "dropup_icon" : "dropdown_icon"
        dropdownView.dropdownImageView.image = UIImage(named: iconName)?.withRenderingMode(.alwaysOriginal)
        
        if isDropdownOpen {
            showDropdown()
        } else {
            hideDropdown()
        }
    }
    
    // 드롭다운 표시 - 부모 뷰에 overlay로 추가
    private func showDropdown() {
        guard let parentView = findScrollViewOrView() else { return }
        
        // dropdownContainerView를 부모 뷰에 추가
        parentView.addSubview(dropdownContainerView)
        
        // dropdownView의 부모 뷰 기준 위치 계산
        let dropdownFrame = dropdownView.convert(dropdownView.bounds, to: parentView)
        
        let tableHeight = CGFloat(dropdownItems.count) * cellHeight
        
        dropdownContainerView.snp.makeConstraints {
            $0.top.equalTo(parentView.snp.top).offset(dropdownFrame.maxY + 8)
            $0.leading.equalTo(parentView.snp.leading).offset(dropdownFrame.minX)
            $0.width.equalTo(dropdownFrame.width)
            $0.height.equalTo(tableHeight)
        }
        
        dropdownContainerView.isHidden = false
        dropdownTableView.isHidden = false
        
        dropdownContainerView.alpha = 0
        UIView.animate(withDuration: 0.2) {
            self.dropdownContainerView.alpha = 1
        }
    }
    
    // 드롭다운 숨김
    private func hideDropdown() {
        UIView.animate(withDuration: 0.2, animations: {
            self.dropdownContainerView.alpha = 0
        }) { _ in
            self.dropdownContainerView.removeFromSuperview()
            self.dropdownContainerView.isHidden = true
            self.dropdownTableView.isHidden = true
            
            // 제약조건 제거
            self.dropdownContainerView.snp.removeConstraints()
        }
    }
    
    // 적절한 부모 뷰 찾기 (ScrollView 또는 최상위 뷰)
    private func findScrollViewOrView() -> UIView? {
        var currentView: UIView? = self.superview
        
        while currentView != nil {
            // ScrollView를 찾으면 그것을 사용
            if currentView is UIScrollView {
                return currentView
            }
            // 또는 ViewController의 view까지 올라감
            if currentView?.next is UIViewController {
                return currentView
            }
            currentView = currentView?.superview
        }
        
        return self.superview
    }
    
    func didSelectItem(at index: Int) {
        selectedItem = dropdownItems[index]
        delegate?.dropdown(self, didSelectItem: selectedItem ?? "")
    }
    
    // MARK: - Public Methods
    func setItems(_ items: [String]) {
        self.dropdownItems = items
        dropdownTableView.reloadData()
    }
    
    func setSelectedItem(_ item: String?) {
        guard let item = item else { return }
        self.selectedItem = item
        dropdownView.titleLabel.text = item
        dropdownView.titleLabel.textColor = .black
    }
    
    // 외부에서 드롭다운 닫기
    func closeDropdown() {
        if isDropdownOpen {
            toggleDropdown()
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension CustomDropdown: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dropdownItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DropdownCell") ?? UITableViewCell(style: .default, reuseIdentifier: "DropdownCell")
        cell.textLabel?.text = dropdownItems[indexPath.row]
        cell.textLabel?.font = UIFont.ptdMediumFont(ofSize: fontSize)
        cell.textLabel?.textColor = UIColor.gray400
        cell.selectionStyle = .none
        cell.backgroundColor = .white
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = dropdownItems[indexPath.row]
        dropdownView.titleLabel.text = selectedItem
        dropdownView.titleLabel.textColor = .black
        self.selectedItem = selectedItem
        toggleDropdown()
        delegate?.dropdown(self, didSelectItem: selectedItem)
    }
    
    func tableView(_ tableView: UITableView, willHighlightRowAt indexPath: IndexPath) -> IndexPath? {
        let cell = tableView.cellForRow(at: indexPath)
        UIView.animate(withDuration: 0.2) {
            cell?.contentView.backgroundColor = UIColor.gray100
        }
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        UIView.animate(withDuration: 0.2) {
            cell?.contentView.backgroundColor = UIColor.gray100
        }
    }
    
    // 셀 하이라이트 처리
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        UIView.animate(withDuration: 0.2) {
            cell?.contentView.backgroundColor = .white
        }
    }
}
