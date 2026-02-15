//
//  PolicyDetailViewController.swift
//  ChungBazi
//

import UIKit
import SnapKit
import Then
import SwiftyToaster

final class PolicyDetailViewController: UIViewController {
    
    private var posterViewHeightConstraint: Constraint?
    
    private var entryPoint: PolicyDetailEntryPoint?
    private var hasTrackedView = false
    
    var policyId: Int?
    var policy: PolicyModel?
    private var policyTarget: PolicyTarget?
    let networkService = PolicyService()
    private weak var currentUrlAlert: MultiURLCustomAlertView?
    
    private var linkUrls: [String] = []   // 유효 링크만 저장
    
    private var trackedDepths: Set<Int> = []
    private var currentScrollDepth: Int = 0
    
    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
    }
    
    private let contentView = UIView()
    private let posterView = PosterView().then { $0.backgroundColor = .clear }
    
    private let policyView = PolicyView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.clipsToBounds = true
    }
    
    private let expandButton = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "expand_icon"), for: .normal)
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 19.5
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.1
        $0.layer.shadowOffset = CGSize(width: 0, height: 4)
        $0.layer.shadowRadius = 4
    }
    
    private let bottomBackgroundView = UIView().then {
        $0.layer.cornerRadius = 10
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.layer.shadowColor = UIColor.black.withAlphaComponent(0.18).cgColor
        $0.layer.shadowOffset = CGSize(width: 0, height: -1)
        $0.layer.shadowRadius = 5
        $0.layer.shadowOpacity = 1
        $0.backgroundColor = .white
    }
    
    private lazy var cartButton = CustomButton(
        backgroundColor: .white,
        titleText: "저장하기",
        titleColor: .gray800,
        borderWidth: 1,
        borderColor: .gray400
    )
    
    private let registerButton = CustomActiveButton(title: "담당기관 바로가기", isEnabled: false).then {
        $0.addTarget(self, action: #selector(handleRegisterButtonTap), for: .touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        trackPolicyDetailViewIfNeeded()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addCustomNavigationBar(
            titleText: "",
            showBackButton: true,
            showCartButton: false,
            showAlarmButton: false,
            showShareButton: true,
            backgroundColor: .white
        )
        
        scrollView.alpha = 0
        bottomBackgroundView.alpha = 0
        setExpandButtonVisible(false)
        showLoading()
        
        setupDelegate()
        setupLayout()
        fetchPolicyDetail()
        setupActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
        
        if isMovingFromParent {
            guard let policyId = policy?.policyId else { return }
            
            AmplitudeManager.shared.trackBackClick(
                policyId: policyId,
                scrollDepth: currentScrollDepth
            )
        }
    }
    
    private func setupDelegate() {
        scrollView.delegate = self
    }
    
    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubviews(posterView, expandButton, policyView)
        
        view.addSubview(bottomBackgroundView)
        bottomBackgroundView.addSubviews(cartButton, registerButton)
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(65)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(bottomBackgroundView.snp.top)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }
        
        posterView.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.top)
            make.leading.trailing.equalToSuperview()
            self.posterViewHeightConstraint = make.height.equalTo(237).constraint
        }
        
        expandButton.snp.makeConstraints { make in
            make.bottom.equalTo(posterView).offset(-40)
            make.trailing.equalTo(posterView).offset(-15)
            make.width.height.equalTo(39)
        }
        
        policyView.snp.makeConstraints { make in
            make.top.equalTo(posterView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(contentView.snp.bottom).offset(-16)
        }
        
        bottomBackgroundView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(92 + view.safeAreaInsets.bottom)
        }
        
        cartButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.centerY.equalToSuperview().offset(-view.safeAreaInsets.bottom / 2 - 7)
            make.width.equalTo(view.frame.width / 2 - 24)
            make.height.equalTo(48)
        }
        
        registerButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview().offset(-view.safeAreaInsets.bottom / 2 - 7)
            make.width.equalTo(view.frame.width / 2 - 24)
            make.height.equalTo(48)
        }
    }
    
    private func fetchPolicyDetail() {
        guard let policyId = policyId else {
            print("⚠️ 정책 ID가 없습니다.")
            return
        }
        
        networkService.fetchPolicyDetail(policyId: policyId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                guard let data = response else { return }
                
                self.policy = PolicyModel(
                    policyId: policyId,
                    posterUrl: data.posterUrl,
                    categoryName: data.categoryName,
                    name: data.name,
                    intro: data.intro,
                    content: data.content,
                    startDate: data.startDate,
                    endDate: data.endDate,
                    applyProcedure: data.applyProcedure,
                    document: data.document,
                    result: data.result,
                    referenceUrl1: data.referenceUrl1,
                    referenceUrl2: data.referenceUrl2,
                    registerUrl: data.registerUrl
                )
                
                self.policyTarget = PolicyTarget(
                    minAge: data.minAge,
                    maxAge: data.maxAge,
                    minIncome: data.minIncome,
                    maxIncome: data.maxIncome,
                    incomeEtc: data.incomeEtc,
                    additionCondition: data.additionCondition,
                    restrictionCondition: data.restrictionCondition
                )
                
                DispatchQueue.main.async {
                    self.updateUI()
                    self.trackPolicyDetailViewIfNeeded()
                }
            case .failure(let error):
                print("❌ 정책 상세 조회 실패: \(error.localizedDescription)")
            }
        }
    }
    
    private func setupActions() {
        expandButton.addTarget(self, action: #selector(handleExpandButtonTap), for: .touchUpInside)
        cartButton.addTarget(self, action: #selector(handleCartButtonTap), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(handleRegisterButtonTap), for: .touchUpInside)
    }
    
    private func updateUI() {
        guard let policy = policy, let target = policyTarget else { return }

        policyView.configure(with: policy, target: target)

        // 유효 링크 세팅
        self.linkUrls = URLHelper.normalizedUrls(from: policy)
        self.registerButton.setEnabled(isEnabled: !self.linkUrls.isEmpty)

        // 포스터 처리 분기
        if let posterUrl = policy.posterUrl, let url = URL(string: posterUrl) {
            downloadImage(from: url) { [weak self] image in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.posterViewHeightConstraint?.update(offset: 207)

                    if let image = image {
                        // 실제 이미지가 있을 때만 확장 버튼 노출
                        self.posterView.configure(with: image)
                        self.setExpandButtonVisible(true)
                    } else {
                        // 다운로드 실패 → 대체 포스터 + 버튼 숨김
                        self.posterView.configureFallback(categoryName: policy.categoryName, title: policy.name)
                        self.setExpandButtonVisible(false)
                    }
                    self.revealContent()
                }
            }
        } else {
            // URL 없음 → 대체 포스터 + 버튼 숨김
            self.posterViewHeightConstraint?.update(offset: 207)
            self.posterView.configureFallback(categoryName: policy.categoryName, title: policy.name)
            self.setExpandButtonVisible(false)
            self.view.layoutIfNeeded()
            self.revealContent()
        }
    }
    
    private func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            completion(data.flatMap { UIImage(data: $0) })
        }.resume()
    }
    
    @objc private func handleExpandButtonTap() {
        let expandImageVC = ExpandImageViewController()
        
        if let image = posterView.posterImageView.image {
            expandImageVC.image = image
        } else {
            expandImageVC.image = nil
            expandImageVC.fallbackCategoryName = policy?.categoryName
            expandImageVC.fallbackTitle = policy?.name
        }
        
        expandImageVC.modalPresentationStyle = .overFullScreen
        present(expandImageVC, animated: true, completion: nil)
    }
    
    @objc private func handleCartButtonTap() {
        guard let policyId = policy?.policyId,
              let policyName = policy?.name else {
            return
        }
        
        AmplitudeManager.shared.trackSavedClick(
            policyId: policyId,
            policyName: policyName
        )
        
        let cartService = CartService()
        cartService.postCart(policyId: policyId) { result in
            switch result {
            case .success:
                Toaster.shared.makeToast("해당 정책이 저장되었습니다")
                
            case .failure(let error):
                Toaster.shared.makeToast(error.localizedDescription)
            }
        }
    }
    
    @objc private func handleRegisterButtonTap() {
        if currentUrlAlert != nil { return }
        
        let urls = self.linkUrls
        guard let policyId = policy?.policyId,
              !urls.isEmpty else { return }
        
        if urls.count == 1, let url = URL(string: urls[0]) {
            AmplitudeManager.shared.trackExternalApplyLinkOpen(
                policyId: policyId,
                externalUrl: url.absoluteString
            )
            
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            return
        }
        
        showMultipleUrlsAlert(urls: urls)
    }
    
    private func presentUrlActionSheet(urls: [String]) {
        let ac = UIAlertController(title: "담당기관 바로가기", message: "열 링크를 선택하세요", preferredStyle: .actionSheet)
        
        for raw in urls {
            let title = raw.replacingOccurrences(of: "^https?://", with: "", options: .regularExpression)
            ac.addAction(UIAlertAction(title: title, style: .default) { _ in
                if let u = URL(string: raw) {
                    UIApplication.shared.open(u, options: [:], completionHandler: nil)
                }
            })
        }
        ac.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        
        present(ac, animated: true, completion: nil)
    }
    
    private func filteredReferenceUrls(_ policy: PolicyModel) -> [String] {
        let raw = [policy.referenceUrl1, policy.referenceUrl2]
        return raw.compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
    
    private func showMultipleUrlsAlert(urls: [String]) {
        let alert = MultiURLCustomAlertView()
        alert.onDismiss = { [weak self] in
            self?.currentUrlAlert = nil
        }
        alert.onSelectUrl = { urlString in
            if let u = URL(string: urlString) {
                UIApplication.shared.open(u, options: [:], completionHandler: nil)
            }
        }
        
        let msg = "해당 정책은 담당기관 바로가기 \n링크가 \(urls.count)개입니다."
        
        guard let policyId = policyId else { return }
        alert.configure(message: msg, urls: urls, policyId: policyId)
        alert.show(in: self)
        
        self.currentUrlAlert = alert
    }
    
    private func setExpandButtonVisible(_ visible: Bool) {
        expandButton.isHidden = !visible
        expandButton.isEnabled = visible
    }
    
    private func revealContent() {
        self.view.layoutIfNeeded()
        self.hideLoading()
        UIView.animate(withDuration: 0.18, delay: 0, options: [.curveEaseOut]) {
            self.scrollView.alpha = 1
            self.bottomBackgroundView.alpha = 1
        }
    }
    
    private func trackPolicyDetailViewIfNeeded() {
        // 이미 트래킹했거나 필수 데이터가 없으면 스킵
        guard !hasTrackedView,
              let policyId = policyId,
              let policyName = policy?.name,
              let policyCategory = policy?.categoryName,
              let entryPoint = entryPoint else {
            return
        }
        
        hasTrackedView = true
        
        AmplitudeManager.shared.trackPolicyDetailView(
            policyId: policyId,
            policyName: policyName,
            policyCategory: policyCategory,
            entryPoint: entryPoint.rawValue
        )
    }
    
    // MARK: - Public Method
    public func configureEntryPoint(_ entryPoint: PolicyDetailEntryPoint) {
        self.entryPoint = entryPoint
    }
}

extension PolicyDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let policyId = policy?.policyId else { return }

        let contentHeight = scrollView.contentSize.height
        let visibleHeight = scrollView.frame.height
        let offsetY = scrollView.contentOffset.y

        let totalScrollableHeight = contentHeight - visibleHeight
        guard totalScrollableHeight > 0 else { return }

        let percentage = (offsetY / totalScrollableHeight) * 100
        currentScrollDepth = min(100, max(0, Int(percentage)))

        trackDepthIfNeeded(policyId: policyId)
    }
    
    private func trackDepthIfNeeded(policyId: Int) {
        let checkpoints = [25, 50, 75, 100]

        for point in checkpoints {
            if currentScrollDepth >= point && !trackedDepths.contains(point) {
                trackedDepths.insert(point)

                AmplitudeManager.shared.trackScrollDepth(
                    policyId: policyId,
                    depth: point
                )
            }
        }
    }
}

struct URLHelper {
    static func normalizedUrls(from policy: PolicyModel) -> [String] {
        let raw = [policy.referenceUrl1, policy.referenceUrl2]
        let trimmed = raw.compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        let normalized = trimmed.compactMap { s -> String? in
            if let u = URL(string: s), let scheme = u.scheme?.lowercased(), (scheme == "http" || scheme == "https") {
                return s
            } else if URL(string: "https://" + s) != nil {
                return "https://" + s
            }
            return nil
        }
        return Array(NSOrderedSet(array: normalized)) as? [String] ?? normalized
    }
}
