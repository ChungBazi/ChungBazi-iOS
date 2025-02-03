//
//  CommunityView.swift
//  ChungBazi
//
//  Created by 신호연 on 2/2/25.
//

import UIKit
import SnapKit
import Then

protocol CommunityViewDelegate: AnyObject {
    func didTapWriteButton()
    func didSelectCategory(index: Int)
}

final class CommunityView: UIView {
    
    weak var delegate: CommunityViewDelegate?
    
    private var posts: [CommunityPost] = []
    
    private lazy var segmentedControl = UISegmentedControl(items: Constants.communityCategoryItems).then {
        $0.selectedSegmentIndex = 0
        $0.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        
        let image = UIImage()
        $0.setBackgroundImage(image, for: .normal, barMetrics: .default)
        $0.setBackgroundImage(image, for: .selected, barMetrics: .default)
        $0.setBackgroundImage(image, for: .highlighted, barMetrics: .default)
        $0.setDividerImage(image, forLeftSegmentState: .selected, rightSegmentState: .normal, barMetrics: .default)
        
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.ptdMediumFont(ofSize: 14),
            .foregroundColor: UIColor.gray300
        ]
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.ptdMediumFont(ofSize: 14),
            .foregroundColor: UIColor.blue700
        ]
        $0.setTitleTextAttributes(normalAttributes, for: .normal)
        $0.setTitleTextAttributes(selectedAttributes, for: .selected)
    }
    private let underlineView = UIView().then {
        $0.backgroundColor = .blue700
    }
    private let underlineBaseView = UIView().then {
        $0.backgroundColor = .gray300
    }
    private let writeButton = UIButton.createWithImage(
        image: UIImage(named: "writeIcon")?.withRenderingMode(.alwaysOriginal),
        target: self,
        action: #selector(handleWriteButtonTap)
    )
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let totalPostCountLabel = UILabel().then {
        $0.text = "총 0개의 글"
        $0.font = .ptdMediumFont(ofSize: 14)
        $0.textColor = .gray800
    }
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        $0.dataSource = self
        $0.delegate = self
        $0.register(CommunityPostListCell.self, forCellWithReuseIdentifier: "CommunityPostListCell")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubviews(segmentedControl, underlineBaseView, underlineView, writeButton)
        segmentedControl.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }
        underlineBaseView.snp.makeConstraints {
            $0.top.height.equalTo(underlineView)
            $0.leading.trailing.equalToSuperview()
        }
        underlineView.snp.makeConstraints {
            $0.top.equalTo(segmentedControl.snp.bottom)
            $0.height.equalTo(2)
            $0.width.equalTo(segmentedControl).dividedBy(Constants.communityCategoryItems.count)
            $0.leading.equalTo(segmentedControl)
        }
        writeButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(18)
            $0.trailing.equalToSuperview().inset(Constants.gutter)
        }
        
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.snp.makeConstraints {
            $0.top.equalTo(underlineView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        contentView.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.top.bottom.equalToSuperview()
        }
        
        contentView.addSubviews(totalPostCountLabel)
        totalPostCountLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(Constants.gutter)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateUnderlinePosition(animated: false)
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        delegate?.didSelectCategory(index: sender.selectedSegmentIndex)
        updateUnderlinePosition(animated: true)
    }
    
    private func updateUnderlinePosition(animated: Bool) {
        let segmentWidth = segmentedControl.bounds.width / CGFloat(Constants.communityCategoryItems.count)
        let targetX = segmentWidth * CGFloat(segmentedControl.selectedSegmentIndex)
        
        if animated {
            UIView.animate(withDuration: 0.2) {
                self.underlineView.snp.updateConstraints {
                    $0.leading.equalTo(self.segmentedControl).offset(targetX)
                }
                self.layoutIfNeeded()
            }
        } else {
            underlineView.snp.updateConstraints {
                $0.leading.equalTo(segmentedControl).offset(targetX)
            }
        }
    }
    
    func updatePosts(_ posts: [CommunityPost], totalPostCount: Int) {
        DispatchQueue.main.async {
            self.posts = posts
            self.totalPostCountLabel.text = "총 \(totalPostCount)개의 글"
            self.collectionView.reloadData()
        }
    }
    
    @objc private func handleWriteButtonTap() {
        delegate?.didTapWriteButton()
    }
}

extension CommunityView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CommunityPostListCell", for: indexPath) as! CommunityPostListCell
        let post = posts[indexPath.row]
        cell.configure(with: post)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width - 16, height: 100)
    }
}
