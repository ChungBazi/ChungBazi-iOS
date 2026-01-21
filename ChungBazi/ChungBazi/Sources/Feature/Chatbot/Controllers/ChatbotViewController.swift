//
//  ChatbotViewController.swift
//  ChungBazi
//
//  Created by 신호연 on 6/8/25.
//

import UIKit
import SnapKit
import Then
import SafeAreaBrush

final class ChatbotViewController: UIViewController {
    
    // MARK: - UI Components
    private let tableView = UITableView().then {
        $0.separatorStyle = .none
        $0.backgroundColor = .clear
    }
    
    private let chatInputView = UIView().then {
        $0.backgroundColor = .white
    }
    
    private let chatTextField = UITextField().then {
        $0.backgroundColor = .blue50
        $0.font = .ptdMediumFont(ofSize: 16)
        $0.textColor = .gray800
        $0.attributedPlaceholder = NSAttributedString(
            string: "궁금한 점을 입력하세요.",
            attributes: [.foregroundColor: UIColor.gray300]
        )
        $0.layer.cornerRadius = 10
        $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 19, height: 1))
        $0.leftViewMode = .always
        $0.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 19 + 24 + 16, height: 1))
        $0.rightViewMode = .always
        $0.autocorrectionType = .no
        $0.spellCheckingType = .no
    }
    
    private let sendButton = UIButton.createWithImage(image: .sendIcon, tintColor: .blue700, target: self, action: #selector(sendButtonTapped))
    
    private let backgroundView = UIView().then {
        $0.backgroundColor = .white
    }
    
    // MARK: - Properties
    private var messages: [ChatbotMessage] = []
    private var chatInputBottomConstraint: Constraint?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue50
        
        addCustomNavigationBar(titleText: "바로봇", showBackButton: true)
        
        setupChatInputView()
        setupTableView()
        fillSafeArea(position: .bottom, color: .white)
        loadDummyMessages()
        
        enableKeyboardHandling(for: tableView, inputView: chatInputView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(Constants.navigationHeight)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(chatInputView.snp.top)
        }
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.contentInset = .zero
        tableView.scrollIndicatorInsets = .zero
        tableView.register(ChatbotMessageCell.self, forCellReuseIdentifier: "ChatbotMessageCell")
    }
    
    private func setupChatInputView() {
        view.addSubview(chatInputView)
        chatInputView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.height.equalTo(68)
        }
        
        chatInputView.layer.shadowPath = UIBezierPath(
            roundedRect: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 68),
            cornerRadius: 10
        ).cgPath
        chatInputView.layer.shadowColor = UIColor.black.withAlphaComponent(0.18).cgColor
        chatInputView.layer.shadowOpacity = 1
        chatInputView.layer.shadowRadius = 10
        chatInputView.layer.shadowOffset = CGSize(width: 0, height: 3)
        chatInputView.layer.masksToBounds = false
        
        backgroundView.layer.cornerRadius = 10
        backgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        backgroundView.clipsToBounds = true
        
        chatInputView.addSubview(backgroundView)
        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        backgroundView.addSubview(chatTextField)
        chatTextField.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(Constants.gutter)
            $0.top.bottom.equalToSuperview().inset(10)
        }
        
        chatTextField.addSubview(sendButton)
        sendButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(Constants.gutter)
        }
    }
    
    // MARK: - Data
    private func loadDummyMessages() {
        messages = ChatbotDataManager.shared.getDummyMessages()
        tableView.reloadData()
    }
    
    // MARK: - Actions
    @objc private func sendButtonTapped() {
        guard let messageText = chatTextField.text,
              !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              sendButton.isEnabled else { return }
        
        sendButton.isEnabled = false
        
        // 사용자 메시지 추가
        let userMessage = ChatbotMessage(type: .text(messageText), isUser: true, timestamp: Date())
        messages.append(userMessage)
        
        // 로딩 메시지 추가
        let loadingMessage = ChatbotMessage(type: .loading, isUser: false, timestamp: Date())
        messages.append(loadingMessage)
        
        tableView.performBatchUpdates({
            let userIndexPath = IndexPath(row: messages.count - 2, section: 0)
            let loadingIndexPath = IndexPath(row: messages.count - 1, section: 0)
            tableView.insertRows(at: [userIndexPath, loadingIndexPath], with: .none)
        }, completion: { _ in
            self.scrollToBottom()
        })
        
        chatTextField.text = ""
        
        ChatbotDataManager.shared.sendMessage(messageText) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                // 챗봇 로딩 메시지 제거
                if let lastMessage = self.messages.last, case .loading = lastMessage.type {
                    self.messages.removeLast()
                    let loadingIndexPath = IndexPath(row: self.messages.count, section: 0)
                    self.tableView.deleteRows(at: [loadingIndexPath], with: .none)
                }
                
                // 실제 응답 추가
                switch result {
                case .success(let botResponse):
                    self.messages.append(botResponse)
                    let responseIndexPath = IndexPath(row: self.messages.count - 1, section: 0)
                    
                    self.tableView.performBatchUpdates({
                        self.tableView.insertRows(at: [responseIndexPath], with: .none)
                    }, completion: { _ in
                        self.scrollToBottom()
                    })
                case .failure(let error):
                    print("❌ 메시지 전송 실패: \(error.localizedDescription)")
                }
                self.sendButton.isEnabled = true
            }
        }
    }
    
    func sendMessage(text: String) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else {
            print("⚠️ [sendMessage] 빈 문자열입니다. 전송 중단.")
            return
        }

        // 1. 사용자 메시지 추가
        let userMessage = ChatbotMessage(
            type: .text(trimmedText),
            isUser: true,
            timestamp: Date()
        )
        messages.append(userMessage)
        
        let loadingMessage = ChatbotMessage(type: .loading, isUser: false, timestamp: Date())
        messages.append(loadingMessage)
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.scrollToBottom()
        }

        // 2. 더미 응답 요청
        ChatbotDataManager.shared.sendMessage(trimmedText) { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.main.async {
                // 로딩 메시지 제거
                if let lastMessage = self.messages.last, case .loading = lastMessage.type {
                    self.messages.removeLast()
                }
                
                switch result {
                case .success(let botMessage):
                    print("🤖 [응답 수신] \(botMessage)")
                    self.messages.append(botMessage)
                    self.tableView.reloadData()
                    DispatchQueue.main.async {
                        self.scrollToBottom()
                    }
                case .failure(let error):
                    print("❌ [응답 실패] \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func scrollToBottom() {
        guard !messages.isEmpty else { return }
        
        tableView.layoutIfNeeded()
        
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        
        if tableView.numberOfRows(inSection: 0) > indexPath.row {
            // 애니메이션 없이 즉시 스크롤
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
            
            // contentOffset을 직접 계산
            DispatchQueue.main.async {
                let contentHeight = self.tableView.contentSize.height
                let tableViewHeight = self.tableView.bounds.height
                
                if contentHeight > tableViewHeight {
                    // 전체 컨텐츠 높이 - 보이는 영역 높이
                    let bottomOffset = CGPoint(x: 0, y: contentHeight - tableViewHeight)
                    self.tableView.setContentOffset(bottomOffset, animated: false)
                }
            }
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Keyboard Handling
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }

        let keyboardHeight = keyboardFrame.height

        UIView.animate(withDuration: duration) {
            self.chatInputView.snp.remakeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.bottom.equalToSuperview().offset(-keyboardHeight)
                make.height.equalTo(68)
            }

            self.tableView.snp.remakeConstraints { make in
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(Constants.navigationHeight)
                make.bottom.equalTo(self.chatInputView.snp.top)
                make.leading.trailing.equalToSuperview()
            }

            self.view.layoutIfNeeded()
        } completion: { _ in
            // 레이아웃 업데이트 후 스크롤
            self.scrollToBottom()
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        UIView.animate(withDuration: duration) {
            self.chatInputView.snp.remakeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
                make.height.equalTo(68)
            }
            
            self.tableView.snp.remakeConstraints { make in
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(Constants.navigationHeight)
                make.bottom.equalTo(self.chatInputView.snp.top)
                make.leading.trailing.equalToSuperview()
            }
            
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - UITableViewDataSource
extension ChatbotViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatbotMessageCell", for: indexPath) as? ChatbotMessageCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        cell.configure(with: message, delegate: self)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ChatbotViewController: UITableViewDelegate {}

// MARK: - ChatbotButtonCellDelegate
extension ChatbotViewController: ChatbotButtonCellDelegate {
    func chatbotButtonCell(_ cell: ChatbotButtonCell, didTapButtonWith title: String) {
        sendMessage(text: title)
    }
}
