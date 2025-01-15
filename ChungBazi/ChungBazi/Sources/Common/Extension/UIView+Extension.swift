//
//  UIView+Extension.swift
//  ChungBazi
//
//  Created by 신호연 on 1/16/25.
//

import UIKit

extension UIView {
    
    /// 특정 코너에 둥근 모서리 적용
    func createRoundView(corners: UIRectCorner = .allCorners, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    /// 전체 코너에 둥근 모서리 적용
    func createRoundedView(radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
}
