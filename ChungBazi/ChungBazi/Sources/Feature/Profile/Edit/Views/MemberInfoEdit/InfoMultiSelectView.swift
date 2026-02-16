//
//  InfoMultiSelectView.swift
//  ChungBazi
//
//  Created by 이현주 on 1/22/26.
//

import UIKit

class InfoMultiSelectView: UIView {
    
    private let titleLabel = B16_SB(text: "", textColor: .gray800)
    
    private lazy var collectionView: UICollectionView = {
        let layout = LeftAlignedCollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumInteritemSpacing = 9
        layout.minimumLineSpacing = 8
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.isScrollEnabled = false
        cv.isUserInteractionEnabled = true
        cv.allowsMultipleSelection = true
        cv.register(MultiSelectCollectionViewCell.self, forCellWithReuseIdentifier: MultiSelectCollectionViewCell.identifier)
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    private var items: [String] = []
    private var selectedItems: [String] = []
    
    var onSelectionChanged: (([String]) -> Void)?
    
    init(title: String, items: [String]) {
        super.init(frame: .zero)
        titleLabel.text = title
        self.items = items
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubviews(titleLabel, collectionView)
        
        titleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(100)
            $0.bottom.equalToSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let contentHeight = self.collectionView.collectionViewLayout.collectionViewContentSize.height
            
            self.collectionView.snp.updateConstraints {
                $0.height.equalTo(contentHeight)
            }
        }
    }
    
    func setSelected(items: [String]) {
        selectedItems = items
        collectionView.reloadData()
        
        // 선택 상태 적용
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.items.enumerated().forEach { index, item in
                if self.selectedItems.contains(item) {
                    self.collectionView.selectItem(
                        at: IndexPath(item: index, section: 0),
                        animated: false,
                        scrollPosition: []
                    )
                }
            }
        }
    }
    
    func getSelectedItems() -> [String] {
        return selectedItems
    }
}

// MARK: - UICollectionViewDataSource
extension InfoMultiSelectView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MultiSelectCollectionViewCell.identifier,
            for: indexPath
        ) as? MultiSelectCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.configure(with: items[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension InfoMultiSelectView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.item]
        
        if !selectedItems.contains(item) {
            selectedItems.append(item)
        }
        
        onSelectionChanged?(selectedItems)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let item = items[indexPath.item]
        selectedItems.removeAll { $0 == item }
        
        onSelectionChanged?(selectedItems)
    }
}
