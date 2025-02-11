//
//  KeyboardHandler.swift
//  ChungBazi
//
//  Created by 신호연 on 1/25/25.
//

/**
 `KeyboardHandler`
 키보드로 인해 가려지는 UI 문제를 해결하고, 키보드 동작을 쉽게 관리할 수 있는 유틸리티 클래스입니다.
 
 ### 기능
 1. 키보드가 나타날 때 `UIScrollView`의 `contentInset`을 조정하여 키보드로 인해 UI가 가려지지 않도록 처리합니다.
 2. 화면의 빈 공간을 터치하거나 스크롤하면 키보드를 숨길 수 있도록 `UITapGestureRecognizer`를 설정합니다.
 
 ### 사용법
 1. 뷰 컨트롤러에서 UIScrollView를 포함한 레이아웃을 구성합니다.
 2. `enableKeyboardHandling(for: scrollView)` 메서드를 호출하여 키보드 처리를 활성화 합니다.
 */

import UIKit
import SnapKit

final class KeyboardHandler: NSObject, UIScrollViewDelegate {
    private weak var scrollView: UIScrollView?
    private weak var viewController: UIViewController?
    private weak var inputView: UIView?

    private var inputViewBottomConstraint: Constraint?

    init(scrollView: UIScrollView, inputView: UIView? = nil, viewController: UIViewController) {
        self.scrollView = scrollView
        self.viewController = viewController
        self.inputView = inputView
        super.init()
        setupKeyboardObservers()
        scrollView.delegate = self
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardHeight = keyboardFrame.height

        UIView.animate(withDuration: 0.3, animations: {
            self.scrollView?.contentInset.bottom = keyboardHeight
            self.scrollView?.scrollIndicatorInsets.bottom = keyboardHeight

            if let inputView = self.inputView {
                if self.inputViewBottomConstraint == nil {
                    inputView.snp.makeConstraints {
                        self.inputViewBottomConstraint = $0.bottom.equalTo(inputView.superview!.safeAreaLayoutGuide.snp.bottom).constraint
                    }
                }
                self.inputViewBottomConstraint?.update(offset: -keyboardHeight)
            }
            self.viewController?.view.layoutIfNeeded()
        })
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3, animations: {
            self.scrollView?.contentInset.bottom = 0
            self.scrollView?.scrollIndicatorInsets.bottom = 0

            self.inputViewBottomConstraint?.update(offset: 0)
            self.viewController?.view.layoutIfNeeded()
        })
    }

    func setTapGestureToDismissKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        viewController?.view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        viewController?.view.endEditing(true)
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        dismissKeyboard()
    }
}

extension UIViewController {
    func enableKeyboardHandling(for scrollView: UIScrollView, inputView: UIView? = nil) {
        let handler = KeyboardHandler(scrollView: scrollView, inputView: inputView, viewController: self)
        handler.setTapGestureToDismissKeyboard()
        objc_setAssociatedObject(self, &keyboardHandlerKey, handler, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

private var keyboardHandlerKey: UInt8 = 0
