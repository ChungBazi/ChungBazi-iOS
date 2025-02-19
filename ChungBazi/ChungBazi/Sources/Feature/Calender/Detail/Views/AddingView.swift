//
//  AddingView.swift
//  ChungBazi
//
//  Created by 이현주 on 2/18/25.
//

import UIKit

protocol AddingViewDelegate: AnyObject {
    func didAddNewDocuments(_ documents: [Document])
}

class AddingView: UIView {
    
    private var documentList: [Document] = []
    weak var delegate: AddingViewDelegate?
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    let saveButton = CustomButton(backgroundColor: .blue700, titleText: "저장하기", titleColor: .white)
    private let tableView = UITableView().then {
        $0.register(CalendarDetailDocumentListCell.self, forCellReuseIdentifier: "CalendarDetailDocumentListCell")
        $0.separatorColor = .gray100
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 64
        $0.isScrollEnabled = false
    }
    private let plusCircleButton = UIButton.createWithImage(image: UIImage(named: "plusCircle")?.withRenderingMode(.alwaysOriginal))
    
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
        contentView.addSubviews(tableView, plusCircleButton, saveButton)
        
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
            $0.bottom.equalTo(saveButton.snp.bottom).offset(20)
        }
        
        tableView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(0) // 처음에는 높이 0
        }
        
        plusCircleButton.snp.makeConstraints {
            $0.top.equalTo(tableView.snp.bottom).offset(14)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(46)
        }
        
        saveButton.snp.makeConstraints {
            $0.top.equalTo(plusCircleButton.snp.bottom).offset(14)
            $0.horizontalEdges.equalToSuperview().inset(105)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    private func setupUITableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupActions() {
        plusCircleButton.addTarget(self, action: #selector(addNewDocumentCell), for: .touchUpInside)
    }
    
    @objc private func addNewDocumentCell() {
        let newDocument = Document(documentId: 0, name: "", isChecked: false)
        documentList.append(newDocument)
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
        
        plusCircleButton.snp.remakeConstraints {
            $0.top.equalTo(tableView.snp.bottom).offset(14)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(46)
        }
        
        saveButton.snp.remakeConstraints {
            $0.top.equalTo(plusCircleButton.snp.bottom).offset(14)
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
    
    func getDocumentContents() -> [String] {
        return documentList
            .compactMap { $0.name.isEmpty ? nil : $0.name } // 빈 값은 제외
    }
    
    @objc private func saveDocuments() {
        delegate?.didAddNewDocuments(documentList)
    }
    
    func resetDocuments() {
        documentList = []
        tableView.reloadData()
        updateTableViewHeight()
    }
}

// MARK: - UITableViewDataSource
extension AddingView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return documentList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarDetailDocumentListCell", for: indexPath) as! CalendarDetailDocumentListCell
        let document = documentList[indexPath.row]
        cell.textFieldUIEnabled()
        cell.unTapCheckButton()
        cell.configure(with: document)
        
        cell.onTextChanged = { [weak self] text in
            guard let self = self else { return }
            self.documentList[indexPath.row].name = text
        }
        
        return cell
    }
}

