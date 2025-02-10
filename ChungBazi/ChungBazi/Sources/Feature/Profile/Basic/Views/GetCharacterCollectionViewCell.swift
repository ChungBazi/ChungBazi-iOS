//
//  GetCharacterCollectionViewCell.swift
//  ChungBazi
//
//  Created by 이현주 on 2/10/25.
//

import UIKit

class GetCharacterCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "GetCharacterCollectionViewCell"
    
    private var isLocked: Bool = false
    
    public var isUnlockedState: Bool {
        return !background.isHidden && unlocked.isHidden == false
    }
    
    private lazy var character = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var crown = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .rewardColorIcon
    }
    
    private lazy var level = UILabel().then {
        $0.font = UIFont.ptdMediumFont(ofSize: 14)
        $0.textColor = .black
    }
    
    private lazy var characterInfoStackView = createStackView(arrangedSubviews: [crown, level], axis: .horizontal, spacing: 3)
    
    private lazy var background = UIView().then {
        $0.isHidden = true
    }
    
    private lazy var locked = UIImageView().then {
        $0.image = .locked
        $0.contentMode = .scaleAspectFit
        $0.isHidden = true
    }
    
    private lazy var unlocked = UIImageView().then {
        $0.image = .unlocked
        $0.contentMode = .scaleAspectFit
        $0.isHidden = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .green300
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        addComponents()
        setConstraints()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.character.image = nil
        self.level.text = nil
        self.background.backgroundColor = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addComponents() {
        [character, characterInfoStackView, background, locked, unlocked].forEach { self.addSubview($0)}
    }
    
    private func setConstraints() {
        character.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.horizontalEdges.equalToSuperview().inset(3)
            $0.bottom.equalTo(characterInfoStackView.snp.top).offset(-8)
        }
        
        crown.snp.makeConstraints {
            $0.size.equalTo(18)
        }
        
        characterInfoStackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-9)
        }
        
        background.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        locked.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(30)
            $0.centerY.equalToSuperview()
        }
        
        unlocked.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(30)
            $0.centerY.equalToSuperview()
        }
    }
    
    private func createStackView(
        arrangedSubviews: [UIView],
        axis: NSLayoutConstraint.Axis,
        spacing: CGFloat = 8,
        alignment: UIStackView.Alignment = .fill,
        distribution: UIStackView.Distribution = .fill
    ) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        stackView.axis = axis
        stackView.spacing = spacing
        stackView.alignment = alignment
        stackView.distribution = distribution
        return stackView
    }
    
    public func configure(with rewardLevel: String) {
        character.image = UIImage(named: rewardLevel)
        guard let level = CharacterImage.levelMapping[rewardLevel] else { return }
        self.level.text = String(level)
    }

    
    //cell을 lock상태로 만드는 함수
    public func setLockedState() {
        background.isHidden = false
        background.backgroundColor = .blue100
        locked.isHidden = false
        unlocked.isHidden = true
        isLocked = true
    }
    
    //cell을 unlock상태로 만드는 함수
    public func setUnlockedState() {
        background.isHidden = false
        background.backgroundColor = UIColor(hex: "#FFF260")
        locked.isHidden = true
        unlocked.isHidden = false
        isLocked = false
    }
    
    //cell을 완전히 잠금해제로 만드는 함수
    public func setFullyUnlockedState() {
        background.isHidden = true
        locked.isHidden = true
        unlocked.isHidden = true
        isLocked = false
    }
    
    //현재 완전히 잠겨있는지 상태 반환
    public func getLockStatus() -> Bool {
        return isLocked
    }
}
