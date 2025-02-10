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

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let postView = CommunityDetailPostView()
    
    private let gray100View = UIView().then {
        $0.backgroundColor = .gray100
    }
    
    private let commentTableView = UITableView().then {
        $0.register(CommunityDetailCommentCell.self, forCellReuseIdentifier: CommunityDetailCommentCell.identifier)
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 136
    }
    
    private var comments: [CommunityDetailCommentModel] = []
    
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
            $0.leading.trailing.equalToSuperview()
            $0.height.greaterThanOrEqualTo(1)
        }
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
            
            self.layoutIfNeeded()
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension CommunityDetailView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CommunityDetailCommentCell.identifier, for: indexPath) as? CommunityDetailCommentCell else {
            return UITableViewCell()
        }
        let comment = comments[indexPath.row]
        cell.configure(with: comment)
        return cell
    }
}
