//
//  CalendarDetailDocumentListView.swift
//  ChungBazi
//
//  Created by 신호연 on 1/21/25.
//

import UIKit
import SnapKit
import Then

final class CalendarDetailDocumentListView: UIView {
    
    private let addButton = CustomButton(backgroundColor: .white, titleText: "수정하기", titleColor: .black, borderWidth: 1, borderColor: .gray400)
    private let tableView = UITableView().then {
        $0.register(CalendarDetailDocumentListCell.self, forCellReuseIdentifier: "CalendarDetailDocumentListCell")
        $0.separatorColor = .gray100
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 64
    }
    private let plusCircleButton = UIButton.createWithImage(image: UIImage(named: "plusCircle")?.withRenderingMode(.alwaysOriginal)).then {
        $0.isHidden = true
    }
    
    private var documentList: [Document] = []
    private var isEditingMode = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupUITableView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubviews(tableView, plusCircleButton, addButton)
        addButton.addTarget(self, action: #selector(tabAddButton), for: .touchUpInside)
        tableView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        plusCircleButton.snp.makeConstraints {
            $0.top.equalTo(tableView.snp.bottom).offset(14)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(46)
        }
        addButton.snp.remakeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(20)
            $0.width.equalTo(118)
            $0.height.equalTo(40)
        }
    }
    
    private func setupUITableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func updateDocuments(documents: [Document]) {
        self.documentList = documents
        tableView.reloadData()
        
        DispatchQueue.main.async {
            self.tableView.snp.updateConstraints {
                $0.height.equalTo(self.tableView.contentSize.height).priority(.required)
            }

            if !self.documentList.isEmpty {
                self.addButton.snp.remakeConstraints {
                    $0.top.equalTo(self.tableView.snp.bottom).offset(20)
                    $0.centerX.equalToSuperview()
                    $0.bottom.equalToSuperview().inset(20)
                    $0.width.equalTo(118)
                    $0.height.equalTo(40)
                }
            } else {
                self.addButton.snp.remakeConstraints {
                    $0.top.equalToSuperview().offset(20)
                    $0.centerX.equalToSuperview()
                    $0.bottom.equalToSuperview().inset(20)
                    $0.width.equalTo(118)
                    $0.height.equalTo(40)
                }
            }
            
            self.layoutIfNeeded()
        }
    }
    
    @objc private func tabAddButton() {
        isEditingMode.toggle()
        
        if isEditingMode {
            addButton.backgroundColor = .blue700
            addButton.setTitle("저장하기", for: .normal)
            addButton.setTitleColor(.white, for: .normal)
            addButton.layer.borderWidth = 0
            
            plusCircleButton.isHidden = false
            
            if documentList.isEmpty {
                addNewDocumentCell()
            }
            
            plusCircleButton.snp.remakeConstraints {
                $0.top.equalTo(tableView.snp.bottom).offset(14)
                $0.centerX.equalToSuperview()
                $0.size.equalTo(46)
            }
            
        } else {
            addButton.backgroundColor = .white
            addButton.setTitle("수정하기", for: .normal)
            addButton.setTitleColor(.black, for: .normal)
            addButton.layer.borderWidth = 1
            addButton.layer.borderColor = UIColor.gray400.cgColor
            plusCircleButton.isHidden = true
            
            addButton.snp.remakeConstraints {
                $0.top.equalToSuperview().offset(20)
                $0.centerX.equalToSuperview()
                $0.bottom.equalToSuperview().inset(20)
                $0.width.equalTo(118)
                $0.height.equalTo(40)
            }
        }
    }
    
    @objc private func addNewDocumentCell() {
        let newDocument = Document(documentId: -1, name: "", isChecked: false)
        documentList.append(newDocument)
        tableView.reloadData()
        
        addButton.snp.remakeConstraints {
            $0.top.equalTo(plusCircleButton.snp.bottom).offset(14)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(20)
            $0.width.equalTo(118)
            $0.height.equalTo(40)
        }
    }
}

// MARK: - UITableViewDataSource
extension CalendarDetailDocumentListView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return documentList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarDetailDocumentListCell", for: indexPath) as! CalendarDetailDocumentListCell
        let document = documentList[indexPath.row]
        cell.configure(with: document)
        return cell
    }
}
