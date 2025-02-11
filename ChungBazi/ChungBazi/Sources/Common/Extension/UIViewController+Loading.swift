//
//  UIViewController+Loading.swift
//  ChungBazi
//
//  Created by 신호연 on 2/11/25.
//

import UIKit
import SnapKit

extension UIViewController {
    private struct LoadingIndicator {
        static var spinner: UIActivityIndicatorView?
    }
    
    func showLoading() {
        DispatchQueue.main.async {
            if LoadingIndicator.spinner == nil {
                let spinner = UIActivityIndicatorView(style: .large)
                spinner.color = .gray
                spinner.translatesAutoresizingMaskIntoConstraints = false
                
                self.view.addSubview(spinner)
                spinner.snp.makeConstraints {
                    $0.center.equalToSuperview()
                }
                
                spinner.startAnimating()
                LoadingIndicator.spinner = spinner
            }
        }
    }
    
    func hideLoading() {
        DispatchQueue.main.async {
            LoadingIndicator.spinner?.stopAnimating()
            LoadingIndicator.spinner?.removeFromSuperview()
            LoadingIndicator.spinner = nil
        }
    }
}
