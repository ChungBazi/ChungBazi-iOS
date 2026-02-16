//
//  WrappingStackView.swift
//  ChungBazi
//
//  Created by 신호연 on 6/8/25.
//

import UIKit
import SnapKit

final class WrappingStackView: UIView {
    private var buttonViews: [UIView] = []
    private let horizontalSpacing: CGFloat = 9
    private let verticalSpacing: CGFloat = 10
    private let maxWidth: CGFloat = 262
    
    func configure(buttons: [UIButton]) {
        buttonViews.forEach { $0.removeFromSuperview() }
        buttonViews.removeAll()
        
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var currentRowHeight: CGFloat = 0
        
        for button in buttons {
            let size = button.intrinsicContentSize
            let buttonWidth = size.width + button.contentEdgeInsets.left + button.contentEdgeInsets.right
            
            if currentX + buttonWidth > maxWidth {
                currentX = 0
                currentY += currentRowHeight + verticalSpacing
                currentRowHeight = 0
            }
            
            addSubview(button)
            button.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(currentX)
                make.top.equalToSuperview().offset(currentY)
            }
            
            currentX += buttonWidth + horizontalSpacing
            currentRowHeight = max(currentRowHeight, size.height + button.contentEdgeInsets.top + button.contentEdgeInsets.bottom)
            
            buttonViews.append(button)
        }
    }
}
