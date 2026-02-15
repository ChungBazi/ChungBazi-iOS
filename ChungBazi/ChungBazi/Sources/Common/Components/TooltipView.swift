//
//  TooltipView.swift
//  ChungBazi
//
//  Created by 이현주 on 1/24/26.
//

import UIKit
import SnapKit
import Then

final class TooltipView: UIView {

    private let tooltipLabel = UILabel().then {
        $0.font = .ptdRegularFont(ofSize: 12)
        $0.textColor = .black
        $0.numberOfLines = 0
        $0.textAlignment = .left
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 10
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 4
        clipsToBounds = false
        
        alpha = 0
        isHidden = true

        addSubview(tooltipLabel)
        
        tooltipLabel.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(12)
            $0.verticalEdges.equalToSuperview().inset(10)
        }
    }

    // MARK: - Public
    /// 툴팁 표시
    func show(
        anchorView: UIView,
        text: String,
        width: CGFloat,
        duration: TimeInterval = 3
    ) {
        tooltipLabel.text = text
        
        guard let parentView = anchorView.superview else { return }
        
        parentView.addSubview(self)

        snp.remakeConstraints {
            $0.leading.equalTo(anchorView.snp.trailing).offset(8)
            $0.centerY.equalTo(anchorView)
            $0.width.equalTo(width)
        }

        parentView.layoutIfNeeded()

        isHidden = false
        alpha = 0

        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.hide()
        }
    }

    func hide() {
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0
        }) { _ in
            self.isHidden = true
        }
    }
}

