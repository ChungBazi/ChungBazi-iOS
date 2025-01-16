//
//  UIView+Extension.swift
//  ChungBazi
//
//  Created by 신호연 on 1/16/25.
//

import UIKit

extension UIView {

    /// 전체 코너에 둥근 모서리 적용
    func createRoundedView(radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
}
