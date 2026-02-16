//
//  ProfileTableCell.swift
//  ChungBazi
//
//  Created by 신호연 on 1/25/25.
//

import UIKit
import SnapKit
import Then

final class ProfileTableCell: UITableViewCell {
    
    private let titleLabel = B16_M(text: "")
    private let arrowImg = UIImageView().then {
        $0.image = .moveIcon
        $0.contentMode = .scaleAspectFit
    }
    private let toggleSwitch = UISwitch().then {
        $0.isHidden = true
        $0.onTintColor = .blue700
        $0.isEnabled = true
    }
    
    var toggleChangedHandler: ((Bool) -> Void)?
    
    override init (style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        toggleSwitch.addTarget(self, action: #selector(toggleValueChanged), for: .valueChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubviews(titleLabel, arrowImg, toggleSwitch)

        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(32)
            $0.centerY.equalToSuperview()
        }

        arrowImg.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(26)
            $0.centerY.equalToSuperview()
        }

        toggleSwitch.snp.makeConstraints {
            $0.trailing.equalTo(arrowImg)
            $0.centerY.equalToSuperview()
        }
    }
    
    func configure(with title: String, isToggle: Bool = false, isOn: Bool = false) {
        titleLabel.text = title
        toggleSwitch.isHidden = !isToggle
        toggleSwitch.isOn = isOn

        selectionStyle = isToggle ? .none : .default
        contentView.isUserInteractionEnabled = !isToggle

        titleLabel.textColor = (title == "탈퇴") ? .buttonAccent : .black
        
        arrowImg.isHidden = isToggle || (title == "로그아웃" || title == "탈퇴")
    }
    
    @objc private func toggleValueChanged(_ sender: UISwitch) {
        toggleChangedHandler?(sender.isOn)
    }
    
    func setToggleState(_ isOn: Bool) {
        toggleSwitch.setOn(isOn, animated: true)
        toggleChangedHandler?(isOn)
    }
}
