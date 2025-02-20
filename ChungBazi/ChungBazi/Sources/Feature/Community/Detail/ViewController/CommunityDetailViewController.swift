//
//  CommunityDetailViewController.swift
//  ChungBazi
//
//  Created by 신호연 on 2/8/25.
//

import UIKit
import SnapKit
import SafeAreaBrush

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
        $0.backgroundColor = .gray100
        $0.font = .ptdMediumFont(ofSize: 16)
        $0.textColor = .gray800
        $0.attributedPlaceholder = NSAttributedString(
            string: "댓글을 입력하세요.",
            attributes: [.foregroundColor: UIColor.gray300]
        )
        $0.layer.cornerRadius = 10
        $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 19, height: 1))
        $0.leftViewMode = .always
        $0.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 19 + 24 + 16, height: 1))
        $0.rightViewMode = .always
    }
    
    private let sendButton = UIButton.createWithImage(image: .sendIcon, tintColor: .blue700, target: self, action: #selector(sendButtonTapped))
    private let backgroundView = UIView().then {
        $0.backgroundColor = .white
    }
    
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
        communityDetailView.scrollView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
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
        commentInputView.addSubview(commentTextField)
        commentTextField.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(Constants.gutter)
            $0.top.bottom.equalToSuperview().inset(10)
        }
        commentTextField.addSubview(sendButton)
        sendButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(Constants.gutter)
        }
        
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
                    views: success.views,
                    commentCount: success.commentCount,
                    postLikes: success.postLikes,
                    userId: success.userId,
                    userName: success.userName,
                    reward: success.reward,
                    characterImg: success.characterImg,
                    imageUrls: success.imageUrls
                )
                
                DispatchQueue.main.async {
                    self.updateNavigationBarTitle(with: self.postData?.categoryDisplayName ?? "커뮤니티")
                    self.communityDetailView.updatePost(self.postData!)
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
                    
                    let newComments = response.commentsList.compactMap { comment -> CommunityDetailCommentModel? in
                        guard let postId = comment.postId,
                              let content = comment.content,
                              let formattedCreatedAt = comment.formattedCreatedAt,
                              let commentId = comment.commentId,
                              let userId = comment.userId,
                              let userName = comment.userName,
                              let reward = comment.reward,
                              let characterImg = comment.characterImg else {
                            return nil
                        }
                        return CommunityDetailCommentModel(
                            postId: postId,
                            content: content,
                            formattedCreatedAt: formattedCreatedAt,
                            commentId: commentId,
                            userId: userId,
                            userName: userName,
                            reward: reward,
                            characterImg: characterImg
                        )
                    }

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
        guard let commentText = commentTextField.text,
              !commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              sendButton.isEnabled else { return }

        sendButton.isEnabled = false
        NotificationCenter.default.addObserver(self, selector: #selector(handleSendAfterKeyboardHide), name: UIResponder.keyboardDidHideNotification, object: nil)

        view.endEditing(true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.forceSendCommentIfNeeded()
        }
    }

    @objc private func handleSendAfterKeyboardHide() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
        sendComment()
    }

    private func forceSendCommentIfNeeded() {
        if commentTextField.isFirstResponder == false {
            sendComment()
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
