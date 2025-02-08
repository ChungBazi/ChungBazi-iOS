//
//  CommunityDetailViewController.swift
//  ChungBazi
//
//  Created by 신호연 on 2/8/25.
//

import UIKit
import SafeAreaBrush

final class CommunityDetailViewController: UIViewController {
    
    private let communityDetailView = CommunityDetailView()
    private let communityService = CommunityService()
    
    private var postId: Int
    private var postData: CommunityDetailPostModel?
    private var comments: [CommunityDetailCommentModel] = []
    
    init(postId: Int) {
        self.postId = postId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchPostData()
        fetchCommentData()
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
        view.addSubview(communityDetailView)
        communityDetailView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(Constants.navigationHeight)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.leading.trailing.equalToSuperview()
        }
        // FIXME: - 카테고리에 따라 타이틀텍스트 변경
        addCustomNavigationBar(titleText: "", showBackButton: true, showCartButton: false, showAlarmButton: false, backgroundColor: .white)
        fillSafeArea(position: .top, color: .white)
        fillSafeArea(position: .bottom, color: .white)
    }
    
    // MARK: - API 요청: 개별 게시글 가져오기
        private func fetchPostData() {
            communityService.getCommunityPost(postId: postId) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let success):
                    self.postData = CommunityDetailPostModel(
                        postId: success.postId,
                        title: success.title,
                        content: success.content,
                        category: success.category,
                        formattedCreatedAt: success.formattedCreatedAt,
                        views: success.views,
                        commentCount: success.commentCount,
                        postLikes: success.postLikes,
                        userId: success.userId,
                        userName: success.userName,
                        reward: success.reward,
                        characterImg: success.characterImg
                    )
                    self.communityDetailView.updatePost(self.postData!)
                case .failure(let error):
                    print("❌ 게시글 불러오기 실패: \(error.localizedDescription)")
                }
            }
        }
        
        // MARK: - API 요청: 개별 게시글의 댓글 가져오기
        private func fetchCommentData() {
            communityService.getCommunityComments(postId: postId, lastCommentId: nil, size: 10) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let success):
                    self.comments = success.map { comment in
                        CommunityDetailCommentModel(
                            postId: comment.postId,
                            content: comment.content,
                            formattedCreatedAt: comment.formattedCreatedAt,
                            commentId: comment.commentId,
                            userId: comment.userId,
                            userName: comment.userName,
                            reward: comment.reward,
                            characterImg: comment.characterImg
                        )
                    }
                    self.communityDetailView.updateComments(self.comments)
                case .failure(let error):
                    print("❌ 댓글 불러오기 실패: \(error.localizedDescription)")
                }
            }
        }
    }
