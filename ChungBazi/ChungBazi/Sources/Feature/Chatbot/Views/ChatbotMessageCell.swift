//
//  ChatbotMessageCell.swift
//  ChungBazi
//
//  Created by 신호연 on 6/8/25.
//

import UIKit
import SnapKit
import Then

final class ChatbotMessageCell: UITableViewCell {
    
    private let messageLabel = PaddingLabel().then {
        $0.numberOfLines = 0
        $0.lineBreakMode = .byCharWrapping
        $0.font = UIFont.ptdMediumFont(ofSize: 14)
        $0.layer.masksToBounds = true
    }
    
    private let timestampLabel = UILabel().then {
        $0.font = UIFont.ptdRegularFont(ofSize: 12)
        $0.textColor = UIColor.gray400
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
    
    private let buttonContainerView = UIView()
    
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
        contentView.addSubview(buttonContainerView)
    }
    
    func configure(with message: ChatbotMessage) {
        messageLabel.isHidden = true
        timestampLabel.isHidden = true
        botIconBackgroundView.isHidden = true
        buttonContainerView.isHidden = true
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        timestampLabel.text = dateFormatter.string(from: message.timestamp)
        
        switch message.type {
        case .text(let text):
            isUserMessage = message.isUser
            messageLabel.isHidden = false
            timestampLabel.isHidden = false
            messageLabel.text = text
            
            if isUserMessage {
                botIconBackgroundView.isHidden = true
                
                messageLabel.snp.remakeConstraints {
                    $0.top.bottom.equalToSuperview().inset(4)
                    $0.trailing.equalToSuperview().inset(16)
                    $0.width.lessThanOrEqualTo(243)
                }
                
                timestampLabel.snp.remakeConstraints {
                    $0.bottom.equalTo(messageLabel.snp.bottom)
                    $0.trailing.equalTo(messageLabel.snp.leading).offset(-9)
                }
                
                messageLabel.backgroundColor = UIColor.blue700
                messageLabel.textColor = UIColor.white
                
            } else {
                botIconBackgroundView.isHidden = false
                
                botIconBackgroundView.snp.remakeConstraints {
                    $0.top.equalToSuperview().offset(4)
                    $0.leading.equalToSuperview().offset(16)
                    $0.width.height.equalTo(47.25)
                }
                
                botIconImageView.snp.remakeConstraints {
                    $0.top.equalTo(botIconBackgroundView).offset(4)
                    $0.left.equalTo(botIconBackgroundView).offset(6)
                    $0.right.equalTo(botIconBackgroundView).inset(5.25)
                    $0.bottom.equalTo(botIconBackgroundView).inset(7.25)
                }
                
                messageLabel.snp.remakeConstraints {
                    $0.top.equalTo(botIconBackgroundView.snp.bottom).offset(9)
                    $0.leading.equalTo(botIconBackgroundView.snp.leading)
                    $0.width.lessThanOrEqualTo(230)
                    $0.bottom.equalToSuperview().inset(4)
                }
                
                timestampLabel.snp.remakeConstraints {
                    $0.bottom.equalTo(botIconBackgroundView.snp.bottom)
                    $0.leading.equalTo(botIconBackgroundView.snp.trailing).offset(10)
                }
                
                messageLabel.backgroundColor = UIColor.white
                messageLabel.textColor = UIColor.gray800
            }
            
        case .textWithButtons(let text, let buttons):
            isUserMessage = false
            botIconBackgroundView.isHidden = false
            timestampLabel.isHidden = false
            buttonContainerView.isHidden = false

            botIconBackgroundView.snp.remakeConstraints {
                $0.top.equalToSuperview().offset(4)
                $0.leading.equalToSuperview().offset(16)
                $0.width.height.equalTo(47.25)
            }

            botIconImageView.snp.remakeConstraints {
                $0.top.equalTo(botIconBackgroundView).offset(4)
                $0.left.equalTo(botIconBackgroundView).offset(6)
                $0.right.equalTo(botIconBackgroundView).inset(5.25)
                $0.bottom.equalTo(botIconBackgroundView).inset(7.25)
            }

            timestampLabel.snp.remakeConstraints {
                $0.bottom.equalTo(botIconBackgroundView.snp.bottom)
                $0.leading.equalTo(botIconBackgroundView.snp.trailing).offset(10)
            }

            messageLabel.isHidden = false
            messageLabel.text = text
            messageLabel.backgroundColor = UIColor.white
            messageLabel.textColor = UIColor.gray800

            messageLabel.snp.remakeConstraints {
                $0.top.equalTo(botIconBackgroundView.snp.bottom).offset(9)
                $0.leading.equalTo(botIconBackgroundView.snp.leading)
                $0.width.lessThanOrEqualTo(230)
            }

            buttonContainerView.subviews.forEach { $0.removeFromSuperview() }

            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var currentRowHeight: CGFloat = 0
            let horizontalSpacing: CGFloat = 9
            let verticalSpacing: CGFloat = 10
            let maxWidth: CGFloat = 262

            buttons.forEach { buttonModel in
                let design: ChatbotButtonView.Design = (buttonModel.style == .blue) ? .blue : .normal
                let button = ChatbotButtonView(title: buttonModel.title, design: design)
                
                // 텍스트 길이를 기준으로 계산
                let textWidth = button.titleLabel?.intrinsicContentSize.width ?? 0
                let textHeight = button.titleLabel?.intrinsicContentSize.height ?? 0
                
                // padding 포함해서 버튼 크기 계산
                let buttonWidth = textWidth + button.contentEdgeInsets.left + button.contentEdgeInsets.right
                let buttonHeight = textHeight + button.contentEdgeInsets.top + button.contentEdgeInsets.bottom
                
                // cornerRadius와 border 다시 적용
                button.layer.cornerRadius = 14
                button.layer.masksToBounds = true
                
                // 배치
                if currentX + buttonWidth > maxWidth {
                    currentX = 0
                    currentY += currentRowHeight + verticalSpacing
                    currentRowHeight = 0
                }
                
                button.frame = CGRect(x: currentX, y: currentY, width: buttonWidth, height: buttonHeight)
                buttonContainerView.addSubview(button)
                
                currentX += buttonWidth + horizontalSpacing
                currentRowHeight = max(currentRowHeight, buttonHeight)
            }

            buttonContainerView.snp.remakeConstraints {
                $0.top.equalTo(messageLabel.snp.bottom).offset(9.75)
                $0.leading.equalTo(botIconBackgroundView.snp.leading)
                $0.width.lessThanOrEqualTo(262)
                $0.height.equalTo(currentY + currentRowHeight)
                $0.bottom.equalToSuperview().inset(4)
            }
            
        default:
            break
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
