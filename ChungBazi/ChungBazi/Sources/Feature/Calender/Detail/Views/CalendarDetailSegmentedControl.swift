//
//  CalendarDetailSegmentedControl.swift
//  ChungBazi
//
//  Created by 신호연 on 1/21/25.
//

import UIKit
import SnapKit
import Then

final class CalendarDetailSegmentedControl: UISegmentedControl {
    
    private lazy var underlineView: UIView = {
        let width = self.bounds.size.width / CGFloat(self.numberOfSegments)
        let height: CGFloat = 2
        let xPosition = CGFloat(self.selectedSegmentIndex * Int(width))
        let yPosition = self.titleTextHeight() + 13
        let frame = CGRect(x: xPosition, y: yPosition, width: width, height: height)
        let view = UIView(frame: frame)
        view.backgroundColor = .gray100
        self.addSubview(view)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clearSegmentBackgroundAndDivider()
        self.configureFont()
    }
    
    override init(items: [Any]?) {
        super.init(items: items)
        self.clearSegmentBackgroundAndDivider()
        self.configureFont()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let segmentWidth = bounds.width / CGFloat(numberOfSegments)
        let underlineXPosition = segmentWidth * CGFloat(selectedSegmentIndex)
        let underlineYPosition = titleTextHeight() + 13
        
        UIView.animate(withDuration: 0.3, animations: {
            self.underlineView.frame = CGRect(
                x: underlineXPosition,
                y: underlineYPosition,
                width: segmentWidth,
                height: 2
            )
        })
    }
    
    private func clearSegmentBackgroundAndDivider() {
        let clearImage = UIImage()
        setBackgroundImage(clearImage, for: .normal, barMetrics: .default)
        setBackgroundImage(clearImage, for: .selected, barMetrics: .default)
        setDividerImage(clearImage, forLeftSegmentState: .selected, rightSegmentState: .normal, barMetrics: .default)
    }
    
    private func configureFont() {
        let font = UIFont.ptdMediumFont(ofSize: 16)
        let attrebutes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.gray300
        ]
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.black
        ]
        self.setTitleTextAttributes(attrebutes, for: .normal)
        self.setTitleTextAttributes(selectedAttributes, for: .selected)
    }
    
    /// 텍스트 높이를 계산하는 함수
    private func titleTextHeight() -> CGFloat {
        guard let font = self.titleTextAttributes(for: .normal)?[.font] as? UIFont else {
            return 0
        }
        return font.lineHeight
    }
}
