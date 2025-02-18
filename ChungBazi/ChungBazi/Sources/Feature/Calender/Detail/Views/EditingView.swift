//
//  EditingView.swift
//  ChungBazi
//
//  Created by 이현주 on 2/18/25.
//

import UIKit

protocol EditingViewDelegate: AnyObject {
    func didUpdateDocuments(_ documents: [Document])  // 문서 수정 후 업데이트
    func didDeleteDocument(at index: Int)             // 문서 삭제
}

class EditingView: UIView, DocumentListUpdatable {
    
    private var documentList: [Document] = []
    weak var delegate: EditingViewDelegate?
    
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupUITableView()
        setupActions()
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
    
    func updateDocuments(with documents: [Document]) {
        self.documentList = documents
        tableView.reloadData()
        
        DispatchQueue.main.async {
            self.updateTableViewHeight()
            // 전체 리로드 대신 변경된 부분만 갱신
            for (index, document) in documents.enumerated() {
                if let cell = self.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? CalendarDetailDocumentListCell {
                    cell.configure(with: document)
                }
            }
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
    
    func getUpdatedDocuments() -> [UpdateDocuments] {
        return documentList
            .filter { !$0.name.isEmpty } // 빈 값 제거
            .map { UpdateDocuments(documentId: $0.documentId, content: $0.name) }
    }
    
    private func setupActions() {
        saveButton.addTarget(self, action: #selector(saveDocuments), for: .touchUpInside)
    }
    
    @objc private func saveDocuments() {
        delegate?.didUpdateDocuments(documentList)
    }
    
    func setDocuments(_ documents: [Document]) {
        self.documentList = documents
        tableView.reloadData()
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
        
        cell.onTextChanged = { [weak self] text in
            guard let self = self else { return }
            self.documentList[indexPath.row].name = text
        }
        
        cell.onCheckChanged = { [weak self] isChecked in
            guard let self = self else { return }
            self.documentList[indexPath.row].isChecked = isChecked
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            documentList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            delegate?.didDeleteDocument(at: indexPath.row)
        }
    }
}

extension EditingView: CalendarDetailDocumentListCellDelegate {
    func didUpdateText(for cell: CalendarDetailDocumentListCell, newText: String) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        documentList[indexPath.row].name = newText
    }
}
