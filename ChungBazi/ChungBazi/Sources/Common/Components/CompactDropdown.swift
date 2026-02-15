//
//  CompactDropdown.swift
//  ChungBazi
//
//  Created by 엄민서 on 1/29/25.
//

import UIKit

protocol CompactDropdownDelegate: AnyObject {
    func dropdown(_ dropdown: CompactDropdown, didSelectItem item: String)
}

class CompactDropdown: UIView {
    
    // MARK: - Properties
    weak var delegate: CompactDropdownDelegate?
    
    private let viewHeight: CGFloat = 36
    private let cellHeight: CGFloat = 36
    
    private let dropdownView: CompactDropDownView
    
    private lazy var dropdownTableView: UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true
        tableView.layer.cornerRadius = 10
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    private var dropdownItems: [String] = []
    private var isDropdownOpen = false
    private var selectedItem: String?
    private var panGesture: UIPanGestureRecognizer!
    
    // MARK: - Initializer
    init(title: String, hasBorder: Bool, items: [String]) {
        self.dropdownItems = items
        self.dropdownView = CompactDropDownView(title: title, hasBorder: hasBorder)
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
        
        dropdownView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(viewHeight)
        }
        
        dropdownTableView.snp.makeConstraints { make in
            make.top.equalTo(dropdownView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(0)
        }
    }
    
    private func setupGesture() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        dropdownTableView.addGestureRecognizer(panGesture)
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: dropdownTableView)
        guard let indexPath = dropdownTableView.indexPathForRow(at: location) else { return }
        
        if gesture.state == .changed {
            applyHighlight(to: dropdownTableView, at: indexPath, highlight: true)
        }
        
        if gesture.state == .ended {
            dropdownTableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            tableView(dropdownTableView, didSelectRowAt: indexPath)
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
        let iconName: ImageResource = isDropdownOpen ? .dropupIcon : .dropdownIcon
        dropdownView.dropdownImageView.image = UIImage(resource: iconName).withRenderingMode(.alwaysOriginal)
        dropdownTableView.isHidden = !isDropdownOpen
        
        let tableHeight = dropdownTableView.contentSize.height
        dropdownTableView.snp.updateConstraints { make in
            make.height.equalTo(isDropdownOpen ? tableHeight : 0)
        }
        
        /// 드롭다운이 열릴 때, 최상단으로 올림
        if isDropdownOpen {
            superview?.bringSubviewToFront(self)
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
extension CompactDropdown: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dropdownItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DropdownCell") ?? UITableViewCell(style: .default, reuseIdentifier: "DropdownCell")
        cell.textLabel?.text = dropdownItems[indexPath.row]
        cell.textLabel?.font = UIFont.ptdMediumFont(ofSize: 14)
        cell.textLabel?.textColor = UIColor.gray400
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = dropdownItems[indexPath.row]
        dropdownView.titleLabel.text = selectedItem
        dropdownView.titleLabel.textColor = .black
        toggleDropdown()
        delegate?.dropdown(self, didSelectItem: selectedItem)
    }
}
