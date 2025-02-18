//
//  CalendarDetailDocumentListCell.swift
//  ChungBazi
//
//  Created by 신호연 on 2/2/25.
//

import UIKit
import SnapKit
import Then

protocol CalendarDetailDocumentListCellDelegate: AnyObject {
    func didUpdateText(for cell: CalendarDetailDocumentListCell, newText: String)
}

final class CalendarDetailDocumentListCell: UITableViewCell, UITextFieldDelegate {
    
    weak var textFieldDelegate: CalendarDetailDocumentListCellDelegate?
    
    var onTextChanged: ((String) -> Void)?
    var onCheckChanged: ((Bool) -> Void)?
    
    private let checkButton = UIButton().then {
        $0.setImage(UIImage(named: "checkbox_unchecked")?.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = .gray500
        $0.addTarget(self, action: #selector(didTapCheckButton), for: .touchUpInside)
        $0.isUserInteractionEnabled = true
    }
    
    private let textField = UITextField().then {
        $0.font = .ptdMediumFont(ofSize: 16)
        $0.textColor = .gray800
        $0.attributedPlaceholder = NSAttributedString(
            string: "서류 내용을 입력하세요",
            attributes: [.foregroundColor: UIColor.gray300]
        )
        $0.isUserInteractionEnabled = false
    }
    
    private var document: Document?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError( "init(coder:) has not been implemented" )
    }
    
    private func setupUI() {
        selectionStyle = .none
        contentView.isUserInteractionEnabled = false
        addSubviews(checkButton, textField)
        checkButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20)
            $0.leading.equalToSuperview().inset(25)
            $0.size.equalTo(24)
        }
        textField.delegate = self
        textField.snp.makeConstraints {
            $0.top.equalTo(checkButton)
            $0.leading.equalTo(checkButton.snp.trailing).offset(14)
            $0.trailing.equalToSuperview().inset(25)
            $0.bottom.equalToSuperview().inset(20)
        }
    }
    
    func configure(with document: Document) {
        self.document = document
        textField.text = document.name
        updateCheckButton()
    }

    @objc private func didTapCheckButton() {
        guard let document = document else { return }
        let newCheckedState = !document.isChecked
        onCheckChanged?(newCheckedState)
        
        self.document?.isChecked = newCheckedState
        updateCheckButton()
    }
    
    func unTapCheckButton() {
        checkButton.isEnabled = false
    }

    private func updateCheckButton() {
        let imageName = document?.isChecked == true ? "checkbox_checked" : "checkbox_unchecked"
        checkButton.setImage(UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate), for: .normal)
        checkButton.tintColor = document?.isChecked == true ? .blue700 : .gray500
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // 키보드 해제
        return true
    }
    
    func textFieldUIEnabled() {
        textField.isUserInteractionEnabled = true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        onTextChanged?(textField.text ?? "")
    }
}
