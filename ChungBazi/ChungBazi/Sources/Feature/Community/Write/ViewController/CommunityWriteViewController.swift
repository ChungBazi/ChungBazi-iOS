//
//  CommunityWriteViewController.swift
//  ChungBazi
//
//  Created by 신호연 on 2/2/25.
//

import UIKit
import SafeAreaBrush
import PhotosUI

final class CommunityWriteViewController: UIViewController, CommunityWriteViewDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate, PHPickerViewControllerDelegate {
    
    private let scrollView = UIScrollView()
    private let communityWriteView = CommunityWriteView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        communityWriteView.delegate = self
        enableKeyboardHandling(for: scrollView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    private func setupUI() {
        view.backgroundColor = .gray50
        fillSafeArea(position: .top, color: .white)
        fillSafeArea(position: .bottom, color: .white)
        
        addCustomNavigationBar(titleText: "글쓰기", showBackButton: true, showCartButton: false, showAlarmButton: true, backgroundColor: .white)
        
        view.addSubview(scrollView)
        scrollView.addSubview(communityWriteView)
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(Constants.navigationHeight)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.leading.trailing.equalToSuperview()
        }
        communityWriteView.snp.makeConstraints {
            $0.edges.width.equalToSuperview()
        }
    }
    
    func didTapCameraButton() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 10 - communityWriteView.selectedImages.count
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        let group = DispatchGroup()
        var newImages: [UIImage] = []
        
        for result in results {
            group.enter()
            result.itemProvider.loadObject(ofClass: UIImage.self) { (object, error) in
                if let image = object as? UIImage {
                    newImages.append(image)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.communityWriteView.selectedImages.append(contentsOf: newImages)
        }
    }
}
