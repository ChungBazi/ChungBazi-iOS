//
//  CommunityWriteViewController.swift
//  ChungBazi
//
//  Created by 신호연 on 2/2/25.
//

import UIKit
import SafeAreaBrush
import PhotosUI
import Moya

final class CommunityWriteViewController: UIViewController, CommunityWriteViewDelegate, PHPickerViewControllerDelegate {
    
    private let communityWriteView = CommunityWriteView()
    private let communityService = CommunityService()
    private var isPosting = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        communityWriteView.viewDelegate = self
        enableKeyboardHandling(for: communityWriteView.scrollView)
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
        
        addCustomNavigationBar(titleText: "글쓰기", showBackButton: true, showCartButton: false, showAlarmButton: false, backgroundColor: .white)
        
        view.addSubview(communityWriteView)
        
        communityWriteView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(Constants.navigationHeight)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.leading.trailing.width.equalToSuperview()
        }
        
        
        fillSafeArea(position: .top, color: .white)
        fillSafeArea(position: .bottom, color: .white)
    }
    
    func didTapCameraButton() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 10 - communityWriteView.selectedImages.count
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func didSelectDropdownItem(_ item: String) {
        checkIfPostCanBeEnabled()
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
            self.checkIfPostCanBeEnabled()
        }
    }
    
    internal func checkIfPostCanBeEnabled() {
        let isTitleFilled = !(communityWriteView.titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        let isCategorySelected = communityWriteView.selectedCategory != nil
        let isContentFilled = !(communityWriteView.contentTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        
        let isEnabled = isTitleFilled && isCategorySelected && isContentFilled
        
        communityWriteView.updatePostButtonState(isEnabled: isEnabled)
        
        DispatchQueue.main.async {
            self.communityWriteView.postButton.backgroundColor = isEnabled ? .blue700 : .gray200
        }
    }
    
    func didTapPostButton() {
        guard !isPosting else { return }
        isPosting = true
        communityWriteView.postButton.isEnabled = false
        
        guard let title = communityWriteView.titleTextField.text,
              let categoryString = communityWriteView.selectedCategory,
              let communityCategory = CommunityCategory.fromString(categoryString),
              let content = communityWriteView.contentTextView.text else {
            isPosting = false
            communityWriteView.postButton.isEnabled = true
            return
        }
        
        let requestBody = CommunityPostRequestDto(title: title, content: content, category: communityCategory.rawValue)
        let images = communityWriteView.selectedImages
        
        communityService.postCommunityPost(body: requestBody, imageList: images) { result in
            DispatchQueue.main.async {
                self.isPosting = false
                self.communityWriteView.postButton.isEnabled = true
                
                switch result {
                case .success:
                    let detailVC = CommunityViewController()
                    self.navigationController?.pushViewController(detailVC, animated: true)
                case .failure(let error):
                    print("🚨 게시글 업로드 실패: \(error.localizedDescription)")
                }
            }
        }
    }
}
