//
//  CalendarDetailViewController.swift
//  ChungBazi
//
//  Created by 신호연 on 1/20/25.
//

import UIKit
import SnapKit

final class CalendarDetailViewController: UIViewController {
    
    // MARK: - Properties
    private let calendarDetailView = CalendarDetailView()
    private var policy: Policy?
    
    private let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["서류 리스트", "서류 참고 내용"])
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private let secondView = CalendarDetailDocumentReferenceView()
    private let underLineView = UIView().then {
        $0.backgroundColor = .blue700
    }
    
    private var emptyView = EmptyView()
    private var notEmptyView = NotEmptyView()
    private var addingView = AddingView()
    private var editingView = EditingView()
    
    private var currentState: ViewState = .empty {
            didSet { updateFirstView() }
        }
    
    // MARK: - Lifecycle
    init(policy: Policy) {
        self.policy = policy
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        contentView.addSubviews(segmentedControl, underLineView, emptyView, notEmptyView, addingView, editingView, secondView)
//        firstView.snp.makeConstraints {
//            $0.top.equalTo(segmentedControl.snp.bottom).offset(1)
//            $0.leading.trailing.equalToSuperview()
//        }
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
        underLineView.snp.makeConstraints {
            $0.top.equalTo(segmentedControl.snp.bottom)
            $0.height.equalTo(1)
            $0.width.equalToSuperview().dividedBy(2)
            $0.leading.equalToSuperview()
        }
        configureSegmentControlAppearance()
        updateFirstView()
        
//        firstView.isHidden = false
        secondView.isHidden = true
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
    
//    private var shouldHideFirstView: Bool? {
//        didSet {
//            guard let shouldHideFirstView = self.shouldHideFirstView else { return }
//            self.emptyView.isHidden = shouldHideFirstView
//            self.notEmptyView.isHidden = shouldHideFirstView
//            self.addingView.isHidden = shouldHideFirstView
//            self.editingView.isHidden = shouldHideFirstView
//            self.secondView.isHidden = !self.emptyView.isHidden
//        }
//    }
    
    @objc private func didTapAddButton() {
        currentState = .adding
        updateFirstView()
    }
    
    @objc private func didTapSaveButton() {
        currentState = .viewing
        updateFirstView()
    }
    
    @objc private func didTapEditButton() {
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
    
    // MARK: - Data
    private func bindPolicyData(_ policy: Policy?) {
        guard let policy = policy else { return }
        calendarDetailView.update(policy: policy)
        secondView.update(policy: policy)
        
        if let userDocuments = policy.userDocuments, !userDocuments.isEmpty {
            notEmptyView.updateDocuments(documents: userDocuments)
            currentState = .viewing
        } else {
            currentState = .empty
        }
    }
}
