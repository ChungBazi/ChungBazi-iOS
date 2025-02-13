//
//  PaddedLabel.swift
//  ChungBazi
//
//  Created by 엄민서 on 2/14/25.
//

import UIKit

class PaddedLabel: UILabel {
    var padding = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10) 

    override func drawText(in rect: CGRect) {
        let insetRect = rect.inset(by: padding)
        super.drawText(in: insetRect)
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + padding.left + padding.right,
                      height: size.height + padding.top + padding.bottom)
    }
}
