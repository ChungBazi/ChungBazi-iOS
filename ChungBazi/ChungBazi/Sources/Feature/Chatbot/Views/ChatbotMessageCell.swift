//
//  ChatbotMessageCell.swift
//  ChungBazi
//
//  Created by 신호연 on 6/8/25.
//

import UIKit
import SnapKit
import Then

class ChatbotMessageCell: UITableViewCell {
    
    private let messageLabel = PaddingLabel().then {
        $0.numberOfLines = 0
        $0.lineBreakMode = .byCharWrapping
        $0.layer.masksToBounds = true
        $0.font = UIFont.ptdMediumFont(ofSize: 14)
    }
    
    private var isUserMessage: Bool = false
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        selectionStyle = .none
        contentView.addSubview(messageLabel)
    }
    
    func configure(with message: ChatbotMessage) {
        isUserMessage = message.isUser
        messageLabel.text = message.text
        
        messageLabel.snp.remakeConstraints {
            $0.top.bottom.equalToSuperview().inset(4)
            if message.isUser {
                $0.trailing.equalToSuperview().inset(16)
                $0.width.lessThanOrEqualTo(243)
            } else {
                $0.leading.equalToSuperview().offset(16)
                $0.width.lessThanOrEqualTo(230)
            }
        }
        
        if message.isUser {
            messageLabel.backgroundColor = UIColor.blue700
            messageLabel.textColor = UIColor.white
        } else {
            messageLabel.backgroundColor = UIColor.white
            messageLabel.textColor = UIColor.gray800
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if isUserMessage {
            messageLabel.applyUserBubbleStyle()
        } else {
            messageLabel.applyChatbotBubbleStyle()
        }
    }
}
