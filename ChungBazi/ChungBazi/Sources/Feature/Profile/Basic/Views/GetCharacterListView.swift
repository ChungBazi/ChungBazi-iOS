//
//  GetCharacterListView.swift
//  ChungBazi
//
//  Created by 이현주 on 2/10/25.
//

import UIKit
import Then

class GetCharacterListView: UIView {
    private let title = UILabel().then {
        $0.text = "캐릭터 획득 리포트"
        $0.font = UIFont.ptdSemiBoldFont(ofSize: 16)
        $0.textColor = .white
    }
    
    public lazy var GetCharacterCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then {
        $0.scrollDirection = .vertical
        $0.minimumLineSpacing = 20
        $0.minimumInteritemSpacing = 11
        $0.estimatedItemSize = .zero
    }).then {
        $0.register(GetCharacterCollectionViewCell.self, forCellWithReuseIdentifier: GetCharacterCollectionViewCell.identifier)
        $0.isScrollEnabled = false
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 10
        $0.layer.masksToBounds = true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white.withAlphaComponent(0.25)
        self.layer.cornerRadius = 10
        self.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner)
        self.layer.masksToBounds = true
        addComponents()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addComponents() {
        [title, GetCharacterCollectionView].forEach { self.addSubview($0) }
    }
    
    private func setConstraints() {
        title.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(26)
        }
        
        GetCharacterCollectionView.snp.makeConstraints {
            $0.top.equalTo(title.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview().inset(17)
            $0.height.equalTo(624)
            $0.bottom.equalToSuperview().offset(-60)
        }
    }
}
