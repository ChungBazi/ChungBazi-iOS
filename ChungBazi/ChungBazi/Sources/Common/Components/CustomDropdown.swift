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
    
    private var viewHeight: CGFloat = 0
    private var cellHeight: CGFloat = 0 // 각 셀의 높이
    private var fontSize: CGFloat = 0 // 폰트 크기
    private var hasShadow: Bool
    
    let dropdownView: CustomDropdownView
    
    private lazy var dropdownTableView: UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true // 초기에는 숨김
        tableView.layer.cornerRadius = 10
        tableView.layer.masksToBounds = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false // 스크롤 비활성화
        return tableView
    }()
    
    private lazy var dropdownContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        if hasShadow { // 쉐도우 옵션에 따라 적용 여부 결정
            applyShadow(to: view)
        }
        return view
    }()
    
    private var dropdownItems: [String] = []
    private var isDropdownOpen = false
    private var selectedItem: String?
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
        addSubview(dropdownView)
        addSubview(dropdownContainerView)
        dropdownContainerView.addSubview(dropdownTableView)
        
        // 드롭다운 뷰 레이아웃
        dropdownView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(viewHeight)
        }
        
        dropdownContainerView.snp.makeConstraints {
            $0.top.equalTo(dropdownView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(0)
        }
        
        // 테이블 뷰 레이아웃
        dropdownTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(0) // 초기 높이 0
        }
    }
    
    private func applyShadow(to view: UIView) {
        view.layer.shadowColor = UIColor.black.cgColor // 블랙 색상 (#000000)
        view.layer.shadowOpacity = 0.2 // 투명도 20%
        view.layer.shadowOffset = CGSize(width: 0, height: 4) // X: 0, Y: 4
        view.layer.shadowRadius = 10 // Blur 값 (흐림 정도)
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
        dropdownContainerView.isHidden = !isDropdownOpen
        dropdownTableView.isHidden = !isDropdownOpen
        
        // 테이블 높이를 동적으로 계산
        let tableHeight = dropdownTableView.contentSize.height
        dropdownTableView.snp.updateConstraints { make in
            make.height.equalTo(isDropdownOpen ? tableHeight : 0)
        }
        dropdownContainerView.snp.updateConstraints { make in
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
        cell.textLabel?.font = UIFont.ptdMediumFont(ofSize: fontSize)
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
