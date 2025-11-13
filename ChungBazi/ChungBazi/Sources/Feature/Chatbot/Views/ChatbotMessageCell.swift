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
    
    weak var delegate: ChatbotButtonCellDelegate?
    weak var messageDelegate: ChatbotMessageCellDelegate?
    
    private let messageLabel = PaddingLabel().then {
        $0.numberOfLines = 0
        $0.lineBreakMode = .byCharWrapping
        $0.font = UIFont.ptdMediumFont(ofSize: 14)
        $0.layer.masksToBounds = true
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
        $0.setContentHuggingPriority(.required, for: .vertical)
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
    
    func configure(with message: ChatbotMessage, delegate: ChatbotButtonCellDelegate?) {
        self.delegate = delegate
        
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
                let design: ChatbotButtonCell.Design = (buttonModel.style == .blue) ? .blue : .normal

                // UIButton 생성
                let button = UIButton(type: .system)
                button.setTitle(buttonModel.title, for: .normal)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
                button.layer.cornerRadius = 14
                button.layer.masksToBounds = true
                button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 13, bottom: 6, right: 13)
                button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)

                // 디자인 스타일 적용
                switch design {
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

                // 텍스트 길이를 기준으로 계산
                let textWidth = button.titleLabel?.intrinsicContentSize.width ?? 0
                let textHeight = button.titleLabel?.intrinsicContentSize.height ?? 0

                // padding 포함해서 버튼 크기 계산
                let buttonWidth = textWidth + button.contentEdgeInsets.left + button.contentEdgeInsets.right
                let buttonHeight = textHeight + button.contentEdgeInsets.top + button.contentEdgeInsets.bottom

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
    
    @objc private func buttonTapped(_ sender: UIButton) {
        guard let title = sender.title(for: .normal) else { return }
        delegate?.chatbotButtonCell(ChatbotButtonCell(), didTapButtonWith: title)
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
