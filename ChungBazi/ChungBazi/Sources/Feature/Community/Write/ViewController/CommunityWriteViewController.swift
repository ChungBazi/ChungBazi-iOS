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

    private let scrollView = UIScrollView()
    private let communityWriteView = CommunityWriteView()
    private let communityService = CommunityService()

    private let buttonContainerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 0, height: 3)
        $0.layer.shadowOpacity = 0.18
        $0.layer.shadowRadius = 10
    }

    private let postButton = CustomActiveButton(title: "완료", isEnabled: false).then {
        $0.addTarget(self, action: #selector(didTapPostButton), for: .touchUpInside)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        communityWriteView.viewDelegate = self
        enableKeyboardHandling(for: scrollView, inputView: buttonContainerView)
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
        
        addCustomNavigationBar(titleText: "글쓰기", showBackButton: true, showCartButton: false, showAlarmButton: false, backgroundColor: .white)

        view.addSubview(scrollView)
        scrollView.addSubview(communityWriteView)
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(Constants.navigationHeight)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.leading.trailing.width.equalToSuperview()
        }

        communityWriteView.snp.makeConstraints {
            $0.edges.width.equalToSuperview()
            $0.height.greaterThanOrEqualTo(view.safeAreaLayoutGuide.snp.height)
        }

        view.addSubview(buttonContainerView)
        buttonContainerView.addSubview(postButton)

        buttonContainerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(58)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }

        postButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.trailing.equalToSuperview().inset(Constants.gutter)
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

        DispatchQueue.main.async {
            self.postButton.isEnabled = isTitleFilled && isCategorySelected && isContentFilled
        }
    }

    @objc private func didTapPostButton() {
        guard let title = communityWriteView.titleTextField.text,
              let category = communityWriteView.selectedCategory,
              let content = communityWriteView.contentTextView.text else { return }

        let requestBody = CommunityPostRequestDto(title: title, content: content, category: category)
        let images = communityWriteView.selectedImages

        communityService.postCommunityPost(body: requestBody, imageList: images) { result in
            switch result {
            case .success(let response):
                print("✅ 게시글 업로드 성공: \(response)")
                self.dismiss(animated: true)

            case .failure(let error):
                print("🚨 게시글 업로드 실패: \(error.localizedDescription)")
            }
        }
    }
}
