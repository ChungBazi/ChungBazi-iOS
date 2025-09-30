//
//  CommunityDetailViewController.swift
//  ChungBazi
//
//  Created by 신호연 on 2/8/25.
//

import UIKit
import SnapKit
import SafeAreaBrush
import SwiftyToaster

final class CommunityDetailViewController: UIViewController {
    
    private let communityDetailView = CommunityDetailView()
    private let communityService = CommunityService()
    
    private let scrollView = UIScrollView()
    
    private var postId: Int
    private var postData: CommunityDetailPostModel?
    private var comments: [CommunityDetailCommentModel] = []
    
    private var isFetching: Bool = false
    private var nextCursor: Int = 0
    private var hasNext: Bool = true
    
    private let refreshControl = UIRefreshControl()
    
    private var commentInputBottomConstraint: Constraint?
    
    private var isLoadingMore = false
    
    private let commentInputView = UIView().then {
        $0.backgroundColor = .white
    }
    private let commentTextField = UITextField().then {
        $0.backgroundColor = .clear
        $0.font = .ptdMediumFont(ofSize: 16)
        $0.textColor = .gray800
        $0.attributedPlaceholder = NSAttributedString(
            string: "댓글을 입력하세요.",
            attributes: [.foregroundColor: UIColor.gray300]
        )
        $0.layer.cornerRadius = 0
        $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 22))
        $0.leftViewMode = .always
        $0.rightView = nil
        $0.rightViewMode = .never
        $0.returnKeyType = .send
    }
    
    private let sendButton = UIButton.createWithImage(image: .sendIcon, tintColor: .blue700, target: self, action: #selector(sendButtonTapped))
    private let backgroundView = UIView().then {
        $0.backgroundColor = .white
    }
    
    private var isPostLikeBusy = false
    private var busyCommentLikes = Set<Int>()
    
    private var replyTarget: (commentId: Int, userName: String)? = nil
    
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
        
        /// 댓글 삭제 후 리프레시
        communityDetailView.onRequestRefresh = { [weak self] in
            guard let self else { return }
            self.nextCursor = 0
            self.hasNext = true
            self.comments.removeAll()
            self.communityDetailView.updateComments(self.comments)
            self.fetchCommentData()
            self.fetchPostData()
        }
        
        /// 글 삭제 후 루트로
        communityDetailView.setPostDeleteHandler { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .communityShouldRefresh, object: nil)
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
        
        fetchPostData()
        fetchCommentData()
        communityDetailView.scrollView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        hookLikeHandlers()
        hookReplyHandlers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
        
        addCustomNavigationBar(titleText: "", showBackButton: true, showCartButton: false, showAlarmButton: false, backgroundColor: .white)
        fillSafeArea(position: .top, color: .white)
        fillSafeArea(position: .bottom, color: .white)
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(Constants.navigationHeight)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalToSuperview()
        }
        scrollView.isScrollEnabled = false
        scrollView.delegate = self
        
        scrollView.addSubviews(communityDetailView)
        communityDetailView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(58)
        }
        
        view.addSubview(backgroundView)
        backgroundView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.height.equalTo(68)
        }
        
        view.addSubview(commentInputView)
        commentInputView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.height.equalTo(68)
        }
        
        let inputBackground = UIView()
        inputBackground.backgroundColor = .gray100
        inputBackground.layer.cornerRadius = 10
        inputBackground.clipsToBounds = true
        
        commentInputView.addSubview(inputBackground)
        inputBackground.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(10)
            $0.leading.trailing.equalToSuperview().inset(Constants.gutter)
        }
        
        inputBackground.addSubview(commentTextField)
        inputBackground.addSubview(sendButton)
        
        sendButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(16)
            $0.width.height.equalTo(24)
        }
        
        commentTextField.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(19)
            $0.top.bottom.equalToSuperview()
            $0.trailing.equalTo(sendButton.snp.leading).offset(-8)
        }
        
        sendButton.setContentHuggingPriority(.required, for: .horizontal)
        commentTextField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        enableKeyboardHandling(for: scrollView, inputView: commentInputView)
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
                    category: CommunityCategory(rawValue: success.category) ?? .all,
                    formattedCreatedAt: success.formattedCreatedAt,
                    status: success.status,
                    views: success.views,
                    commentCount: success.commentCount,
                    postLikes: success.postLikes,
                    userId: success.userId,
                    userName: success.userName,
                    reward: success.reward,
                    characterImg: success.characterImg,
                    thumbnailUrl: success.thumbnailUrl,
                    imageUrls: success.imageUrls,
                    anonymous: success.anonymous,
                    mine: success.mine,
                    likedByUser: success.likedByUser
                )
                
                DispatchQueue.main.async(group: nil, qos: .userInitiated, flags: []) {
                    guard let post = self.postData else { return }
                    self.updateNavigationBarTitle(with: post.categoryDisplayName)
                    self.communityDetailView.updatePost(post)
                }
                
            case .failure(let error):
                print("❌ 게시글 불러오기 실패: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - API 요청: 개별 게시글의 댓글 가져오기
    private func fetchCommentData() {
        guard hasNext, !isFetching else { return }
        
        isFetching = true
        
        communityService.getCommunityComments(postId: postId, cursor: nextCursor) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isFetching = false
                
                switch result {
                case .success(let response):
                    guard let response = response else { return }
                    
                    let newComments = self.flattenComments(response.commentsList)
                    if self.nextCursor == 0 {
                        self.comments = newComments
                    } else {
                        self.comments.append(contentsOf: newComments)
                    }
                    
                    if response.nextCursor != self.nextCursor {
                        self.nextCursor = response.nextCursor
                    } else {
                        print("⚠️ nextCursor 변경 없음! 더 이상 로드할 데이터 없음")
                        self.hasNext = false
                    }
                    
                    self.hasNext = !newComments.isEmpty && response.hasNext
                    
                    self.communityDetailView.updateComments(self.comments)
                    
                case .failure(let error):
                    print("❌ 댓글 불러오기 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @objc private func sendButtonTapped() {
        guard sendButton.isEnabled else { return }
        let text = commentTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !text.isEmpty else { return }
        
        sendButton.isEnabled = false
        sendComment(text)
        view.endEditing(true)
    }
    
    private func sendComment(_ text: String) {
        let parentId = replyTarget?.commentId
        let commentRequest = CommunityCommentRequestDto(
            postId: postId,
            content: text,
            parentCommentId: parentId
        )
        
        communityService.postCommunityComment(body: commentRequest) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.commentTextField.text = ""
                    self.replyTarget = nil
                    self.commentTextField.attributedPlaceholder = NSAttributedString(
                        string: "댓글을 입력하세요.",
                        attributes: [.foregroundColor: UIColor.gray300]
                    )
                    
                    self.nextCursor = 0
                    self.hasNext = true
                    self.comments.removeAll()
                    self.communityDetailView.updateComments(self.comments)
                    self.fetchCommentData()
                    self.fetchPostData()
                    
                case .failure(let error):
                    Toaster.shared.makeToast("댓글 작성에 실패했어요. 다시 시도해 주세요.")
                    print("❌ 댓글 작성 실패: \(error.localizedDescription)")
                }
                self.sendButton.isEnabled = true
            }
        }
    }
    
    private func sendComment() {
        guard let commentText = commentTextField.text, !commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("⚠️ 댓글이 비어있습니다.")
            sendButton.isEnabled = true
            return
        }
        
        let commentRequest = CommunityCommentRequestDto(postId: postId, content: commentText)
        
        communityService.postCommunityComment(body: commentRequest) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.commentTextField.text = ""
                    self.view.endEditing(true)
                    
                    self.nextCursor = 0
                    self.hasNext = true
                    self.comments.removeAll()
                    self.communityDetailView.updateComments(self.comments)
                    
                    self.fetchCommentData()
                    self.fetchPostData()
                    
                case .failure(let error):
                    print("❌ 댓글 작성 실패: \(error.localizedDescription)")
                }
                self.sendButton.isEnabled = true
            }
        }
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let window = view.window else { return }
        
        let keyboardHeight = window.frame.height - keyboardFrame.origin.y
        let safeAreaBottomInset = view.safeAreaInsets.bottom
        let adjustedKeyboardHeight = keyboardHeight - safeAreaBottomInset
        
        UIView.animate(withDuration: 0.3) {
            self.commentInputBottomConstraint?.deactivate()
            self.commentInputBottomConstraint = nil
            
            self.commentInputView.snp.remakeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.bottom.equalToSuperview().offset(-keyboardHeight)
                make.height.equalTo(68)
            }
            
            self.scrollView.snp.remakeConstraints { make in
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).inset(Constants.navigationHeight)
                make.bottom.equalTo(self.commentInputView.snp.top)
                make.leading.trailing.equalToSuperview()
            }
            
            self.communityDetailView.snp.remakeConstraints { make in
                make.top.leading.trailing.equalTo(self.scrollView.contentLayoutGuide)
                make.width.equalTo(self.scrollView.frameLayoutGuide)
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).inset(58 + adjustedKeyboardHeight)
            }
            
            self.scrollView.contentInset.bottom = adjustedKeyboardHeight
            self.scrollView.scrollIndicatorInsets.bottom = adjustedKeyboardHeight
            
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.commentInputBottomConstraint?.deactivate()
            self.commentInputBottomConstraint = nil
            
            self.commentInputView.snp.remakeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
                make.height.equalTo(68)
            }
            
            self.scrollView.snp.remakeConstraints { make in
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).inset(Constants.navigationHeight)
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
                make.leading.trailing.equalToSuperview()
            }
            
            self.communityDetailView.snp.remakeConstraints { make in
                make.top.leading.trailing.equalTo(self.scrollView.contentLayoutGuide)
                make.width.equalTo(self.scrollView.frameLayoutGuide)
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).inset(58)
            }
            
            self.scrollView.contentInset.bottom = 0
            self.scrollView.scrollIndicatorInsets.bottom = 0
            
            self.view.layoutIfNeeded()
        }
    }
    
    private func updateNavigationBarTitle(with title: String) {
        addCustomNavigationBar(titleText: title, showBackButton: true, showCartButton: false, showAlarmButton: false, backgroundColor: .white)
    }
    
    private func setupRefreshControl() {
        scrollView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    }
    
    @objc private func handleRefresh() {
        self.nextCursor = 0
        self.hasNext = true
        self.comments.removeAll()
        
        self.communityDetailView.updateComments(self.comments)
        
        fetchPostData()
        fetchCommentData()
        
        DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
        }
    }
    
    private func hookLikeHandlers() {
        communityDetailView.onTapPostLike = { [weak self] in
            self?.togglePostLike()
        }
        communityDetailView.onTapCommentLike = { [weak self] indexPath in
            self?.toggleCommentLike(at: indexPath)
        }
    }
    
    private func togglePostLike() {
        guard !isPostLikeBusy, var post = postData else { return }
        isPostLikeBusy = true
        
        let newLiked = !post.likedByUser
        let newCount = post.postLikes + (newLiked ? 1 : -1)
        communityDetailView.updatePostLikeUI(liked: newLiked, count: max(0, newCount))
        
        post = CommunityDetailPostModel(
            postId: post.postId,
            title: post.title,
            content: post.content,
            category: post.category,
            formattedCreatedAt: post.formattedCreatedAt,
            status: post.status,
            views: post.views,
            commentCount: post.commentCount,
            postLikes: max(0, newCount),
            userId: post.userId,
            userName: post.userName,
            reward: post.reward,
            characterImg: post.characterImg,
            thumbnailUrl: post.thumbnailUrl,
            imageUrls: post.imageUrls,
            anonymous: post.anonymous,
            mine: post.mine,
            likedByUser: newLiked
        )
        self.postData = post
        
        let call: (@escaping (Result<Void, Error>) -> Void) -> Void = newLiked
        ? { self.communityService.postLike(postId: post.postId, completion: $0) }
        : { self.communityService.deleteLike(postId: post.postId, completion: $0) }
        
        call { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isPostLikeBusy = false
                switch result {
                case .success:
                    break
                case .failure:
                    let rolledLiked = !newLiked
                    let rolledCount = post.postLikes + (rolledLiked ? 1 : -1)
                    self.communityDetailView.updatePostLikeUI(liked: rolledLiked, count: max(0, rolledCount))
                    self.postData = CommunityDetailPostModel(
                        postId: post.postId,
                        title: post.title,
                        content: post.content,
                        category: post.category,
                        formattedCreatedAt: post.formattedCreatedAt,
                        status: post.status,
                        views: post.views,
                        commentCount: post.commentCount,
                        postLikes: max(0, rolledCount),
                        userId: post.userId,
                        userName: post.userName,
                        reward: post.reward,
                        characterImg: post.characterImg,
                        thumbnailUrl: post.thumbnailUrl,
                        imageUrls: post.imageUrls,
                        anonymous: post.anonymous,
                        mine: post.mine,
                        likedByUser: rolledLiked
                    )
                    Toaster.shared.makeToast("좋아요 처리에 실패했어요. 네트워크를 확인해 주세요.")
                }
            }
        }
    }
    
    private func toggleCommentLike(at indexPath: IndexPath) {
        guard indexPath.row < comments.count else { return }
        let curr = comments[indexPath.row]
        guard !busyCommentLikes.contains(curr.commentId) else { return }
        busyCommentLikes.insert(curr.commentId)
        
        let newLiked = !curr.likedByUser
        let newCount = curr.likesCount + (newLiked ? 1 : -1)
        communityDetailView.updateCommentLikeUI(at: indexPath, liked: newLiked, count: max(0, newCount))
        
        let updated = CommunityDetailCommentModel(
            postId: curr.postId,
            content: curr.content,
            formattedCreatedAt: curr.formattedCreatedAt,
            commentId: curr.commentId,
            userId: curr.userId,
            userName: curr.userName,
            reward: curr.reward,
            characterImg: curr.characterImg,
            likesCount: max(0, newCount),
            parentCommentId: curr.parentCommentId,
            deleted: curr.deleted,
            mine: curr.mine,
            likedByUser: newLiked
        )
        comments[indexPath.row] = updated
        
        let call: (@escaping (Result<Void, Error>) -> Void) -> Void = newLiked
        ? { self.communityService.postCommentLike(commentId: curr.commentId, completion: $0) }
        : { self.communityService.deleteCommentLike(commentId: curr.commentId, completion: $0) }
        
        call { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.busyCommentLikes.remove(curr.commentId)
                switch result {
                case .success:
                    break
                case .failure:
                    let rolledLiked = !newLiked
                    let rolledCount = updated.likesCount + (rolledLiked ? 1 : -1)
                    self.communityDetailView.updateCommentLikeUI(at: indexPath, liked: rolledLiked, count: max(0, rolledCount))
                    self.comments[indexPath.row] = CommunityDetailCommentModel(
                        postId: curr.postId,
                        content: curr.content,
                        formattedCreatedAt: curr.formattedCreatedAt,
                        commentId: curr.commentId,
                        userId: curr.userId,
                        userName: curr.userName,
                        reward: curr.reward,
                        characterImg: curr.characterImg,
                        likesCount: max(0, rolledCount),
                        parentCommentId: curr.parentCommentId,
                        deleted: curr.deleted,
                        mine: curr.mine,
                        likedByUser: rolledLiked
                    )
                    Toaster.shared.makeToast("댓글 좋아요 처리에 실패했어요.")
                }
            }
        }
    }
    
    private func hookReplyHandlers() {
        communityDetailView.onStartReply = { [weak self] indexPath in
            guard let self = self, indexPath.row < self.comments.count else { return }
            let c = self.comments[indexPath.row]
            if c.deleted {
                Toaster.shared.makeToast("삭제된 댓글에는 대댓글을 달 수 없어요.")
                return
            }
            self.replyTarget = (commentId: c.commentId, userName: c.userName)

            self.commentTextField.becomeFirstResponder()
        }
    }
    
    private func makeCommentModel(from c: Comment) -> CommunityDetailCommentModel? {
        guard
            let postId = c.postId,
            let content = c.content,
            let formatted = c.formattedCreatedAt,
            let commentId = c.commentId,
            let userId = c.userId,
            let userName = c.userName,
            let reward = c.reward,
            let characterImg = c.characterImg
        else { return nil }

        return CommunityDetailCommentModel(
            postId: postId,
            content: content,
            formattedCreatedAt: formatted,
            commentId: commentId,
            userId: userId,
            userName: userName,
            reward: reward,
            characterImg: characterImg,
            likesCount: c.likesCount ?? 0,
            parentCommentId: c.parentCommentId,
            deleted: c.deleted ?? false,
            mine: c.mine,
            likedByUser: c.likedByUser ?? false
        )
    }

    private func flattenComments(_ list: [Comment]) -> [CommunityDetailCommentModel] {
        var result: [CommunityDetailCommentModel] = []
        func dfs(_ node: Comment) {
            if let m = makeCommentModel(from: node) { result.append(m) }
            (node.comments ?? []).forEach { dfs($0) }  // 재귀로 모든 자식 순회
        }
        list.forEach { dfs($0) }
        return result
    }
}

extension CommunityDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.height
        
        if offsetY > contentHeight - frameHeight - 100 && hasNext && !isFetching && !isLoadingMore {
            isLoadingMore = true
            self.fetchCommentData()
            self.isLoadingMore = false
        }
    }
}
