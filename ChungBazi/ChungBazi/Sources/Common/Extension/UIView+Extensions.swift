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
    
    /// 특정 모서리에만 둥근 모서리 적용
    func roundCorners(corners: UIRectCorner, radius: CGFloat = 10) {
        let path = UIBezierPath(
            roundedRect: self.bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    /// 챗봇 메시지용 말풍선: 왼쪽 위는 0, 나머지는 radius
    func applyChatbotBubbleStyle(radius: CGFloat = 10) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.layoutIfNeeded()
            self.roundCorners(corners: [.topRight, .bottomLeft, .bottomRight], radius: radius)
        }
    }
    
    /// 사용자 메시지용 말풍선: 오른쪽 위는 0, 나머지는 radius
    func applyUserBubbleStyle(radius: CGFloat = 10) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.layoutIfNeeded()
            self.roundCorners(corners: [.topLeft, .bottomLeft, .bottomRight], radius: radius)
        }
    }
    
    var owningViewController: UIViewController? {
        var r: UIResponder? = self
        while let next = r?.next {
            if let vc = next as? UIViewController { return vc }
            r = next
        }
        return nil
    }
}
