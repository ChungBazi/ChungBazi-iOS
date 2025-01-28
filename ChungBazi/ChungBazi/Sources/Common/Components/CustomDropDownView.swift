//
//  CustomDropDownView.swift
//  ChungBazi
//
//  Created by 이현주 on 1/25/25.
//

import UIKit

class CustomDropdownView: UIView {

    // MARK: - Properties
    public lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "취업 상태를 선택하세요"
        label.font = UIFont.ptdMediumFont(ofSize: 16) // 원하는 폰트
        label.textColor = UIColor.gray400
        label.textAlignment = .left
        return label
    }()

    public lazy var dropdownImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "dropdown_icon")?.withRenderingMode(.alwaysOriginal)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let tapGesture = UITapGestureRecognizer() // 드롭다운을 열기 위한 탭 제스처

    public var onDropdownTapped: (() -> Void)? // 드롭다운 클릭 시 동작

    // MARK: - Initializer
    init(title: String, hasBorder: Bool) {
        super.init(frame: .zero)
        titleLabel.text = title
        layer.borderWidth = hasBorder ? 1 : 0
        layer.borderColor = hasBorder ? UIColor.gray400.cgColor : nil
        setupUI()
        addGestureRecognizer(tapGesture)
        tapGesture.addTarget(self, action: #selector(handleTap))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup UI
    private func setupUI() {
        layer.cornerRadius = 10
        backgroundColor = .white

        addSubview(titleLabel)
        addSubview(dropdownImageView)

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12) // 타이틀 왼쪽 여백
            make.centerY.equalToSuperview()
        }

        dropdownImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12) // 이미지 오른쪽 여백
            make.centerY.equalToSuperview()
        }

        self.snp.makeConstraints { make in
            make.height.equalTo(50) // 전체 높이 설정
        }
    }

    // MARK: - Actions
    @objc private func handleTap() {
        onDropdownTapped?() // 외부에서 정의한 동작 실행
    }
}

