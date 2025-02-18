//
//  EditingView.swift
//  ChungBazi
//
//  Created by 이현주 on 2/18/25.
//

import UIKit

class EditingView: UIView {
    
    private var documentList: [Document] = []
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    let networkService = CalendarService()
    
    private let tableView = UITableView().then {
        $0.register(CalendarDetailDocumentListCell.self, forCellReuseIdentifier: "CalendarDetailDocumentListCell")
        $0.separatorColor = .gray100
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 64
        $0.isScrollEnabled = false
    }

    let saveButton = CustomButton(backgroundColor: .blue700, titleText: "저장하기", titleColor: .white)
    
    init(documentList: [Document]) {
        super.init(frame: .zero)
        self.documentList = documentList
        setupUI()
        setupUITableView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubviews(tableView, saveButton)
        
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        tableView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(0)
        }
        saveButton.snp.makeConstraints {
            $0.top.equalTo(tableView.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(105)
            $0.centerX.equalToSuperview()
        }
    }
    
    func updateDocuments(documents: [Document]) {
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
        
        saveButton.snp.makeConstraints {
            $0.top.equalTo(tableView.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(105)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(48)
        }
        
        contentView.snp.remakeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
            $0.bottom.equalTo(saveButton.snp.bottom).offset(20)
        }
        
        self.layoutIfNeeded()
    }
    
    private func setupUITableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    //수정된 서류 업데이트 시,
    func getUpdatedDocuments() -> [UpdateDocuments] {
        return documentList
            .filter { !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty } // 빈 값 제거
            .map { networkService.makeUpdateDocuments(documentId: $0.documentId, content: $0.name) }
    }
}

// MARK: - UITableViewDataSource
extension EditingView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return documentList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarDetailDocumentListCell", for: indexPath) as! CalendarDetailDocumentListCell
        let document = documentList[indexPath.row]
        cell.textFieldUIEnabled()
        cell.configure(with: document)
        return cell
    }
}
