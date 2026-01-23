//
//  MultiSelectCollectionViewCell.swift
//  ChungBazi
//
//  Created by 이현주 on 1/22/26.
//

import UIKit

class MultiSelectCollectionViewCell: UICollectionViewCell {
    static let identifier = "MultiSelectCollectionViewCell"
    
    private let titleLabel = B14_M(text: "", textColor: .gray800)
    
    override var isSelected: Bool {
        didSet {
            updateAppearance()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        updateAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        titleLabel.numberOfLines = 1
        
        contentView.addSubview(titleLabel)
        
        contentView.layer.cornerRadius = 10
        contentView.layer.borderWidth = 1
        contentView.backgroundColor = .clear
        
        titleLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10))
        }
    }
    
    func configure(with title: String) {
        titleLabel.text = title
    }
    
    private func updateAppearance() {
        if isSelected {
            contentView.layer.borderColor = UIColor.black.cgColor
        } else {
            contentView.layer.borderColor = UIColor.gray300.cgColor
        }
    }
}
