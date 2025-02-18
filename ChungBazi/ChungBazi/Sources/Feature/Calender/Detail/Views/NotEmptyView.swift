//
//  NotEmptyView.swift
//  ChungBazi
//
//  Created by 이현주 on 2/18/25.
//

import UIKit

protocol NotEmptyViewDelegate: AnyObject {
    func didUpdateDocuments(_ documents: [Document]) // 체크 상태 변경 시 호출
}

class NotEmptyView: UIView, DocumentListUpdatable {
    
    private var documentList: [Document] = []
    weak var delegate: NotEmptyViewDelegate?
    
    private let scrollView = UIScrollView()
        private let contentView = UIView()

    let addButton = CustomButton(backgroundColor: .blue100, titleText: "추가하기", titleColor: .black)
    
    let editButton = CustomButton(backgroundColor: .white, titleText: "수정하기", titleColor: .black, borderWidth: 1, borderColor: .gray400)
    
    private lazy var buttonStackView = UIStackView(arrangedSubviews: [addButton, editButton]).then {
        $0.axis = .horizontal
        $0.spacing = 10
        $0.distribution = .fillEqually
    }
    
    private let tableView = UITableView().then {
        $0.register(CalendarDetailDocumentListCell.self, forCellReuseIdentifier: "CalendarDetailDocumentListCell")
        $0.separatorColor = .gray100
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 64
        $0.isScrollEnabled = false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupUITableView()
        layoutIfNeeded()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubviews(buttonStackView, tableView)
        
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        buttonStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15)
            $0.horizontalEdges.equalToSuperview().inset(17)
            $0.centerX.equalToSuperview()
        }
        tableView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.top.equalTo(buttonStackView.snp.bottom).offset(5)
            $0.height.equalTo(0)
            $0.bottom.equalToSuperview().inset(20)
        }
    }
    
    private func setupUITableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func updateDocuments(with documents: [Document]) {
        self.documentList = documents
        tableView.reloadData()
        
        DispatchQueue.main.async {
            self.updateTableViewHeight()
        }
    }
    
    private func updateTableViewHeight() {
        let maxHeight: CGFloat = UIScreen.main.bounds.height
        let newHeight = min(tableView.contentSize.height, maxHeight)
        
        tableView.snp.updateConstraints {
            $0.height.equalTo(newHeight).priority(.required)
        }
        
        contentView.snp.remakeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
            $0.bottom.equalTo(tableView.snp.bottom).offset(20)
        }
        
        self.layoutIfNeeded()
    }
}

// MARK: - UITableViewDataSource
extension NotEmptyView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return documentList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarDetailDocumentListCell", for: indexPath) as! CalendarDetailDocumentListCell
        let document = documentList[indexPath.row]
        cell.configure(with: document)
        
        cell.onCheckChanged = { [weak self] isChecked in
            guard let self = self else { return }
            self.documentList[indexPath.row].isChecked = isChecked
            self.delegate?.didUpdateDocuments(self.documentList) // 즉시 업데이트
        }
        
        return cell
    }
}
