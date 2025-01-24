//
//  SearchResultViewController.swift
//  ChungBazi
//

import UIKit
import SnapKit

class SearchResultViewController: UIViewController {
    
    private let searchView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        return view
    }()

        private let hiddenTextField: UITextField = {
            let textField = UITextField()
            textField.isHidden = false
            textField.font = UIFont(name: AppFontName.pMedium, size: 16)
            textField.textColor = AppColor.gray800
            return textField
        }()
    
    private let searchPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.text = "검색어를 입력하세요"
        label.textColor = AppColor.gray300
        label.font = UIFont(name: AppFontName.pMedium, size: 16)
        return label
    }()

    private let searchIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "search_icon"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let popularSearchLabel: UILabel = {
        let label = UILabel()
        label.text = "인기 검색어"
        label.textColor = AppColor.gray800
        label.font = UIFont(name: AppFontName.pSemiBold, size: 20)
        return label
    }()

    private let popularKeywordsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 10
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.gray50
        addCustomNavigationBar(
            titleText: "",
            showBackButton: true,
            showCartButton: true,
            showAlarmButton: true,
            showHomeRecommendTabs: false,
            backgroundColor: .gray50
        )
        setupLayout()
        
        configureSearchViewTap()

    }

    private func setupLayout() {
        
        view.addSubview(searchView)
        searchView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(90)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(40)
        }
        searchView.addSubview(hiddenTextField)
                hiddenTextField.snp.makeConstraints { make in
                    make.edges.equalToSuperview().inset(UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 40))
                }
        

        searchView.addSubview(searchPlaceholderLabel)
        searchPlaceholderLabel.snp.makeConstraints { make in
            make.centerY.equalTo(searchView)
            make.leading.equalTo(searchView.snp.leading).offset(10)
        }
        searchView.addSubview(searchIcon)
        searchIcon.snp.makeConstraints { make in
            make.centerY.equalTo(searchView)
            make.trailing.equalTo(searchView.snp.trailing).offset(-16)
            make.width.height.equalTo(24)
        }
        

        view.addSubview(popularSearchLabel)
        popularSearchLabel.snp.makeConstraints { make in
            make.top.equalTo(searchView.snp.bottom).offset(32)
            make.leading.equalToSuperview().offset(16)
        }
    }
    private func configureSearchViewTap() {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapSearchView))
            searchView.addGestureRecognizer(tapGesture)

            hiddenTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        }

        @objc private func didTapSearchView() {
            hiddenTextField.becomeFirstResponder()
            searchPlaceholderLabel.isHidden = true
        }

        @objc private func textFieldDidChange() {
            searchPlaceholderLabel.isHidden = !(hiddenTextField.text?.isEmpty ?? true)
        }
  

}
