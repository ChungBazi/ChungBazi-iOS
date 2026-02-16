//
//  DottedLineView.swift
//  ChungBazi
//
//  Created by 엄민서 on 2/7/25.
//

import UIKit

final class DottedLineView: UIView {
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setLineWidth(1)
        context.setStrokeColor(AppColor.gray300?.cgColor ?? UIColor.gray.cgColor)
        context.setLineDash(phase: 0, lengths: [9, 3]) 
        context.move(to: CGPoint(x: 0, y: rect.height / 2))
        context.addLine(to: CGPoint(x: rect.width, y: rect.height / 2))
        context.strokePath()
    }
}
