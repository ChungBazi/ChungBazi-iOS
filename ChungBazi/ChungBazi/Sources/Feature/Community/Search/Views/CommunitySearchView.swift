//
//  CommunitySearchView.swift
//  ChungBazi
//
//  Created by 신호연 on 2/2/25.
//

import UIKit
import SnapKit
import Then

final class CommunitySearchView: UIView {
    
    private let dropdownPeriodView = CompactDropdown(
        title: "기간",
        hasBorder: false,
        items: Constants.communitySearchPeriodCategoryItems
    )
    private let dropdownTitleView = CompactDropdown(
        title: "제목",
        hasBorder: false,
        items: Constants.communitySearchTitleCategoryItems
    )
    
    private let searchbarView = UITextField().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
        $0.font = .ptdMediumFont(ofSize: 16)
        $0.textColor = .gray800
        $0.attributedPlaceholder = NSAttributedString(
            string: "검색어를 입력하세요.",
            attributes: [.foregroundColor: UIColor.gray300]
        )
        $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 17, height: 1))
        $0.leftViewMode = .always
        $0.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 17 + 24 + 12, height: 1))
        $0.rightViewMode = .always
    }
    private let searchButton = UIButton.createWithImage(
        image: .searchIcon,
        tintColor: .gray500,
        target: self,
        action: #selector(searchButtonTapped)
    )
    
    private let popularKeywordsLabel = UILabel().then {
        $0.text = "인기 검색어"
        $0.font = .ptdSemiBoldFont(ofSize: 20)
        $0.textColor = .gray800
    }
    private let popularKeywordsView = CommunitySearchPopularKeywoardsView()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubviews(dropdownPeriodView, dropdownTitleView, searchbarView, popularKeywordsLabel, popularKeywordsView)
        dropdownPeriodView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().inset(Constants.gutter)
            $0.width.equalTo(91)
            $0.height.equalTo(36*Constants.communitySearchPeriodCategoryItems.count + 36 + 8)
        }
        dropdownTitleView.snp.makeConstraints {
            $0.top.equalTo(dropdownPeriodView)
            $0.leading.equalTo(dropdownPeriodView.snp.trailing).offset(9)
            $0.width.equalTo(91)
            $0.height.equalTo(36*Constants.communitySearchTitleCategoryItems.count + 36 + 8)
        }
        
        searchbarView.addSubview(searchButton)
        searchbarView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(46)
            $0.leading.trailing.equalToSuperview().inset(Constants.gutter)
            $0.height.equalTo(40)
        }
        searchButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(12)
        }
        
        popularKeywordsLabel.snp.makeConstraints {
            $0.leading.equalTo(dropdownPeriodView).offset(5)
            $0.top.equalTo(searchbarView.snp.bottom).offset(26)
        }
        popularKeywordsView.snp.makeConstraints {
            $0.top.equalTo(popularKeywordsLabel.snp.bottom).offset(15)
            $0.leading.trailing.bottom.equalToSuperview().inset(Constants.gutter)
        }
    }
    
    @objc private func searchButtonTapped() {
        
    }
}
