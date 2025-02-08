//
//  CalendarDetailViewController.swift
//  ChungBazi
//
//  Created by 신호연 on 1/20/25.
//

import UIKit
import SnapKit
import SafeAreaBrush

final class CalendarDetailViewController: UIViewController {
    
    // MARK: - Properties
    private let calendarDetailView = CalendarDetailView()
    private var policy: Policy?
    
    private let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["서류 리스트", "서류 참고 내용"])
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    private let firstView = CalendarDetailDocumentListView()
    private let secondView = CalendarDetailDocumentReferenceView()
    private let underLineView = UIView().then {
        $0.backgroundColor = .blue700
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
        if let policy = policy {
            bindPolicyData(policy)
        }
        
        self.segmentedControl.addTarget(self, action: #selector(didChangeValue(segment:)), for: .valueChanged)
        
        self.segmentedControl.selectedSegmentIndex = 0
        self.didChangeValue(segment: self.segmentedControl)
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
        segmentedControl.addTarget(self, action: #selector(changeSegmentedControlLinePosition(_:)), for: .valueChanged)
        segmentedControl.addTarget(self, action: #selector(didChangeValue(_:)), for: .valueChanged)
    }
    
    private func setupCalendarDetailView() {
        view.addSubview(calendarDetailView)
        calendarDetailView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        let contentView = calendarDetailView.accessibleContentView
        
        contentView.addSubviews(segmentedControl, underLineView, firstView, secondView)
        firstView.snp.makeConstraints {
            $0.top.equalTo(segmentedControl.snp.bottom).offset(1)
            $0.leading.trailing.equalToSuperview()
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
        
        firstView.isHidden = false
        secondView.isHidden = true
    }
    
    private var shouldHideFirstView: Bool? {
        didSet {
            guard let shouldHideFirstView = self.shouldHideFirstView else { return }
            self.firstView.isHidden = shouldHideFirstView
            self.secondView.isHidden = !self.firstView.isHidden
        }
    }
    
    @objc private func didChangeValue(segment: UISegmentedControl) {
        self.shouldHideFirstView = segment.selectedSegmentIndex != 0
    }
    
    private func configureSegmentControlAppearance() {
        segmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.gray300,
            NSAttributedString.Key.font: UIFont.ptdMediumFont(ofSize: 16)
        ], for: .normal)
        segmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.black,
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
    
    @objc private func didChangeValue(_ segment: UISegmentedControl) {
        switch segment.selectedSegmentIndex {
        case 0:
            firstView.isHidden = false
            secondView.isHidden = true
        case 1:
            firstView.isHidden = true
            secondView.isHidden = false
        default:
            break
        }
    }
    
    // MARK: - Data
    private func bindPolicyData(_ policy: Policy?) {
        guard let policy = policy else { return }
        calendarDetailView.update(policy: policy)
        secondView.update(policy: policy)
        
        if let userDocuments = policy.userDocuments, !userDocuments.isEmpty {
            firstView.updateDocuments(documents: userDocuments)
        } else { return }
    }
}
