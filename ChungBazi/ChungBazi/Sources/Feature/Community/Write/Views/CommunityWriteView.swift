//
//  CommunityWriteView.swift
//  ChungBazi
//
//  Created by 신호연 on 2/2/25.
//

import UIKit
import SnapKit
import Then

protocol CommunityWriteViewDelegate: AnyObject {
    func didTapCameraButton()
}

final class CommunityWriteView: UIView, UITextViewDelegate, UICollectionViewDelegate {
    
    weak var delegate: CommunityWriteViewDelegate?
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let dropdownView = CompactDropdown(
        title: "관심",
        hasBorder: false,
        items: Constants.communityCategoryItems.filter { $0 != CommunityCategory.all.displayName }
    )
    private let cameraButton = UIButton.createWithImage(
        image: .cameraIcon,
        tintColor: .gray500,
        target: self,
        action: #selector(handleCameraButtonTap)
    )
    
    private let titleTextField = UITextField().then {
        $0.attributedPlaceholder = NSAttributedString(
            string: "제목을 입력해주세요.",
            attributes: [
                .font: UIFont.ptdSemiBoldFont(ofSize: 20),
                NSAttributedString.Key.foregroundColor: UIColor.gray300
            ]
        )
        $0.defaultTextAttributes = [
            .font: UIFont.ptdSemiBoldFont(ofSize: 20),
            .foregroundColor: UIColor.black
        ]
    }
    
    private let separateLine = UIView().then {
        $0.backgroundColor = .gray300
    }
    
    private let contentTextView = UITextView().then {
        $0.font = UIFont.ptdMediumFont(ofSize: 14)
        $0.textColor = UIColor.gray300
        $0.text = "자유롭게 얘기해보세요."
        $0.isScrollEnabled = false
        $0.backgroundColor = .clear
        $0.textContainerInset = .zero
        $0.textContainer.lineFragmentPadding = 0
    }
    
    private let photoCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 9
        layout.itemSize = CGSize(width: 80, height: 80)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        $0.collectionViewLayout = layout
        $0.backgroundColor = .clear
        $0.showsHorizontalScrollIndicator = false
        $0.register(CommunityWritePhotoCell.self, forCellWithReuseIdentifier: "CommunityWritePhotoCell")
    }
    
    var selectedImages: [UIImage] = [] {
        didSet {
            if selectedImages.count > 10 {
                selectedImages = Array(selectedImages.prefix(10))
            }
            DispatchQueue.main.async {
                self.photoCollectionView.reloadData()
            }
        }
    }
    
    private let communityRuleView = UIView()
    private let communityRuleLabel = B14_M(text: "커뮤니티 이용규칙 보러가기", textColor: .gray500)
    private let communityRuleIcon = UIImageView().then {
        $0.image = .arrowRight
        $0.image?.withRenderingMode(.alwaysTemplate)
        $0.tintColor = .gray500
    }
    
    private let buttonContainerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 0, height: 3)
        $0.layer.shadowOpacity = 0.18
        $0.layer.shadowRadius = 10
    }
    
    private let postButton = CustomActiveButton(title: "완료", isEnabled: false)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupDelegates()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubviews(scrollView, contentView, communityRuleView, buttonContainerView)
        contentView.addSubviews(dropdownView, cameraButton, titleTextField, separateLine, contentTextView, photoCollectionView)
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.bottom.equalTo(communityRuleView.snp.top).offset(-22)
        }
        contentView.snp.makeConstraints {
            $0.top.width.equalToSuperview()
            $0.bottom.equalTo(photoCollectionView).offset(20)
        }
        
        dropdownView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(14)
            $0.leading.equalToSuperview().inset(Constants.gutter)
            $0.width.equalTo(91)
            $0.height.equalTo(36)
        }
        
        cameraButton.snp.makeConstraints {
            $0.centerY.equalTo(dropdownView)
            $0.trailing.equalToSuperview().inset(28)
        }
        
        titleTextField.snp.makeConstraints {
            $0.top.equalTo(dropdownView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        
        separateLine.snp.makeConstraints {
            $0.top.equalTo(titleTextField.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(Constants.gutter)
            $0.height.equalTo(1)
        }
        
        contentTextView.snp.makeConstraints {
            $0.top.equalTo(separateLine.snp.bottom).offset(18)
            $0.leading.trailing.equalTo(titleTextField)
            $0.height.greaterThanOrEqualTo(80)
        }
        
        photoCollectionView.snp.makeConstraints {
            $0.top.equalTo(contentTextView.snp.bottom).offset(46)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(98)
        }
        
        communityRuleView.addSubviews(communityRuleLabel, communityRuleIcon)
        communityRuleView.snp.makeConstraints {
            $0.bottom.equalTo(buttonContainerView.snp.top).offset(-22)
            $0.trailing.equalToSuperview().inset(Constants.gutter)
        }
        
        communityRuleLabel.snp.makeConstraints {
            $0.trailing.equalTo(communityRuleIcon.snp.leading).offset(-9.5)
            $0.centerY.equalToSuperview()
        }
        
        communityRuleIcon.snp.makeConstraints {
            $0.trailing.centerY.equalToSuperview()
        }
        
        buttonContainerView.addSubviews(postButton)
        buttonContainerView.snp.makeConstraints {
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(58)
        }
        
        postButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.trailing.equalToSuperview().inset(Constants.gutter)
        }
    }
    
    private func setupDelegates() {
        contentTextView.delegate = self
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
    }
    
    @objc private func handleCameraButtonTap() {
        delegate?.didTapCameraButton()
    }
    
    func removeImage(at index: Int) {
        guard index < selectedImages.count else { return }
        selectedImages.remove(at: index)
        photoCollectionView.reloadData()
    }
    
    // MARK: - UITextViewDelegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "자유롭게 얘기해보세요." {
            textView.text = ""
            textView.textColor = .gray800
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = "자유롭게 얘기해보세요."
            textView.textColor = .gray300
        }
    }
}

extension CommunityWriteView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CommunityWritePhotoCell", for: indexPath) as! CommunityWritePhotoCell
        let image = selectedImages[indexPath.item]
        
        cell.configure(with: image, index: indexPath.item, onDelete: { [weak self] index in
            self?.removeImage(at: index)
        })
        
        return cell
    }
}
