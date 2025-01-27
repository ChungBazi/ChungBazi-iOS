//
//  UIView+Extensions.swift
//  ChungBazi
//
//  Created by 신호연 on 1/16/25.
//

import UIKit

extension UIView {

    /// 전체 코너에 둥근 모서리 적용
    func createRoundedView(radius: CGFloat = 10) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
    
    /// 여러 서브뷰 한 번에 추가
    func addSubviews(_ views: UIView...) {
        views.forEach { self.addSubview($0) }
    }
}
