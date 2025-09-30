//
//  CommunityDetailView.swift
//  ChungBazi
//
//  Created by 신호연 on 2/8/25.
//

import UIKit
import SnapKit
import Then

final class CommunityDetailView: UIView {
    
    var onRequestRefresh: (() -> Void)?
    var onStartReply: ((IndexPath) -> Void)?
    
    public let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let postView = CommunityDetailPostView()
    private let authorProfileView = CommunityDetailPostAuthoreProfileView()
    
    private let gray100View = UIView().then {
        $0.backgroundColor = .gray100
    }
    
    private let commentTableView = UITableView().then {
        $0.register(CommunityDetailCommentCell.self, forCellReuseIdentifier: CommunityDetailCommentCell.identifier)
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 136
        $0.isScrollEnabled = false
        $0.alwaysBounceVertical = false
        $0.showsVerticalScrollIndicator = false
        $0.backgroundColor = .clear
        $0.isUserInteractionEnabled = true
        $0.separatorStyle = .none
    }
    
    private var comments: [CommunityDetailCommentModel] = []
    
    var onTapPostLike: (() -> Void)?
    var onTapCommentLike: ((IndexPath) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        commentTableView.delegate = self
        commentTableView.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError( "init(coder:) has not been implemented" )
    }
    
    private func setupUI() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        contentView.snp.makeConstraints {
            $0.edges.width.equalToSuperview()
        }
        
        contentView.addSubviews(postView, gray100View, commentTableView)
        
        postView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        
        gray100View.snp.makeConstraints {
            $0.height.equalTo(8)
            $0.top.equalTo(postView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
        }
        
        commentTableView.snp.makeConstraints {
            $0.top.equalTo(gray100View.snp.bottom)
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.greaterThanOrEqualTo(1)
        }
        
        postView.onTapLike = { [weak self] in self?.onTapPostLike?() }
        commentTableView.delegate = self
        commentTableView.dataSource = self
    }
    
    func updatePost(_ post: CommunityDetailPostModel) {
        postView.configure(with: post)
    }
    
    func updateComments(_ comments: [CommunityDetailCommentModel]) {
        self.comments = comments
        commentTableView.reloadData()
        
        DispatchQueue.main.async {
            self.commentTableView.layoutIfNeeded()
            let tableHeight = self.commentTableView.contentSize.height
            
            self.commentTableView.snp.remakeConstraints {
                $0.top.equalTo(self.gray100View.snp.bottom)
                $0.leading.trailing.equalToSuperview()
                $0.height.equalTo(tableHeight)
            }
            self.contentView.snp.remakeConstraints {
                $0.edges.width.equalToSuperview()
                $0.bottom.equalTo(self.commentTableView.snp.bottom)
            }
            self.scrollView.layoutIfNeeded()
        }
    }
    
    func updateTableViewInsets(_ bottomInset: CGFloat) {
        commentTableView.contentInset.bottom = bottomInset
        commentTableView.scrollIndicatorInsets.bottom = bottomInset
    }
    
    func setPostDeleteHandler(_ handler: @escaping () -> Void) {
        postView.setDeleteHandler(handler)
    }
    
    func updatePostLikeUI(liked: Bool, count: Int) {
        postView.updateLikeUI(liked: liked, count: count)
    }
    func updateCommentLikeUI(at indexPath: IndexPath, liked: Bool, count: Int) {
        (commentTableView.cellForRow(at: indexPath) as? CommunityDetailCommentCell)?
            .updateLikeUI(liked: liked, count: count)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension CommunityDetailView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: CommunityDetailCommentCell.identifier, for: indexPath
        ) as! CommunityDetailCommentCell
        let model = comments[indexPath.row]
        cell.configure(with: model)

        cell.onTapReply = { [weak self] in
            self?.onStartReply?(indexPath)
        }
        return cell
    }
}
