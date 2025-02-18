//
//  CustomImageView.swift
//  ChungBazi
//
//  Created by 신호연 on 2/17/25.
//

import UIKit

final class CustomImageView: UIImageView {
    
    private var topMargin: CGFloat = 0
    private var leftMargin: CGFloat = 0
    private var rightMargin: CGFloat = 0
    private var bottomMargin: CGFloat = 0

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        self.contentMode = .scaleAspectFit
        self.clipsToBounds = true
    }
    
    func setImageMargins(top: CGFloat, left: CGFloat, right: CGFloat, bottom: CGFloat) {
        self.topMargin = top
        self.leftMargin = left
        self.rightMargin = right
        self.bottomMargin = bottom
        adjustContentsRect()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        adjustContentsRect()
    }
    
    private func adjustContentsRect() {
        let totalWidth = bounds.width
        let totalHeight = bounds.height
        
        guard totalWidth > 0, totalHeight > 0 else { return }
        
        let scaleFactor = UIScreen.main.scale

        let x = (leftMargin / scaleFactor) / totalWidth
        let y = (topMargin / scaleFactor) / totalHeight
        let width = ((totalWidth - (leftMargin + rightMargin) / scaleFactor) / totalWidth)
        let height = ((totalHeight - (topMargin + bottomMargin) / scaleFactor) / totalHeight)

        self.layer.contentsRect = CGRect(x: x, y: y, width: width, height: height)
    }
}
