//
//  CommunityViewController.swift
//  ChungBazi
//
//  Created by 신호연 on 2/2/25.
//

import UIKit

final class CommunityViewController: UIViewController, CommunityViewDelegate {
    
    private let communityView = CommunityView()
    private let communityService = CommunityService()
    private var communityPosts: [CommunityPost] = []
    
    private var nextCursor: Int = 0
    private var hasNext: Bool = true
    private var  isFetching: Bool = false
    private var currentCategoryIndex: Int = 0
    
    private let refreshControl = UIRefreshControl()
    
    private var postIdSet: Set<Int> = []
    
    private var scrollOffsetY: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupRefreshControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if communityPosts.isEmpty {
            self.postIdSet.removeAll()
            self.communityPosts.removeAll()
            self.communityView.updatePosts([], totalPostCount: 0)

            self.nextCursor = 0
            self.hasNext = true
            self.isFetching = false

            fetchData(for: currentCategoryIndex, cursor: 0)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.communityView.scrollView.setContentOffset(CGPoint(x: 0, y: self.scrollOffsetY), animated: false)
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        scrollOffsetY = communityView.scrollView.contentOffset.y
    }
    
    private func setupUI() {
        view.backgroundColor = .gray50
        view.addSubview(communityView)
        communityView.delegate = self
        communityView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(Constants.navigationHeight)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.leading.trailing.equalToSuperview()
        }
        addCustomNavigationBar(titleText: "커뮤니티", showBackButton: false, showCartButton: false, showAlarmButton: false, showLeftSearchButton: true)
        communityView.scrollView.delegate = self
    }
    
    private func setupRefreshControl() {
        communityView.scrollView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    }
    
    @objc private func handleRefresh() {
        self.nextCursor = 0
        self.hasNext = true
        self.postIdSet.removeAll()
        fetchData(for: currentCategoryIndex, cursor: 0)
    }

    private func fetchData(for categoryIndex: Int, cursor: Int) {
        guard !isFetching, hasNext else {
            print("❌ 데이터를 가져오지 않음: isFetching: \(isFetching), hasNext: \(hasNext)")
            return
        }

        isFetching = true
        showLoading()

        guard let category = CommunityCategory.allCases[safe: categoryIndex] else {
            print("❌ 유효하지 않은 카테고리 인덱스: \(categoryIndex)")
            return
        }

        communityService.getCommunityPosts(category: category.rawValue, cursor: cursor) { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.hideLoading()
                self.isFetching = false
                self.refreshControl.endRefreshing()
            }

            switch result {
            case .success(let success):
                DispatchQueue.main.async {
                    let rawPosts = success?.postList ?? []

                    let newPosts = self.mapCommunityPosts(from: rawPosts)

                    let filteredPosts = newPosts.filter { !self.postIdSet.contains($0.postId) }

                    self.postIdSet.formUnion(filteredPosts.map { $0.postId })

                    if cursor == 0 {
                        self.communityPosts = filteredPosts
                    } else {
                        if !filteredPosts.isEmpty {
                            self.communityPosts.append(contentsOf: filteredPosts)
                        }
                    }

                    self.communityView.updatePosts(self.communityPosts, totalPostCount: success?.totalPostCount ?? 0)

                    if let next = success?.nextCursor {
                        if next == 0 && self.hasNext {
                            self.hasNext = true
                        }
                        self.nextCursor = next
                    }

                    if let hasNext = success?.hasNext {
                        print("📌 hasNext: \(hasNext)")
                        if self.nextCursor == 0 && hasNext {
                            self.hasNext = true
                        } else {
                            self.hasNext = hasNext
                        }
                    } else {
                        self.hasNext = false
                    }

                    self.communityView.layoutIfNeeded()
                }

            case .failure(let error):
                print("❌ 네트워크 요청 실패: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showRetryButton()
                }
            }
        }
    }
    
    private func showRetryButton() {
        let retryButton = UIButton(type: .system)
        retryButton.setTitle("다시 시도", for: .normal)
        retryButton.addTarget(self, action: #selector(retryFetchData), for: .touchUpInside)
        
        retryButton.frame = CGRect(x: 50, y: 100, width: 200, height: 50)
        retryButton.center = view.center
        retryButton.backgroundColor = .systemRed
        retryButton.setTitleColor(.white, for: .normal)
        retryButton.layer.cornerRadius = 10
        
        view.addSubview(retryButton)
    }
    
    @objc private func retryFetchData() {
        view.subviews.forEach { subview in
            if let button = subview as? UIButton, button.title(for: .normal) == "다시 시도" {
                button.removeFromSuperview()
            }
        }
        fetchData(for: currentCategoryIndex, cursor: nextCursor)
    }
    
    private func fetchMoreDataIfNeeded() {
        guard hasNext, !isFetching else { return }

        let contentHeight = communityView.scrollView.contentSize.height
        let frameHeight = communityView.scrollView.frame.height

        if contentHeight == 0 {
            print("❌ contentHeight가 0이므로 추가 데이터 요청을 중단합니다.")
            return
        }

        if contentHeight < frameHeight + 100 {
            print("🚀 남은 데이터가 적으므로 추가 데이터 요청")
            fetchMoreData()
        }
    }
    
    private func fetchMoreData() {
        guard hasNext, !isFetching else { return }

        print("📡 추가 데이터 요청 - nextCursor: \(nextCursor)")
        
        fetchData(for: currentCategoryIndex, cursor: nextCursor)
    }
    
    private func mapCommunityPosts(from posts: [Post]) -> [CommunityPost] {
        let mappedPosts = posts.compactMap { post -> CommunityPost? in
            guard let postId = post.postId else {
                print("⚠️ 변환 중 postId가 nil인 게시글 발견, 제외")
                return nil
            }

            let communityPost = CommunityPost(
                postId: postId,
                title: post.title ?? "제목 없음",
                content: post.content ?? "내용 없음",
                category: CommunityCategory(rawValue: post.category ?? "") ?? .all,
                formattedCreatedAt: post.formattedCreatedAt ?? "",
                views: post.views ?? 0,
                commentCount: post.commentCount ?? 0,
                postLikes: post.postLikes ?? 0,
                userId: post.userId ?? 0,
                userName: post.userName ?? "익명",
                reward: post.reward ?? "",
                characterImg: post.characterImg ?? "",
                thumbnailUrl: post.thumbnailUrl ?? ""
            )

            return communityPost
        }
    
        return mappedPosts
    }
    
    func didSelectCategory(index: Int) {
        self.currentCategoryIndex = index
        self.nextCursor = 0
        self.hasNext = true
        self.communityPosts.removeAll()
        self.postIdSet.removeAll()

        self.communityView.layoutIfNeeded()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.communityView.scrollView.setContentOffset(CGPoint(x: 0, y: -self.communityView.scrollView.contentInset.top), animated: true)
        }

        fetchData(for: index, cursor: 0)
    }
    
    func didTapWriteButton() {
        let nextVC = CommunityWriteViewController()
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
    func didSelectPost(postId: Int) {
        let detailVC = CommunityDetailViewController(postId: postId)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension CommunityViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.height

        if offsetY > contentHeight - frameHeight - 100 && !isFetching && hasNext {
            fetchMoreData()
        }
    }
}
