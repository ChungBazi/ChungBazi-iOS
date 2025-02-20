//
//  CalendarDetailViewController.swift
//  ChungBazi
//
//  Created by 신호연 on 1/20/25.
//

import UIKit
import SnapKit

protocol DocumentListUpdatable: AnyObject {
    func updateDocuments(with documents: [Document])
}

final class CalendarDetailViewController: UIViewController {
    
    // MARK: - Properties
    private let calendarDetailView = CalendarDetailView()
    private var documentList: [Document] = [] {
        didSet {
            notifyViews()
        }
    }
    private var policy: Policy?
    var cartId: Int
    var policyId: Int
    
    let policyNetwork = PolicyService()
    let calendarNetwork = CalendarService()
    
    private let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["서류 리스트", "서류 참고 내용"])
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private let secondView = CalendarDetailDocumentReferenceView()
    private let underLineView = UIView().then {
        $0.backgroundColor = .blue700
    }
    
    private let staticUnderLineView = UIView().then {
        $0.backgroundColor = .gray100
    }
    
    private var emptyView = EmptyView()
    private var notEmptyView: NotEmptyView!
    private var addingView: AddingView!
    private var editingView: EditingView!
    
    private var currentState: ViewState = .empty {
            didSet { updateFirstView() }
        }
    
    // MARK: - Lifecycle
    init(policy: Policy) {
        self.policy = policy
        self.cartId = policy.cartId
        self.policyId = policy.policyId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notEmptyView = NotEmptyView()
        addingView = AddingView()
        editingView = EditingView()
        
        addingView.delegate = self
        editingView.delegate = self
        notEmptyView.delegate = self
        
        fetchCalendarPolicyDetail()
        
        setupUI()
        setupActions()
        if let policy = policy {
            bindPolicyData(policy)
        }
        
        self.segmentedControl.selectedSegmentIndex = 0
        self.didChangeValue(self.segmentedControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        addCustomGrabber(to: view)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        callCheckUpdate()
    }

    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .white
        setupCalendarDetailView()
    }
    
    private func setupCalendarDetailView() {
        view.addSubview(calendarDetailView)
        calendarDetailView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        let contentView = calendarDetailView.accessibleContentView
        
        contentView.addSubviews(segmentedControl, staticUnderLineView, underLineView, emptyView, notEmptyView, addingView, editingView, secondView)

        [emptyView, notEmptyView, addingView, editingView, secondView].forEach {
            $0.snp.makeConstraints {
                $0.top.equalTo(underLineView.snp.bottom).offset(1)
                $0.leading.trailing.bottom.equalToSuperview()
            }
        }
        secondView.snp.makeConstraints {
            $0.top.equalTo(segmentedControl.snp.bottom).offset(1)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(30)
        }
        segmentedControl.snp.makeConstraints {
            $0.top.equalTo(calendarDetailView.accessiblePolicyInfoView.snp.bottom).offset(21)
            $0.leading.trailing.equalTo(calendarDetailView)
            $0.height.equalTo(48)
        }
        staticUnderLineView.snp.makeConstraints {
            $0.top.equalTo(segmentedControl.snp.bottom)
            $0.height.equalTo(1)
            $0.horizontalEdges.equalToSuperview()
        }
        underLineView.snp.makeConstraints {
            $0.top.equalTo(staticUnderLineView.snp.top)
            $0.height.equalTo(1)
            $0.width.equalToSuperview().dividedBy(2)
            $0.leading.equalToSuperview()
        }
        
        configureSegmentControlAppearance()
        updateFirstView()
        
        secondView.isHidden = true
    }
    
    private func updateDocumentList(_ newList: [Document]) {
        DispatchQueue.main.async {
            self.documentList = newList
            self.notEmptyView.updateDocuments(with: newList)
            self.editingView.updateDocuments(with: newList)
        }
    }
    
    private func updateFirstView() {
        let isReferenceView = segmentedControl.selectedSegmentIndex == 1
        
        secondView.isHidden = !isReferenceView
        emptyView.isHidden = isReferenceView || currentState != .empty
        notEmptyView.isHidden = isReferenceView || currentState != .viewing
        addingView.isHidden = isReferenceView || currentState != .adding
        editingView.isHidden = isReferenceView || currentState != .editing
    }
    
    private func setupActions() {
        segmentedControl.addTarget(self, action: #selector(changeSegmentedControlLinePosition(_:)), for: .valueChanged)
        segmentedControl.addTarget(self, action: #selector(didChangeValue(_:)), for: .valueChanged)
        
        emptyView.addButton.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
        notEmptyView.addButton.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
        notEmptyView.editButton.addTarget(self, action: #selector(didTapEditButton), for: .touchUpInside)
        addingView.saveButton.addTarget(self, action: #selector(didTapSaveButton), for: .touchUpInside)
        editingView.saveButton.addTarget(self, action: #selector(didTapSaveButton), for: .touchUpInside)
    }
    
    private func notifyViews() {
        notEmptyView.updateDocuments(with: documentList)
        editingView.updateDocuments(with: documentList)
    }
    
    @objc private func didTapAddButton() {
        addingView.resetDocuments()
        callCheckUpdate()
        currentState = .adding
        updateFirstView()
    }
    
    @objc private func didTapSaveButton() {
        switch currentState {
        case .adding:
            postpostCalendarDocuments(documents: addingView.getDocumentContents()) { [weak self] in
                self?.fetchCalendarPolicyDetail() // 최신 데이터 가져오기
                DispatchQueue.main.async {
                    self?.currentState = .viewing
                    self?.updateFirstView()
                }
            }
            
        case .editing:
            updateCalendarDocumentsDetail(body: editingView.getUpdatedDocuments()) { [weak self] in
                guard let self = self else { return }
                
                // 체크 상태 업데이트 후에만 최신 데이터 가져오기
                self.callCheckUpdate { success in
                    guard success else { return } // 체크 업데이트 실패 시 종료
                    
                    self.fetchCalendarPolicyDetail() // 최신 데이터 가져오기
                    DispatchQueue.main.async {
                        self.currentState = .viewing
                        self.updateFirstView()
                    }
                }
            }
            
        default:
            break
        }
    }
    
    @objc private func didTapEditButton() {
        editingView.setDocuments(documentList)
        callCheckUpdate()
        currentState = .editing
        updateFirstView()
    }
    
    @objc private func didChangeValue(_ segment: UISegmentedControl) {
        updateFirstView()
    }
    
    private func configureSegmentControlAppearance() {
        segmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.gray300,
            NSAttributedString.Key.font: UIFont.ptdMediumFont(ofSize: 16)
        ], for: .normal)
        segmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.blue700,
            NSAttributedString.Key.font: UIFont.ptdSemiBoldFont(ofSize: 16)
        ], for: .selected)
        segmentedControl.selectedSegmentTintColor = .clear
        segmentedControl.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
        segmentedControl.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
    }
    
    @objc func changeSegmentedControlLinePosition(_ segment: UISegmentedControl) {
        let leadingDistance: CGFloat = CGFloat(segmentedControl.selectedSegmentIndex) * segmentedControl.frame.width / CGFloat(segmentedControl.numberOfSegments)
        
        UIView.animate(withDuration: 0.2, animations: {
            self.underLineView.snp.updateConstraints {
                $0.leading.equalToSuperview().offset(leadingDistance)
            }
            self.view.layoutIfNeeded()
        })
    }
    
    // MARK: - Data & API
    private func bindPolicyData(_ policy: Policy?) {
        guard let policy = policy else { return }
        calendarDetailView.update(policy: policy)
        secondView.update(policy: policy)
        
        if let userDocuments = policy.userDocuments, !userDocuments.isEmpty {
            updateDocumentList(userDocuments)
            currentState = .viewing
        } else {
            currentState = .empty
        }
    }
    
    private func fetchCalendarPolicyDetail() {
        policyNetwork.fetchCalendarPolicyDetail(cartId: cartId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                guard let documents = response?.documents,
                      let cartId = response?.cartId,
                      let policyId = response?.policyId else { return }
                
                self.cartId = cartId
                self.policyId = policyId
                policy?.documentText = response?.referenceDocuments ?? "서류 참고 내용 없음"
                policy?.userDocuments = documents.map {
                    Document(documentId: $0.documentId ?? 0,
                             name: $0.content ?? "이름 없음",
                             isChecked: $0.checked ?? false)
                }
                
                //문서 데이터 설정 후, 즉시 호출
                DispatchQueue.main.async {
                    self.updateDocumentList(self.policy?.userDocuments ?? [])
                    self.bindPolicyData(self.policy)
                    self.updateFirstView()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func updateCalendarDocumentsDetail(body: [UpdateDocuments], completion: @escaping () -> Void) {
        calendarNetwork.updateCalendarDocumentsDetail(cartId: cartId, body: body) { result in
            switch result {
            case .success:
                completion() // 성공하면 최종 업데이트 실행
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func postpostCalendarDocuments(documents: [String], completion: @escaping () -> Void) {
        let body = calendarNetwork.makePostDocumentsRequestDto(documents: documents)
        calendarNetwork.postpostCalendarDocuments(cartId: cartId, body: body) { result in
            switch result {
            case .success:
                completion() // 성공하면 최종 업데이트 실행
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func updateCalendarDocumentsCheck(body: [UpdateCheck]) {
        calendarNetwork.updateCalendarDocumentsCheck(cartId: cartId, body: body) { result in
            if case .failure(let error) = result { print(error) }
        }
    }
    
    private func callCheckUpdate(completion: ((Bool) -> Void)? = nil) {
        let updatedChecks = documentList.map {
            calendarNetwork.makeUpdateCheck(documentId: $0.documentId, checked: $0.isChecked)
        }

        calendarNetwork.updateCalendarDocumentsCheck(cartId: cartId, body: updatedChecks) { result in
            switch result {
            case .success:
                completion?(true)
            case .failure(let error):
                completion?(false)
            }
        }
    }
}

extension CalendarDetailViewController: AddingViewDelegate, EditingViewDelegate, NotEmptyViewDelegate {
    func didAddNewDocuments(_ documents: [Document]) {
        documentList.append(contentsOf: documents)
    }
    
    func didUpdateDocuments(_ documents: [Document]) {
        documentList = documents
    }
    
    func didDeleteDocument(at index: Int) {
        documentList.remove(at: index)
    }
}
