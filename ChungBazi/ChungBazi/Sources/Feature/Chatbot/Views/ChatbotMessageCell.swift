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
        $0.layer.cornerRadius = 10
        $0.layer.masksToBounds = true
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
        $0.setContentHuggingPriority(.required, for: .vertical)
    }
    
    private let loadingContainerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
        $0.layer.masksToBounds = true
    }
    
    private let loadingDotsStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 6
        $0.alignment = .center
        $0.distribution = .equalSpacing
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
        $0.image = UIImage(resource: .questionBaro)
        $0.contentMode = .scaleAspectFit
    }
    
    private let buttonContainerView = UIView()
    
    private var isUserMessage: Bool = false
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        setupViews()
        setupLoadingDots()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        selectionStyle = .none
        contentView.addSubview(messageLabel)
        contentView.addSubview(loadingContainerView)
        loadingContainerView.addSubview(loadingDotsStackView)
        contentView.addSubview(timestampLabel)
        contentView.addSubview(botIconBackgroundView)
        botIconBackgroundView.addSubview(botIconImageView)
        contentView.addSubview(buttonContainerView)
    }
    
    private func setupLoadingDots() {
        let colors: [UIColor] = [
            UIColor.blue200,
            UIColor.blue500,
            UIColor.blue700
        ]
        
        for color in colors {
            let dot = createDot(color: color)
            loadingDotsStackView.addArrangedSubview(dot)
        }
        
        loadingDotsStackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(21)
            $0.height.equalTo(8)
        }
    }
    
    private func createDot(color: UIColor) -> UIView {
        let dot = UIView()
        dot.backgroundColor = color
        dot.layer.cornerRadius = 4
        dot.snp.makeConstraints {
            $0.width.height.equalTo(8)
        }
        return dot
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // 모든 뷰 숨김
        messageLabel.isHidden = true
        loadingContainerView.isHidden = true
        timestampLabel.isHidden = true
        botIconBackgroundView.isHidden = true
        buttonContainerView.isHidden = true
        
        // 텍스트 초기화
        messageLabel.text = nil
        timestampLabel.text = nil
        
        // 버튼 제거
        buttonContainerView.subviews.forEach { $0.removeFromSuperview() }
        
        // 제약조건 완전히 제거
        messageLabel.snp.removeConstraints()
        loadingContainerView.snp.removeConstraints()
        timestampLabel.snp.removeConstraints()
        botIconBackgroundView.snp.removeConstraints()
        botIconImageView.snp.removeConstraints()
        buttonContainerView.snp.removeConstraints()
    }
    
    func configure(with message: ChatbotMessage, delegate: ChatbotButtonCellDelegate?) {
        self.delegate = delegate
        
        messageLabel.isHidden = true
        loadingContainerView.isHidden = true
        timestampLabel.isHidden = true
        botIconBackgroundView.isHidden = true
        buttonContainerView.isHidden = true
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        timestampLabel.text = dateFormatter.string(from: message.timestamp)
        
        switch message.type {
        case .loading:
            isUserMessage = message.isUser
            botIconBackgroundView.isHidden = false
            loadingContainerView.isHidden = false
            
            botIconBackgroundView.snp.remakeConstraints {
                $0.top.equalToSuperview().offset(11)
                $0.leading.equalToSuperview().offset(16)
                $0.width.height.equalTo(47.25)
            }
            
            botIconImageView.snp.remakeConstraints {
                $0.top.equalTo(botIconBackgroundView).offset(4)
                $0.left.equalTo(botIconBackgroundView).offset(6)
                $0.right.equalTo(botIconBackgroundView).inset(5.25)
                $0.bottom.equalTo(botIconBackgroundView).inset(7.25)
            }
            
            loadingContainerView.snp.remakeConstraints {
                $0.top.equalTo(botIconBackgroundView.snp.bottom).offset(9)
                $0.leading.equalTo(botIconBackgroundView.snp.leading)
                $0.bottom.equalToSuperview().inset(19)
                $0.height.equalTo(40)
            }
        case .text(let text):
            isUserMessage = message.isUser
            messageLabel.isHidden = false
            timestampLabel.isHidden = false
            messageLabel.text = text
            
            if isUserMessage {
                botIconBackgroundView.isHidden = true
                
                messageLabel.snp.remakeConstraints {
                    $0.top.equalToSuperview().offset(3)
                    $0.trailing.equalToSuperview().inset(16)
                    $0.width.lessThanOrEqualTo(243)
                    $0.bottom.equalToSuperview().inset(11)
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
                    $0.top.equalToSuperview().offset(11)
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
                    $0.bottom.equalToSuperview().inset(19)
                }
                
                timestampLabel.snp.remakeConstraints {
                    $0.bottom.equalTo(messageLabel.snp.bottom)
                    $0.leading.equalTo(messageLabel.snp.trailing).offset(9)
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
                $0.bottom.equalTo(messageLabel.snp.bottom)
                $0.leading.equalTo(messageLabel.snp.trailing).offset(9)
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
                $0.bottom.equalToSuperview().inset(19)
            }
            
        default:
            break
        }
        
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        guard let title = sender.title(for: .normal) else { return }
        delegate?.chatbotButtonCell(ChatbotButtonCell(), didTapButtonWith: title)
    }
}
