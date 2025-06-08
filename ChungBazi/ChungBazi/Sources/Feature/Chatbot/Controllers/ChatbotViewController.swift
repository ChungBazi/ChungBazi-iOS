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
    
    private let sendButton = UIButton.createWithImage(
        image: .sendIcon,
        tintColor: .blue700,
        target: self,
        action: #selector(sendButtonTapped)
    )
    
    // MARK: - Properties
    private var messages: [ChatbotMessage] = []
    private var chatInputBottomConstraint: Constraint?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue50
        
        addCustomNavigationBar(titleText: "바로봇", showBackButton: true)
        setupInputView()
        setupTableView()
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
            $0.bottom.equalTo(chatInputView.snp.top)
        }
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
    }
    
    private func setupInputView() {
        view.addSubview(chatInputView)
        chatInputView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.height.equalTo(68)
        }
        chatInputView.roundCorners(corners: [.topLeft, .topRight], radius: 10)
        
        chatInputView.addSubview(chatTextField)
        chatInputView.addSubview(sendButton)
        
        sendButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(Constants.gutter)
            $0.width.height.equalTo(24)
        }
        
        chatTextField.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(Constants.gutter)
            $0.top.bottom.equalToSuperview().inset(10)
            $0.trailing.equalTo(sendButton.snp.leading).offset(-10)
        }
    }
    
    // MARK: - Data
    private func loadDummyMessages() {
        messages = ChatbotDataManager.shared.getDummyMessages()
        tableView.reloadData()
    }
    
    // MARK: - Actions
    @objc private func sendButtonTapped() {
        guard let text = chatTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else {
            return
        }
        let newMessage = ChatbotMessage(text: text, isUser: true, timestamp: Date())
        messages.append(newMessage)
        tableView.reloadData()
        let lastRow = messages.count - 1
        let indexPath = IndexPath(row: lastRow, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        chatTextField.text = ""
    }
    
    // MARK: - Keyboard Handling
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let window = view.window else { return }
        
        let keyboardHeight = window.frame.height - keyboardFrame.origin.y
        
        UIView.animate(withDuration: 0.3) {
            self.chatInputView.snp.updateConstraints {
                $0.bottom.equalToSuperview().offset(-keyboardHeight)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.chatInputView.snp.updateConstraints {
                $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
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
