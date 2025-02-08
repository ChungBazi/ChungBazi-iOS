//
//  UIWrapStackView.swift
//  ChungBazi
//
//  Created by 신호연 on 2/9/25.
//

import UIKit

/// 가로로 정렬된 뷰들이 가득 차면 자동으로 다음 줄로 넘겨 배치하는 StackView 대체 클래스
final class UIWrapStackView: UIView {
    var spacing: CGFloat = 8
    var verticalSpacing: CGFloat = 8
    private var arrangedSubviews: [UIView] = []

    func addArrangedSubview(_ view: UIView) {
        arrangedSubviews.append(view)
        addSubview(view)
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var maxRowHeight: CGFloat = 0

        for subview in arrangedSubviews {
            let subviewSize = subview.intrinsicContentSize
            let subviewWidth = subviewSize.width
            let subviewHeight = subviewSize.height

            if currentX + subviewWidth > bounds.width {
                currentX = 0
                currentY += maxRowHeight + verticalSpacing
                maxRowHeight = 0
            }

            subview.frame = CGRect(x: currentX, y: currentY, width: subviewWidth, height: subviewHeight)
            currentX += subviewWidth + spacing
            maxRowHeight = max(maxRowHeight, subviewHeight)
        }
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var totalHeight: CGFloat = 0
        var currentX: CGFloat = 0
        var maxRowHeight: CGFloat = 0

        for subview in arrangedSubviews {
            let subviewSize = subview.intrinsicContentSize
            let subviewWidth = subviewSize.width
            let subviewHeight = subviewSize.height

            if currentX + subviewWidth > size.width {
                currentX = 0
                totalHeight += maxRowHeight + verticalSpacing
                maxRowHeight = 0
            }

            currentX += subviewWidth + spacing
            maxRowHeight = max(maxRowHeight, subviewHeight)
        }

        totalHeight += maxRowHeight
        return CGSize(width: size.width, height: totalHeight)
    }
}
