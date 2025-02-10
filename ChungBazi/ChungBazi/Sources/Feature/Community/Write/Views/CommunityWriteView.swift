import UIKit
import SnapKit
import Then

protocol CommunityWriteViewDelegate: AnyObject {
    func didTapCameraButton()
    func didSelectDropdownItem(_ item: String)
}

final class CommunityWriteView: UIView {
    
    weak var viewDelegate: CommunityWriteViewDelegate?
    
    private let scrollView = UIScrollView()
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
    }.then {
        $0.isUserInteractionEnabled = true
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
    
    private let collectionViewHandler = CommunityWriteCollectionViewHandler()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupHandlers()
        dropdownView.delegate = self

        DispatchQueue.main.async {
            self.bringSubviewToFront(self.dropdownView)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubviews(scrollView, dropdownView)
        scrollView.addSubview(contentView)
        contentView.addSubviews(cameraButton, titleTextField, separateLine, contentTextView, photoCollectionView, communityRuleView)

        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        scrollView.delaysContentTouches = false

        contentView.snp.makeConstraints {
            $0.edges.width.equalToSuperview()
            $0.bottom.equalTo(photoCollectionView.snp.bottom).offset(20)
        }

        dropdownView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(14)
            $0.leading.equalToSuperview().inset(Constants.gutter)
            $0.width.equalTo(91)
            $0.height.equalTo(36*Constants.communityCategoryItems.count + 36 + 8)
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
    
    @objc private func handleCameraButtonTap() {
        viewDelegate?.didTapCameraButton()
    }
    
    func removeImage(at index: Int) {
        guard index < selectedImages.count else { return }
        selectedImages.remove(at: index)
        photoCollectionView.reloadData()
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

extension CommunityWriteView: CustomDropdownDelegate {
    func dropdown(_ dropdown: CustomDropdown, didSelectItem item: String) {
        viewDelegate?.didSelectDropdownItem(item)

        DispatchQueue.main.async {
            dropdown.dropdownView.titleLabel.text = item
            dropdown.dropdownView.titleLabel.textColor = .black
            self.layoutIfNeeded()
        }
    }
}
