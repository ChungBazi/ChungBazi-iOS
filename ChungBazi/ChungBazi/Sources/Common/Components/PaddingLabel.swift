//
//  PaddingLabel.swift
//  ChungBazi
//
//  Created by 신호연 on 6/8/25.
//

import UIKit

class PaddingLabel: UILabel {
    var textInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
    
    override func drawText(in rect: CGRect) {
        let insets = textInsets
        super.drawText(in: rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        let width = size.width + textInsets.left + textInsets.right
        let height = size.height + textInsets.top + textInsets.bottom
        return CGSize(width: width, height: height)
    }
}
