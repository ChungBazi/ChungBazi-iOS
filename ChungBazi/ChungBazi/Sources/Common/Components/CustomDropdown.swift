//
//  CustomDropdown.swift
//  ChungBazi
//
//  Created by 이현주 on 1/25/25.
//

import UIKit

protocol CustomDropdownDelegate: AnyObject {
    func dropdown(_ dropdown: CustomDropdown, didSelectItem item: String)
}

class CustomDropdown: UIView {
    
    // MARK: - Properties
    weak var delegate: CustomDropdownDelegate?
    
    private let viewHeight: CGFloat = 48
    private let cellHeight: CGFloat = 48 // 각 셀의 높이
    
    private let dropdownView: CustomDropdownView
    
    private lazy var dropdownTableView: UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true // 초기에는 숨김
        tableView.layer.cornerRadius = 10
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false // 스크롤 비활성화
        return tableView
    }()
    
    private var dropdownItems: [String] = []
    private var isDropdownOpen = false
    private var selectedItem: String?
    private var panGesture: UIPanGestureRecognizer!
    
    // MARK: - Initializer
    init(title: String, hasBorder: Bool, items: [String]) {
        self.dropdownItems = items
        self.dropdownView = CustomDropdownView(title: title, hasBorder: hasBorder)
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
        addSubview(dropdownView)
        addSubview(dropdownTableView)
        
        // 드롭다운 뷰 레이아웃
        dropdownView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(viewHeight)
        }
        
        // 테이블 뷰 레이아웃
        dropdownTableView.snp.makeConstraints { make in
            make.top.equalTo(dropdownView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(0) // 초기 높이 0
        }
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
        dropdownTableView.isHidden = !isDropdownOpen
        
        // 테이블 높이를 동적으로 계산
        let tableHeight = dropdownTableView.contentSize.height
        dropdownTableView.snp.updateConstraints { make in
            make.height.equalTo(isDropdownOpen ? tableHeight : 0)
        }
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
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension CustomDropdown: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dropdownItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DropdownCell") ?? UITableViewCell(style: .default, reuseIdentifier: "DropdownCell")
        cell.textLabel?.text = dropdownItems[indexPath.row]
        cell.textLabel?.font = UIFont.ptdMediumFont(ofSize: 16)
        cell.textLabel?.textColor = UIColor.gray400
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = dropdownItems[indexPath.row]
        dropdownView.titleLabel.text = selectedItem // 선택된 항목 업데이트
        dropdownView.titleLabel.textColor = .black
        toggleDropdown()
        delegate?.dropdown(self, didSelectItem: selectedItem)
    }
    
    // 셀 하이라이트 처리 (터치로 훑을 때)
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
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        UIView.animate(withDuration: 0.2) {
            cell?.contentView.backgroundColor = .white
        }
    }
}
