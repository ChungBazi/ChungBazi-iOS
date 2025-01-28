//
//  CustomGrabbar.swift
//  ChungBazi
//
//  Created by 신호연 on 1/28/25.
//

import UIKit

extension UIViewController {
    func addCustomGrabber(to view: UIView, topOffset: CGFloat = 9) {
        let grabbarView = UIView()
        grabbarView.backgroundColor = .gray300
        grabbarView.layer.cornerRadius = 2.5
        grabbarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(grabbarView)
        grabbarView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(topOffset)
            $0.width.equalTo(86)
            $0.height.equalTo(5)
            $0.centerX.equalToSuperview()
        }
    }
}
