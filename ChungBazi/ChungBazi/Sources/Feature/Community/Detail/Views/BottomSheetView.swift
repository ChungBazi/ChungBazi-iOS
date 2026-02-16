//
//  BottomSheetView.swift
//  ChungBazi
//
//  Created by 신호연 on 9/13/25.
//

import UIKit
import SnapKit
import Then
import SafeAreaBrush

protocol BottomSheetViewDelegate: AnyObject {
    func bottomSheet(_ sheet: BottomSheetView, didSelectItemAt index: Int, title: String)
    func bottomSheetDidDismiss(_ sheet: BottomSheetView)
}

final class BottomSheetView: UIView {

    // MARK: Configuration
    struct Item {
        let title: String
        let textColor: UIColor?
        let accessibilityIdentifier: String?
        public init(title: String,
                    textColor: UIColor? = nil,
                    accessibilityIdentifier: String? = nil) {
            self.title = title
            self.textColor = textColor
            self.accessibilityIdentifier = accessibilityIdentifier
        }
    }

    weak var delegate: BottomSheetViewDelegate?
    var onSelect: ((Int, String) -> Void)?

    var cornerRadius: CGFloat = 30 { didSet { containerView.layer.cornerRadius = cornerRadius } }

    private let dimView = UIControl().then {
        $0.backgroundColor = UIColor(hex: "#00000059")
        $0.alpha = 0.0
        $0.isHidden = true
        $0.accessibilityIdentifier = "bottomSheet.dimView"
    }

    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 30
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.clipsToBounds = true
    }

    private let topBar = UIView().then {
        $0.backgroundColor = .white
    }

    private let grabber = UIView().then {
        $0.backgroundColor = .gray300
        $0.layer.cornerRadius = 2.5         // 피그마 R=5
        if #available(iOS 13.0, *) {
            $0.layer.cornerCurve = .continuous   // 모서리 곡선 부드럽게
        }
        $0.clipsToBounds = true
    }

    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 0
        $0.distribution = .fill
        $0.alignment = .fill
    }

    private lazy var panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))

    private var containerBottomConstraint: Constraint?
    private var didFillBottomSafeArea = false

    private var contentHeight: CGFloat { containerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height }

    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: Setup
    private func setup() {
        addSubview(dimView)
        addSubview(containerView)

        dimView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        containerView.addSubview(topBar)
        containerView.addSubview(stackView)
        topBar.addSubview(grabber)

        containerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            containerBottomConstraint = make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
                .offset(UIScreen.main.bounds.height).constraint
        }

        topBar.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(28)
        }

        grabber.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(86)
            make.height.equalTo(5)
        }

        stackView.snp.makeConstraints { make in
            make.top.equalTo(grabber.snp.bottom).offset(10)
            make.left.right.bottom.equalToSuperview()
        }

        containerView.bringSubviewToFront(topBar)
        dimView.addTarget(self, action: #selector(dismissTapped), for: .touchUpInside)
        containerView.addGestureRecognizer(panGesture)
    }

    // MARK: Public Methods
    func setItems(_ items: [Item]) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (idx, item) in items.enumerated() {
            let row = BottomSheetRow(title: item.title)
            if let color = item.textColor { row.titleLabel.textColor = color }
            row.accessibilityIdentifier = item.accessibilityIdentifier ?? "bottomSheet.row_\(idx)"
            row.heightAnchor.constraint(equalToConstant: 70).isActive = true
            row.onTap = { [weak self] in
                guard let self else { return }
                self.onSelect?(idx, item.title)
                self.delegate?.bottomSheet(self, didSelectItemAt: idx, title: item.title)
            }
            stackView.addArrangedSubview(row)
        }
        layoutIfNeeded()
    }
    
    func present(in parent: UIView, animated: Bool = true) {
        if superview == nil { parent.addSubview(self) }
        self.snp.makeConstraints { make in
            make.edges.equalTo(parent)
        }
        parent.layoutIfNeeded()

        owningViewController?.fillSafeArea(position: .bottom, color: .white)

        dimView.isHidden = false
        containerBottomConstraint?.update(offset: 0)

        let animations = {
            self.dimView.alpha = 1.0
            parent.layoutIfNeeded()
        }
        if animated {
            UIView.animate(
                withDuration: 0.32,
                delay: 0,
                usingSpringWithDamping: 0.95,
                initialSpringVelocity: 0.8,
                options: [.curveEaseOut]
            ) { animations() }
        } else {
            animations()
        }
    }

    func dismiss(animated: Bool = true) {
        guard let parent = superview else { return }
        containerBottomConstraint?.update(offset: UIScreen.main.bounds.height)

        let animations = {
            self.dimView.alpha = 0.0
            parent.layoutIfNeeded()
        }
        let completion: (Bool) -> Void = { _ in
            self.dimView.isHidden = true

            self.owningViewController?.fillSafeArea(position: .bottom, color: .clear)

            self.removeFromSuperview()
            self.delegate?.bottomSheetDidDismiss(self)
        }

        if animated {
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseIn]) {
                animations()
            } completion: { finished in
                completion(finished)
            }
        } else {
            animations()
            completion(true)
        }
    }

    // MARK: Actions
    @objc private func dismissTapped() { dismiss() }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let parent = superview else { return }
        let translation = gesture.translation(in: parent)
        switch gesture.state {
        case .changed:
            let offset = max(0, translation.y)
            containerBottomConstraint?.update(offset: offset)
            let alpha = max(0.0, 1.0 - (offset / 200.0))
            dimView.alpha = alpha
        case .ended, .cancelled:
            let velocity = gesture.velocity(in: parent).y
            let shouldDismiss = (translation.y > 120) || (velocity > 800)
            containerBottomConstraint?.update(offset: shouldDismiss ? UIScreen.main.bounds.height : 0)
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut]) {
                parent.layoutIfNeeded()
                self.dimView.alpha = shouldDismiss ? 0.0 : 1.0
            } completion: { _ in
                if shouldDismiss { self.dismiss(animated: false) }
            }
        default: break
        }
    }
}

// MARK: - BottomSheetRow (70pt height, centered B16_M label)
private final class BottomSheetRow: UIControl {
    let titleLabel = B16_M(text: "").then {
        $0.textAlignment = .center
        $0.textColor = .gray800
        $0.numberOfLines = 1
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
    }

    var onTap: (() -> Void)?

    init(title: String) {
        super.init(frame: .zero)
        backgroundColor = .white
        addSubview(titleLabel)
        titleLabel.text = title

        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.greaterThanOrEqualToSuperview().offset(16)
            make.right.lessThanOrEqualToSuperview().inset(16)
        }

        addTarget(self, action: #selector(tap), for: .touchUpInside)
        accessibilityTraits.insert(.button)
    }

    @objc private func tap() { onTap?() }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - Convenience Presenting
extension BottomSheetView {
    static func present(in parent: UIView,
                        items: [Item],
                        onSelect: ((Int, String) -> Void)? = nil) -> BottomSheetView {
        let sheet = BottomSheetView()
        sheet.onSelect = onSelect
        sheet.setItems(items)
        sheet.present(in: parent)
        return sheet
    }
}

// MARK: - Example Usage (inside a UIViewController)
/*
final class ExampleVC: UIViewController, BottomSheetViewDelegate {
    func showSheet() {
        let titles = ["첫 번째 항목", "두 번째 항목", "세 번째 항목"]
        BottomSheetView.present(in: view, titles: titles, delegate: self)
    }

    func bottomSheet(_ sheet: BottomSheetView, didSelectItemAt index: Int, title: String) {
        print("Selected: \(index) - \(title)")
        sheet.dismiss()
    }

    func bottomSheetDidDismiss(_ sheet: BottomSheetView) { }
}
*/
