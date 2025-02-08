//
//  MyCharacterCollectionViewCell.swift
//  ChungBazi
//
//  Created by 이현주 on 2/9/25.
//

import UIKit

class CharacterEditCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "CharacterEditCollectionViewCell"
    
    private lazy var character = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .LEVEL_1
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .green300
        self.layer.cornerRadius = 44
        self.layer.masksToBounds = true
        addComponents()
        setConstraints()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        //self.character.image = nil
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addComponents() {
        contentView.addSubview(character)
    }
    
    private func setConstraints() {
        character.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(7)
            $0.top.equalToSuperview().offset(1)
        }
    }
    
    public func configure() {
    }
}
