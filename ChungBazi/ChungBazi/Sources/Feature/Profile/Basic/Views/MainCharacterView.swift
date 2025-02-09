//
//  MainCharacterView.swift
//  ChungBazi
//
//  Created by 이현주 on 2/10/25.
//

import UIKit

class MainCharacterView: UIView {
    var remainPost: Int = 0
    var remainComment: Int = 0

    private lazy var myYellowCrown = UIImageView().then {
        $0.image = .rewardColorIcon
        $0.contentMode = .scaleAspectFit
    }

    private lazy var myLevel = UILabel().then {
        $0.text = "3"
        $0.font = UIFont.ptdSemiBoldFont(ofSize: 24)
        $0.textColor = UIColor(hex: "#FFF260")
    }

    private lazy var myNickname = UILabel().then {
        $0.text = "청바로"
        $0.font = UIFont.ptdSemiBoldFont(ofSize: 20)
        $0.textColor = .white
    }

    private lazy var remainWhiteCrown = UIImageView().then {
        $0.image = .rewardIcon.withRenderingMode(.alwaysTemplate)
        $0.tintColor = .gray100
    }

    private lazy var nextLevel = UILabel().then {
        $0.text = "4"
        $0.font = UIFont.ptdSemiBoldFont(ofSize: 16)
        $0.textColor = .gray100
    }

    private lazy var remainText = UILabel().then {
        $0.font = UIFont.ptdSemiBoldFont(ofSize: 16)
        $0.textColor = .gray100
        $0.text = "까지 글 \(remainPost)개 댓글 \(remainComment)개 남았어요!"
    }

    private lazy var starBackground = UIImageView().then {
        $0.image = .starBackground
        $0.contentMode = .scaleAspectFit
    }

    private lazy var stage = UIImageView().then {
        $0.image = .stage
        $0.contentMode = .scaleAspectFit
    }

    private lazy var stageCrown = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .alarmRewardIcon
    }

    private lazy var stageLevel = UILabel().then {
        $0.text = "3"
        $0.font = UIFont.ptdSemiBoldFont(ofSize: 16)
        $0.textColor = .blue700
    }

    private lazy var character = UIImageView().then {
        $0.image = .LEVEL_2
        $0.contentMode = .scaleAspectFit
    }

    private lazy var confetti = UIImageView().then {
        $0.image = .confetti
        $0.contentMode = .scaleAspectFit
        $0.isHidden = true
    }

    private lazy var myLevelStackView = createStackView(arrangedSubviews: [myYellowCrown, myLevel], axis: .horizontal, spacing: 4)
    private lazy var myInfoStackView = createStackView(arrangedSubviews: [myLevelStackView, myNickname], axis: .horizontal)

    private lazy var remainLevelStackView = createStackView(arrangedSubviews: [remainWhiteCrown, nextLevel], axis: .horizontal, spacing: 4)
    private lazy var remainInfoStackView = createStackView(arrangedSubviews: [remainLevelStackView, remainText], axis: .horizontal)

    private lazy var stageInfoStackView = createStackView(arrangedSubviews: [stageCrown, stageLevel], axis: .horizontal, spacing: 2)

    override init(frame: CGRect) {
        super.init(frame: frame)
        addComponents()
        setConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addComponents() {
        [starBackground, myInfoStackView, remainInfoStackView, stage, character, confetti].forEach { self.addSubview($0) }
        stage.addSubview(stageInfoStackView)
    }

    private func setConstraints() {
        starBackground.snp.makeConstraints {
            $0.top.equalToSuperview().offset(7)
            $0.leading.equalToSuperview().offset(15)
            //$0.trailing.equalToSuperview().offset(-33)
            $0.height.equalTo(461)
            $0.bottom.equalToSuperview()
        }
        
        myYellowCrown.snp.makeConstraints {
            $0.size.equalTo(36)
        }
        
        myInfoStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(7)
            $0.leading.equalToSuperview().offset(31)
        }
        
        remainWhiteCrown.snp.makeConstraints {
            $0.size.equalTo(24)
        }
        
        remainInfoStackView.snp.makeConstraints {
            $0.top.equalTo(myInfoStackView.snp.bottom).offset(7)
            $0.leading.equalTo(myInfoStackView.snp.leading).offset(4)
        }
        
        stage.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-77)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(Constants.superViewWidth * 0.64)
        }
        
        stageCrown.snp.makeConstraints {
            $0.size.equalTo(24)
        }
        
        stageInfoStackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-7)
        }
        
        character.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(stage.snp.bottom).offset(-34)
            $0.width.equalTo(Constants.superViewWidth * 0.67)
        }
        
        confetti.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(18)
            $0.bottom.equalTo(stage.snp.bottom).offset(-47)
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
    
    //위에 두줄 값들 바꾸는 함수
    //캐릭터이미지, stage level 바꾸는 함수
    //빵빠레 5초동안 유지됐다가 hidden하는 함수
}
