//
//  CommunityPhotoViewController.swift
//  ChungBazi
//
//  Created by 신호연 on 2/11/25.
//

import UIKit

final class CommunityPhotoViewController: UIViewController {
    
    private let photoView = CommunityPhotoView()
    
    private var imageUrls: [String]
    private var currentIndex: Int
    
    init(imageUrls: [String], initialIndex: Int) {
        self.imageUrls = imageUrls
        self.currentIndex = initialIndex
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupUI()
        photoView.configure(images: imageUrls, initialIndex: currentIndex)
    }
    
    private func setupUI() {
        view.addSubview(photoView)
        photoView.delegate = self
        
        photoView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}

// MARK: - CommunityPhotoViewDelegate
extension CommunityPhotoViewController: CommunityPhotoViewDelegate {
    func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}
