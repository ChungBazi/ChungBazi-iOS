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
        $0.register(ChatbotMessageCell.self, forCellReuseIdentifier: "ChatbotMessageCell")
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
            string: "궁금한점을 입력하세요.",
            attributes: [.foregroundColor: UIColor.gray300]
        )
        $0.layer.cornerRadius = 10
        $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 19, height: 1))
        $0.leftViewMode = .always
        $0.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 19 + 24 + 16, height: 1))
        $0.rightViewMode = .always
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
        setupTableView()
        setupChatInputView()
        fillSafeArea(position: .bottom, color: .white)
        loadDummyMessages()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
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
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(68)
        }
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupChatInputView() {
        view.addSubview(backgroundView)
        backgroundView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.height.equalTo(68)
        }

        view.addSubview(chatInputView)
        chatInputView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.height.equalTo(68)
        }
        
        chatInputView.addSubview(chatTextField)
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
        let userMessage = ChatbotMessage(text: messageText, isUser: true, timestamp: Date())
        messages.append(userMessage)
        tableView.reloadData()
        scrollToBottom()
        chatTextField.text = ""
        
        ChatbotDataManager.shared.sendMessage(messageText) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let botResponse):
                    self.messages.append(botResponse)
                    self.tableView.reloadData()
                    self.scrollToBottom()
                case .failure(let error):
                    print("❌ 메시지 전송 실패: \(error.localizedDescription)")
                }
                self.sendButton.isEnabled = true
            }
        }
    }
    
    private func scrollToBottom() {
        guard !messages.isEmpty else { return }
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    // MARK: - Keyboard Handling
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let window = view.window else { return }

        let keyboardHeight = window.frame.height - keyboardFrame.origin.y
        let safeAreaBottomInset = view.safeAreaInsets.bottom
        let adjustedKeyboardHeight = keyboardHeight - safeAreaBottomInset

        UIView.animate(withDuration: 0.3) {
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
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) {
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatbotMessageCell", for: indexPath) as? ChatbotMessageCell else {
            return UITableViewCell()
        }
        let message = messages[indexPath.row]
        cell.configure(with: message)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ChatbotViewController: UITableViewDelegate {}
