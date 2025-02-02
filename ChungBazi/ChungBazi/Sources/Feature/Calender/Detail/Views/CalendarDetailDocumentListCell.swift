//
//  CalendarDetailDocumentListCell.swift
//  ChungBazi
//
//  Created by 신호연 on 2/2/25.
//

import UIKit
import SnapKit
import Then

final class CalendarDetailDocumentListCell: UITableViewCell {
    
    private let checkButton = UIButton.createWithImage(image: .checkboxUnchecked, target: self, action: #selector(didTapCheckButton))
    private let textField = UITextField().then {
        $0.font = .ptdMediumFont(ofSize: 16)
        $0.textColor = .gray800
        $0.attributedPlaceholder = NSAttributedString(
            string: "서류 내용을 입력하세요",
            attributes: [.foregroundColor: UIColor.gray300]
        )
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
        addSubviews(checkButton, textField)
        checkButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20)
            $0.leading.equalToSuperview().inset(25)
            $0.size.equalTo(24)
        }
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
        checkButton.setImage(document.isChecked ? .checkboxChecked : .checkboxUnchecked, for: .normal)
    }

    @objc private func didTapCheckButton() {
        guard let document = document else { return }
        self.document?.isChecked.toggle()
        checkButton.setImage(document.isChecked ? .checkboxChecked : .checkboxUnchecked, for: .normal)
    }
    
}
