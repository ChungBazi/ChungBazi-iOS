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

final class CommunityWriteView: UIScrollView, CustomDropdownDelegate {
    
    weak var viewDelegate: CommunityWriteViewDelegate?
    
    private lazy var dropdownView = CustomDropdown(
        height: 36,
        fontSize: 14,
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
                .foregroundColor: UIColor.gray300
            ]
        )
        $0.defaultTextAttributes = [
            .font: UIFont.ptdSemiBoldFont(ofSize: 20),
            .foregroundColor: UIColor.black
        ]
        $0.backgroundColor = .clear
    }
    
    private let separateLine = UIView().then {
        $0.backgroundColor = .gray300
    }
    
    private let contentTextView = UITextView()

    private lazy var photoCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 9
        layout.itemSize = CGSize(width: 80, height: 80)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    var selectedImages: [UIImage] = [] {
        didSet {
            selectedImages = Array(selectedImages.prefix(10))
            DispatchQueue.main.async { self.photoCollectionView.reloadData() }
        }
    }
    
    private let communityRuleView = UIView()
    private let communityRuleLabel = B14_M(text: "커뮤니티 이용규칙 보러가기", textColor: .gray500)
    private let communityRuleIcon = UIImageView().then {
        $0.image = .arrowRight
        $0.image?.withRenderingMode(.alwaysTemplate)
        $0.tintColor = .gray500
    }
    
    private let textViewHandler = CommunityWriteTextViewHandler()
    private let collectionViewHandler = CommunityWriteCollectionViewHandler()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupHandlers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentTextView.delegate = textViewHandler
        photoCollectionView.delegate = collectionViewHandler
        photoCollectionView.dataSource = collectionViewHandler
        
        dropdownView.delegate = self // 드롭다운 선택 반영을 위해 delegate 설정
        
        addSubviews(dropdownView, cameraButton, titleTextField, separateLine, contentTextView, photoCollectionView, communityRuleView)
        
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
            $0.bottom.equalToSuperview().inset(22)
            $0.trailing.equalToSuperview().inset(Constants.gutter)
            $0.height.equalTo(20)
        }
        
        communityRuleLabel.snp.makeConstraints {
            $0.trailing.equalTo(communityRuleIcon.snp.leading).offset(-9.5)
            $0.centerY.equalToSuperview()
        }
        
        communityRuleIcon.snp.makeConstraints {
            $0.trailing.centerY.equalToSuperview()
        }
    }
    
    private func setupHandlers() {
        textViewHandler.contentTextView = contentTextView
        collectionViewHandler.photoCollectionView = photoCollectionView
        collectionViewHandler.selectedImages = { [weak self] in
            self?.selectedImages ?? []
        }
        collectionViewHandler.removeImage = { [weak self] index in
            self?.removeImage(at: index)
        }
    }
    
    @objc private func handleCameraButtonTap() {
        viewDelegate?.didTapCameraButton()
    }
    
    func removeImage(at index: Int) {
        guard index < selectedImages.count else { return }
        selectedImages.remove(at: index)
        photoCollectionView.reloadData()
    }
    
    // MARK: - CustomDropdownDelegate
    func dropdown(_ dropdown: CustomDropdown, didSelectItem item: String) {
        print("선택된 카테고리: \(item)")
        dropdownView.setItems(Constants.communityCategoryItems.filter { $0 != CommunityCategory.all.displayName })
    }
}

final class CommunityWriteTextViewHandler: NSObject, UITextViewDelegate {
    weak var contentTextView: UITextView?
    
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

final class CommunityWriteCollectionViewHandler: NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
    weak var photoCollectionView: UICollectionView?
    var selectedImages: (() -> [UIImage])?
    var removeImage: ((Int) -> Void)?
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedImages?().count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CommunityWritePhotoCell", for: indexPath) as! CommunityWritePhotoCell
        let image = selectedImages?()[indexPath.item] ?? UIImage()
        
        cell.configure(with: image, index: indexPath.item, onDelete: { [weak self] index in
            self?.removeImage?(index)
        })
        
        return cell
    }
}
