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
    
    private let timestampLabel = UILabel().then {
        $0.font = UIFont.ptdMediumFont(ofSize: 14)
        $0.textColor = UIColor.gray300
    }
    
    private let botIconBackgroundView = UIView().then {
        $0.backgroundColor = UIColor.green300
        $0.layer.cornerRadius = 47.25 / 2
        $0.clipsToBounds = true
    }
    
    private let botIconImageView = UIImageView().then {
        $0.image = UIImage(named: "questionBaro")
        $0.contentMode = .scaleAspectFit
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
        contentView.addSubview(timestampLabel)
        contentView.addSubview(botIconBackgroundView)
        botIconBackgroundView.addSubview(botIconImageView)
    }
    
    func configure(with message: ChatbotMessage) {
        isUserMessage = message.isUser
        messageLabel.text = message.text
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        timestampLabel.text = dateFormatter.string(from: message.timestamp)
        
        messageLabel.snp.removeConstraints()
        timestampLabel.snp.removeConstraints()
        botIconBackgroundView.snp.removeConstraints()
        botIconImageView.snp.removeConstraints()
        
        if message.isUser {
            botIconBackgroundView.isHidden = true
            timestampLabel.isHidden = false
            
            messageLabel.snp.makeConstraints {
                $0.top.bottom.equalToSuperview().inset(4)
                $0.trailing.equalToSuperview().inset(16)
                $0.width.lessThanOrEqualTo(243)
            }
            
            timestampLabel.snp.makeConstraints {
                $0.bottom.equalTo(messageLabel.snp.bottom)
                $0.trailing.equalTo(messageLabel.snp.leading).offset(-9)
            }
            
            messageLabel.backgroundColor = UIColor.blue700
            messageLabel.textColor = UIColor.white
            
        } else {
            botIconBackgroundView.isHidden = false
            timestampLabel.isHidden = false
            
            botIconBackgroundView.snp.makeConstraints {
                $0.top.equalToSuperview().offset(4)
                $0.leading.equalToSuperview().offset(16)
                $0.width.height.equalTo(47.25)
            }
            
            botIconImageView.snp.makeConstraints {
                $0.top.equalTo(botIconBackgroundView).offset(4)
                $0.left.equalTo(botIconBackgroundView).offset(6)
                $0.right.equalTo(botIconBackgroundView).inset(5.25)
                $0.bottom.equalTo(botIconBackgroundView).inset(7.25)
            }
            
            messageLabel.snp.makeConstraints {
                $0.top.equalTo(botIconBackgroundView.snp.bottom).offset(9)
                $0.leading.equalTo(botIconBackgroundView.snp.leading)
                $0.width.lessThanOrEqualTo(230)
                $0.bottom.equalToSuperview().inset(4)
            }
            
            timestampLabel.snp.makeConstraints {
                $0.bottom.equalTo(botIconBackgroundView.snp.bottom)
                $0.leading.equalTo(botIconBackgroundView.snp.trailing).offset(10)
            }
            
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
