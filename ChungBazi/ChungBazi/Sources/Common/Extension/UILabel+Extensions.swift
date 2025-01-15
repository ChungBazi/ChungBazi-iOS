//
//  UILabel+Extensions.swift
//  ChungBazi
//
//  Created by 신호연 on 1/16/25.
//

import UIKit

extension UILabel {
    func setLineSpacing(ratio: Double) {
        self.lineBreakMode = .byWordWrapping
        self.lineBreakStrategy = .hangulWordPriority
        
        let style = NSMutableParagraphStyle()
        let lineheight = self.font.pointSize * CGFloat(ratio)
        style.minimumLineHeight = lineheight
        style.maximumLineHeight = lineheight
        
        self.attributedText = NSAttributedString(
            string: self.text ?? "", attributes: [
                .paragraphStyle: style
            ])
    }
    
    func addCharacterSpacing(_ value: Double = -0.032) {    //FIXME: 자간 변경
        let kernValue = self.font.pointSize * CGFloat(value)
        guard let text = text, !text.isEmpty else { return }
        let string = NSMutableAttributedString(string: text)
        string.addAttribute(NSAttributedString.Key.kern, value: kernValue, range: NSRange(location: 0, length: string.length - 1))
        attributedText = string
    }
    
    static func createLabel(text: String, textColor: UIColor, fontSize: CGFloat? = nil, lineHeightMultiple: CGFloat) -> UILabel {
        let label = B16_M(text: text, textColor: textColor)
        if let fontSize = fontSize {
            label.font = label.font.withSize(fontSize)
        }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = lineHeightMultiple
        paragraphStyle.alignment = .center
        let attributedText = NSMutableAttributedString(string: text)
        attributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: text.count))
        label.attributedText = attributedText
        label.numberOfLines = 0
        return label
    }
}
