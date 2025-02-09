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
    
    private let scrollView = UIScrollView()
    
    private var postId: Int
    private var postData: CommunityDetailPostModel?
    private var comments: [CommunityDetailCommentModel] = []
    
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
        
        // FIXME: - 카테고리에 따라 타이틀텍스트 변경
        addCustomNavigationBar(titleText: "", showBackButton: true, showCartButton: false, showAlarmButton: false, backgroundColor: .white)
        fillSafeArea(position: .top, color: .white)
        fillSafeArea(position: .bottom, color: .white)
        enableKeyboardHandling(for: scrollView, inputView: commentInputView)
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(Constants.navigationHeight)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.leading.trailing.equalToSuperview()
        }
        scrollView.isScrollEnabled = false
        
        scrollView.addSubviews(communityDetailView, commentInputView)
        communityDetailView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
            $0.bottom.equalTo(commentInputView.snp.top)
        }
        
        commentInputView.snp.makeConstraints {
            $0.leading.trailing.equalTo(scrollView.frameLayoutGuide)
            $0.bottom.equalTo(scrollView.frameLayoutGuide.snp.bottom)
            $0.height.equalTo(58)
        }
        commentInputView.addSubview(commentTextField)
        commentTextField.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(Constants.gutter)
            $0.top.equalToSuperview().inset(10)
            $0.bottom.equalToSuperview()
        }
        commentTextField.addSubview(sendButton)
        sendButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(Constants.gutter)
        }
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
                    characterImg: success.characterImg,
                    imageUrls: success.imageUrls
                )
                self.communityDetailView.updatePost(self.postData!)
            case .failure(let error):
                print("❌ 게시글 불러오기 실패: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - API 요청: 개별 게시글의 댓글 가져오기
    // MARK: - API 요청: 개별 게시글의 댓글 가져오기
    private func fetchCommentData() {
        communityService.getCommunityComments(postId: postId, lastCommentId: nil) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let success):
                print("🔹 서버 응답 데이터: \(success)")

                if success?.result?.isEmpty ?? true {
                    print("⚠️ 댓글이 없습니다.")
                    self.comments = []
                    self.communityDetailView.updateComments(self.comments)
                    return
                }

                self.comments = success?.result?.map { comment in
                    CommunityDetailCommentModel(
                        postId: comment.postId ?? 0,
                        content: comment.content ?? "내용 없음",
                        formattedCreatedAt: comment.formattedCreatedAt ?? "",
                        commentId: comment.commentId ?? 0,
                        userId: comment.userId ?? 0,
                        userName: comment.userName ?? "익명",
                        reward: comment.reward ?? "",
                        characterImg: comment.characterImg ?? ""
                    )
                } ?? []
                self.communityDetailView.updateComments(self.comments)
                
            case .failure(let error):
                print("❌ 댓글 불러오기 실패: \(error.localizedDescription)")
            }
        }
    }
    
    @objc private func sendButtonTapped() {
        
    }
}
