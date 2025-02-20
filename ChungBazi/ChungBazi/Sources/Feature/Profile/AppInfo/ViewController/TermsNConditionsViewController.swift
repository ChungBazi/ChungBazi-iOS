//
//  TermsNConditionsViewController.swift
//  ChungBazi
//
//  Created by 이현주 on 2/20/25.
//

import UIKit
import Then

class TermsNConditionsViewController: UIViewController {
    
    var titleName: String = ""
    
    private lazy var scrollView = UIScrollView()
    private lazy var contentView = UIView()
    
    private lazy var contents = UILabel().then {
        $0.font = UIFont.ptdMediumFont(ofSize: 14)
        $0.textColor = .gray800
        $0.numberOfLines = 0
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .gray50
        addCustomNavigationBar(titleText: titleName, showBackButton: true, showCartButton: false, showAlarmButton: false, backgroundColor: .white)
        fillSafeArea(position: .top, color: .white)
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(contents)
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(Constants.navigationHeight)
            $0.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView)
            $0.width.equalTo(scrollView.snp.width)
            $0.bottom.equalTo(contents.snp.bottom).offset(30)
        }
        
        contents.snp.makeConstraints {
            $0.top.equalToSuperview().offset(22)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().offset(-30)
        }
    }
    
    func changeContents(_ contents: String) {
        self.contents.text = contents
        self.contents.setLineSpacing()
    }

}
