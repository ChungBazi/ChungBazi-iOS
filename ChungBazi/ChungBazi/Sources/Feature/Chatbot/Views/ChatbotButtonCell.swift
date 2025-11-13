//
//  ChatbotButtonCell.swift
//  ChungBazi
//
//  Created by 신호연 on 6/8/25.
//

import UIKit
import Then
import SnapKit

protocol ChatbotButtonCellDelegate: AnyObject {
    func chatbotButtonCell(_ cell: ChatbotButtonCell, didTapButtonWith title: String)
}

protocol ChatbotMessageCellDelegate: AnyObject {
    func chatbotMessageCell(_ cell: ChatbotMessageCell, didTapButtonWith title: String)
}

final class ChatbotButtonCell: UITableViewCell {

    enum Design {
        case blue
        case normal
    }

    weak var delegate: ChatbotButtonCellDelegate?

    private let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.alignment = .fill
        $0.distribution = .fillEqually
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    }

    func configure(with buttons: [(title: String, design: Design)]) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for buttonInfo in buttons {
            let button = UIButton(type: .system)
            button.setTitle(buttonInfo.title, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            button.layer.cornerRadius = 14
            button.layer.masksToBounds = true
            button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 13, bottom: 6, right: 13)

            switch buttonInfo.design {
            case .blue:
                button.setTitleColor(UIColor(named: "blue700") ?? .blue, for: .normal)
                button.layer.borderWidth = 1
                button.layer.borderColor = UIColor(named: "blue700")?.cgColor ?? UIColor.blue.cgColor
                button.backgroundColor = .white
            case .normal:
                button.setTitleColor(UIColor(named: "gray800") ?? .darkGray, for: .normal)
                button.layer.borderWidth = 0
                button.layer.borderColor = UIColor.clear.cgColor
                button.backgroundColor = .white
            }

            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
    }

    
    @objc private func buttonTapped(_ sender: UIButton) {
        guard let title = sender.title(for: .normal) else {
            print("❌ 버튼 타이틀 없음")
            return
        }
        delegate?.chatbotButtonCell(self, didTapButtonWith: title)
    }
}
