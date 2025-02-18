import UIKit
import SnapKit
import Then

protocol CommunityWriteViewDelegate: AnyObject {
    func didTapCameraButton()
    func didSelectDropdownItem(_ item: String)
    func checkIfPostCanBeEnabled()
    func didTapPostButton()
}

final class CommunityWriteView: UIView, UITextViewDelegate {

    weak var viewDelegate: CommunityWriteViewDelegate?
    
    var selectedCategory: String?
    
    let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let dropdownView = CustomDropdown(
        height: 36,
        fontSize: 14,
        title: "관심",
        hasBorder: false,
        items: Constants.communityCategoryItems.filter { $0 != CommunityCategory.all.displayName }
    ).then {
        $0.isUserInteractionEnabled = true
    }
    
    private let cameraButton = UIButton.createWithImage(
        image: .cameraIcon,
        tintColor: .gray500,
        target: self,
        action: #selector(handleCameraButtonTap)
    )
    
    let titleTextField = UITextField().then {
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
        $0.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    private let separateLine = UIView().then {
        $0.backgroundColor = .gray300
    }
    
    let contentTextView = UITextView().then {
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
                self.viewDelegate?.checkIfPostCanBeEnabled()
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
    
    private let collectionViewHandler = CommunityWriteCollectionViewHandler()
    
    private let buttonContainerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 0, height: 3)
        $0.layer.shadowOpacity = 0.18
        $0.layer.shadowRadius = 10
    }

    let postButton = CustomActiveButton(title: "완료", isEnabled: false).then {
        $0.addTarget(self, action: #selector(didTapPostButton), for: .touchUpInside)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupHandlers()
        dropdownView.delegate = self
        contentTextView.delegate = self

        DispatchQueue.main.async {
            self.bringSubviewToFront(self.dropdownView)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubviews(scrollView, dropdownView, cameraButton, communityRuleView, buttonContainerView)
        scrollView.addSubview(contentView)
        contentView.addSubviews(titleTextField, separateLine, contentTextView, photoCollectionView, communityRuleView)

        scrollView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(14 + 36 + 14)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(communityRuleView.snp.top).offset(17)
        }
        
        scrollView.delaysContentTouches = false

        contentView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.edges.width.equalToSuperview()
            $0.bottom.equalTo(photoCollectionView.snp.bottom).offset(20)
            $0.height.greaterThanOrEqualTo(scrollView.snp.height)
        }

        dropdownView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(14)
            $0.leading.equalToSuperview().inset(Constants.gutter)
            $0.width.equalTo(91)
            $0.height.equalTo(36*Constants.communityCategoryItems.count + 36 + 8)
        }

        cameraButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20)
            $0.trailing.equalToSuperview().inset(28)
        }

        titleTextField.snp.makeConstraints {
            $0.top.equalToSuperview().offset(66)
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
            $0.bottom.equalTo(buttonContainerView.snp.top).offset(-17)
            $0.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(20)
        }
        communityRuleIcon.snp.makeConstraints {
            $0.centerY.trailing.equalToSuperview()
        }
        communityRuleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(communityRuleIcon.snp.leading).offset(-9.5)
        }
        
        buttonContainerView.addSubview(postButton)
        buttonContainerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(58)
            $0.bottom.equalToSuperview()
        }
        postButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.trailing.equalToSuperview().inset(Constants.gutter)
        }
        
        scrollView.delaysContentTouches = false
    }
    
    private func setupHandlers() {
        photoCollectionView.delegate = collectionViewHandler
        photoCollectionView.dataSource = collectionViewHandler
        collectionViewHandler.selectedImages = { [weak self] in
            self?.selectedImages ?? []
        }
        collectionViewHandler.removeImage = { [weak self] index in
            self?.removeImage(at: index)
        }
    }
    
    @objc private func didTapPostButton() {
        viewDelegate?.didTapPostButton()
    }
    
    func updatePostButtonState(isEnabled: Bool) {
        DispatchQueue.main.async {
            self.postButton.isEnabled = isEnabled
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
    
    @objc private func textFieldDidChange() {
        viewDelegate?.checkIfPostCanBeEnabled()
    }

    func textViewDidChange(_ textView: UITextView) {
        viewDelegate?.checkIfPostCanBeEnabled()
    }
}

final class CommunityWriteTextViewHandler: NSObject, UITextViewDelegate {
    weak var contentTextView: UITextView?
    private let placeholderText = "자유롭게 얘기해보세요."

    init(textView: UITextView) {
        self.contentTextView = textView
        super.init()
        setupPlaceholder()
    }

    private func setupPlaceholder() {
        guard let textView = contentTextView else { return }
        textView.text = placeholderText
        textView.textColor = .gray300
        textView.delegate = self
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholderText {
            textView.text = ""
            textView.textColor = .gray800
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = placeholderText
            textView.textColor = .gray300
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        if textView.textColor == .gray300 {
            textView.textColor = .gray800
            textView.text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        if textView.text.isEmpty {
            setPlaceholder(in: textView)
        }
    }

    private func setPlaceholder(in textView: UITextView) {
        textView.text = placeholderText
        textView.textColor = .gray300
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
        }, showDeleteButton: true)
        
        return cell
    }
}

extension CommunityWriteView: CustomDropdownDelegate {
    func dropdown(_ dropdown: CustomDropdown, didSelectItem item: String) {
        selectedCategory = item
        viewDelegate?.didSelectDropdownItem(item)
        viewDelegate?.checkIfPostCanBeEnabled()
    }
}
