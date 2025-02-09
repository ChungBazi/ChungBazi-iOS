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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchData(for: 0)
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
        addCustomNavigationBar(titleText: "커뮤니티", showBackButton: false, showCartButton: false, showAlarmButton: true, showLeftSearchButton: true)
    }
    
    private func fetchData(for categoryIndex: Int) {
        guard let category = CommunityCategory.allCases[safe: categoryIndex] else { return }
        
        communityService.getCommunityPosts(category: category.rawValue, lastPostId: nil) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let success):
                self.communityPosts = self.mapCommunityPosts(from: success?.postList ?? [])
                self.communityView.updatePosts(self.communityPosts, totalPostCount: success?.totalPostCount ?? 0)
            case .failure(let error):
                print("❌ 네트워크 요청 실패: \(error.localizedDescription)")
            }
        }
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
        fetchData(for: index)
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
