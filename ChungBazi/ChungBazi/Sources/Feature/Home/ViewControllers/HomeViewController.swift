//
//  HomeViewController.swift
//  ChungBazi
//

import UIKit
import SnapKit

class HomeViewController: UIViewController {

    private let searchView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        return view
    }()

    private let searchIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "search_icon"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let policyIconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "homeicon"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let policyTextLabel: UILabel = {
        let label = UILabel()
        label.text = "정책도 쉽고 간편하게\n청바지"
        label.numberOfLines = 2
        label.font = UIFont(name: AppFontName.pSemiBold, size: 20)
        label.textAlignment = .right
        label.textColor = .black
        let attributedText = NSMutableAttributedString(string: label.text ?? "")
        attributedText.addAttribute(.foregroundColor, value: AppColor.blue700, range: (label.text! as NSString).range(of: "청바지"))
        label.attributedText = attributedText
        return label
    }()

    private let banner = BannerView()

    private let chatbotImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "chatbot"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let categories: [CategoryItem] = [
        CategoryItem(title: "일자리", iconName: "policy_job_icon", policies: []),
        CategoryItem(title: "주거", iconName: "policy_housing_icon", policies: []),
        CategoryItem(title: "교육", iconName: "policy_education_icon", policies: []),
        CategoryItem(title: "복지,문화", iconName: "policy_welfare_culture_icon", policies: []),
        CategoryItem(title: "참여,권리", iconName: "policy_participation_icon", policies: [])
    ]
 
    private let categoriesGridStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.gray50
        
        addCustomNavigationBar(
                titleText: "",
                showBackButton: false,
                showCartButton: true,
                showAlarmButton: true,
                showHomeRecommendTabs: true,
                activeTab: 0,
                backgroundColor: .gray50
            )
        setupLayout()
        configureCategoriesWithChatbot()
        configureSearchViewTap()
    }

    private func setupLayout() {
        view.addSubview(searchView)
        searchView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(80)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(40)
        }

        searchView.addSubview(searchIcon)
        searchIcon.snp.makeConstraints { make in
            make.centerY.equalTo(searchView)
            make.trailing.equalTo(searchView.snp.trailing).offset(-16)
            make.width.height.equalTo(24)
        }

        view.addSubview(policyIconImageView)
        view.addSubview(policyTextLabel)
        policyIconImageView.snp.makeConstraints { make in
            make.top.equalTo(searchView.snp.bottom).offset(14)
            make.leading.equalToSuperview().offset(25)
            make.width.height.equalTo(159)
        }
        policyIconImageView.layer.shadowColor = UIColor.black.cgColor
        policyIconImageView.layer.shadowOpacity = 0.25
        policyIconImageView.layer.shadowOffset = CGSize(width: 0, height: 4)
        policyIconImageView.layer.shadowRadius = 4
        policyIconImageView.layer.masksToBounds = false
        policyTextLabel.snp.makeConstraints { make in
            make.centerY.equalTo(policyIconImageView)
            make.trailing.equalToSuperview().offset(-30)
            make.width.equalTo(166)
            make.height.equalTo(56)
        }

        view.addSubview(banner)
        banner.snp.makeConstraints { make in
            make.top.equalTo(policyIconImageView.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(110)
        }

        view.addSubview(categoriesGridStackView)
        categoriesGridStackView.snp.makeConstraints { make in
            make.top.equalTo(banner.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }

    private func configureCategoriesWithChatbot() {
        let firstRowStackView = UIStackView()
        firstRowStackView.axis = .horizontal
        firstRowStackView.spacing = 10
        firstRowStackView.alignment = .fill
        firstRowStackView.distribution = .fillEqually
        categoriesGridStackView.addArrangedSubview(firstRowStackView)

        let secondRowStackView = UIStackView()
        secondRowStackView.axis = .horizontal
        secondRowStackView.spacing = 14
        secondRowStackView.alignment = .fill
        secondRowStackView.distribution = .fillEqually
        categoriesGridStackView.addArrangedSubview(secondRowStackView)

        for (index, category) in categories.enumerated() {
            let button = CategoryButton()
            button.iconImageView.image = UIImage(named: category.iconName)
            button.customTitleLabel.text = category.title
            button.tag = index
            button.addTarget(self, action: #selector(categoryButtonTapped(_:)), for: .touchUpInside)
                
            if index < 3 {
                firstRowStackView.addArrangedSubview(button)
            } else {
                secondRowStackView.addArrangedSubview(button)
            }

            button.snp.makeConstraints { make in
                make.width.height.equalTo(105)
            }
        }
        categoriesGridStackView.setCustomSpacing(10, after: firstRowStackView)

        let chatbotButtonContainer = UIView()

        chatbotButtonContainer.snp.makeConstraints { make in
            make.width.height.equalTo(105)
        }

        let chatbotButton = UIView()
        chatbotButton.backgroundColor = AppColor.green300
        chatbotButton.layer.cornerRadius = 39
        chatbotButton.layer.shadowColor = UIColor.black.cgColor
        chatbotButton.layer.shadowOpacity = 0.15
        chatbotButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        chatbotButton.layer.shadowRadius = 10
        chatbotButtonContainer.addSubview(chatbotButton)
        
        chatbotButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-4)
            make.trailing.equalToSuperview().offset(-8)
            make.width.height.equalTo(78)
        }

        let chatbotIcon = UIImageView(image: UIImage(named: "chatbot"))
        chatbotIcon.contentMode = .scaleAspectFit
        chatbotButton.addSubview(chatbotIcon)

        chatbotIcon.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(73)
        }
        secondRowStackView.addArrangedSubview(chatbotButtonContainer)
    }
    
    private func configureSearchViewTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapSearchView))
        searchView.addGestureRecognizer(tapGesture)
    }

    @objc private func didTapSearchView() {
        let searchResultVC = SearchResultViewController()
        navigationController?.pushViewController(searchResultVC, animated: true)
    }
    
    @objc private func categoryButtonTapped(_ sender: UIButton) {
        guard let categoryPolicy = PolicyData.getPolicies(for: categories[sender.tag].title) else { return }
        
        let categoryVC = CategoryPolicyViewController()
        categoryVC.configure(categoryTitle: categoryPolicy.title, policies: categoryPolicy.policies)
        navigationController?.pushViewController(categoryVC, animated: true)
    }
}
