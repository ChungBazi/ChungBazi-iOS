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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupRefreshControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData(for: 0, cursor: 0)
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
        self.communityPosts.removeAll()
        fetchData(for: currentCategoryIndex, cursor: 0)
    }
    
    private func fetchData(for categoryIndex: Int, cursor: Int) {
        guard !isFetching, hasNext else { return }
        isFetching = true
        showLoading()

        guard let category = CommunityCategory.allCases[safe: categoryIndex] else { return }

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
                    let newPosts = self.mapCommunityPosts(from: success?.postList ?? [])

                    if cursor == 0 {
                        self.communityPosts = newPosts
                    } else {
                        self.communityPosts.append(contentsOf: newPosts)
                    }

                    self.communityView.updatePosts(self.communityPosts, totalPostCount: success?.totalPostCount ?? 0)

                    print("📌 현재 커서: \(cursor), 받은 nextCursor: \(success?.nextCursor ?? -1), hasNext: \(success?.hasNext ?? false)")

                    if let next = success?.nextCursor, next > cursor {
                        self.nextCursor = next
                    }

                    self.hasNext = success?.hasNext ?? false
                }
            case .failure(let error):
                print("❌ 네트워크 요청 실패: \(error.localizedDescription)")
            }
        }
    }
    
    private func fetchMoreData() {
        guard hasNext, !isFetching else { return }
        fetchData(for: currentCategoryIndex, cursor: nextCursor)
    }
    
    private func mapCommunityPosts(from posts: [Post]) -> [CommunityPost] {
        return posts.map { post in
            CommunityPost(
                postId: post.postId ?? 0,
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
        }
    }
    
    func didSelectCategory(index: Int) {
        self.currentCategoryIndex = index
        self.nextCursor = 0
        self.hasNext = true
        self.communityPosts.removeAll()
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
