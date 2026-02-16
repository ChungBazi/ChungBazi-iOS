//
//  PaddingLabel.swift
//  ChungBazi
//
//  Created by 신호연 on 6/8/25.
//

import UIKit

class PaddingLabel: UILabel {
    var textInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16) {
        didSet {
            setNeedsDisplay()
            invalidateIntrinsicContentSize()
        }
    }

    override func drawText(in rect: CGRect) {
        let insetRect = rect.inset(by: textInsets)
        super.drawText(in: insetRect)
    }
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insetBounds = bounds.inset(by: textInsets)
        let textRect = super.textRect(forBounds: insetBounds, limitedToNumberOfLines: numberOfLines)
        
        let invertedInsets = UIEdgeInsets(
            top: -textInsets.top,
            left: -textInsets.left,
            bottom: -textInsets.bottom,
            right: -textInsets.right
        )
        return textRect.inset(by: invertedInsets)
    }
}
