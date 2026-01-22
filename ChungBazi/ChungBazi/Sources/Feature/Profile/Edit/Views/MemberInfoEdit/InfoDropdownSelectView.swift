//
//  InfoDropdownSelectView.swift
//  ChungBazi
//
//  Created by 이현주 on 1/22/26.
//

import UIKit
import SnapKit
import Then

class InfoDropdownSelectView: UIView {
    
    private let titleLabel = B16_SB(text: "", textColor: .gray800)
    private let dropdown: CustomDropdown
    private let items: [String]
    private let itemHeight: CGFloat
    private let isLong: Bool
    
    private var selectedItem: String?
    
    weak var delegate: CustomDropdownDelegate? {
        didSet {
            dropdown.delegate = delegate
        }
    }
    
    init(title: String, placeholder: String, items: [String], itemHeight: CGFloat = 48, isLong: Bool) {
        self.items = items
        self.itemHeight = itemHeight
        self.isLong = isLong
        
        self.dropdown = CustomDropdown(
            height: itemHeight,
            fontSize: 16,
            title: placeholder,
            hasBorder: true,
            items: items,
            hasShadow: false
        )
        super.init(frame: .zero)
        titleLabel.text = title
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubviews(titleLabel, dropdown)
        
        titleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }
        
        let dropdownWidth = isLong ? 0.83 : 0.4
        
        dropdown.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.equalTo(titleLabel.snp.leading)
            $0.width.equalToSuperview().multipliedBy(dropdownWidth)
            $0.height.equalTo(itemHeight)
            $0.bottom.equalToSuperview()
        }
    }
    
    func getSelectedItem() -> String? {
        return selectedItem
    }
    
    func getDropdown() -> CustomDropdown {
        return dropdown
    }
    
    func setSelectedItem(_ item: String?) {
        dropdown.setSelectedItem(item)
        self.selectedItem = item
    }
}
