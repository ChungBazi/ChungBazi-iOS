//
//  HomeViewController.swift
//  ChungBazi
//

import UIKit
import SnapKit
import Then

final class HomeViewController: UIViewController {

    private let searchView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
    }

    private let searchIcon = UIImageView(image: UIImage(named: "search_icon")).then {
        $0.contentMode = .scaleAspectFit
    }

    private let policyIconImageView = UIImageView(image: UIImage(named: "homeicon")).then {
        $0.contentMode = .scaleAspectFit
    }

    private let policyTextLabel = UILabel().then {
        let text = "정책도 쉽고 간편하게\n청바지"
        let attributedText = NSMutableAttributedString(string: text)
        
        let firstPartRange = (text as NSString).range(of: "정책도 쉽고 간편하게")
        let secondPartRange = (text as NSString).range(of: "청바지")

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        
        attributedText.addAttribute(.font, value: UIFont.ptdSemiBoldFont(ofSize: 20), range: firstPartRange)
        attributedText.addAttribute(.foregroundColor, value: UIColor.black, range: firstPartRange)
        attributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: firstPartRange)

        attributedText.addAttribute(.font, value: UIFont.afgRegularFont(ofSize: 20), range: secondPartRange)
        attributedText.addAttribute(.foregroundColor, value: AppColor.blue700, range: secondPartRange)
        
        $0.numberOfLines = 2
        $0.textAlignment = .right
        $0.attributedText = attributedText
    }

    private let banner = BannerView()

    private let categoriesGridStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 14
        $0.alignment = .fill
    }

    private let categories: [CategoryItem] = [
        CategoryItem(title: "일자리", iconName: "policy_job_icon", policies: []),
        CategoryItem(title: "주거", iconName: "policy_housing_icon", policies: []),
        CategoryItem(title: "교육", iconName: "policy_education_icon", policies: []),
        CategoryItem(title: "복지,문화", iconName: "policy_welfare_culture_icon", policies: []),
        CategoryItem(title: "참여,권리", iconName: "policy_participation_icon", policies: [])
    ]

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
        let screenHeight = UIScreen.main.bounds.height
        let dynamicSpacing = screenHeight * 0.02
        
        view.addSubviews(searchView, policyIconImageView, policyTextLabel, banner, categoriesGridStackView)
        
        searchView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(dynamicSpacing * 5)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(40)
        }

        searchView.addSubview(searchIcon)
        searchIcon.snp.makeConstraints { make in
            make.centerY.equalTo(searchView)
            make.trailing.equalTo(searchView.snp.trailing).offset(-16)
            make.width.height.equalTo(24)
        }

        policyIconImageView.snp.makeConstraints { make in
            make.top.equalTo(searchView.snp.bottom).offset(dynamicSpacing)
            make.leading.equalToSuperview().offset(25)
            make.width.height.equalTo(159)
        }
        
        policyIconImageView.layer.do {
            $0.shadowColor = UIColor.black.cgColor
            $0.shadowOpacity = 0.25
            $0.shadowOffset = CGSize(width: 0, height: 4)
            $0.shadowRadius = 4
            $0.masksToBounds = false
        }
        
        policyTextLabel.snp.makeConstraints { make in
            make.centerY.equalTo(policyIconImageView)
            make.trailing.equalToSuperview().inset(25)
            make.width.equalTo(166)
        }

        banner.snp.makeConstraints { make in
            make.top.equalTo(policyIconImageView.snp.bottom).offset(dynamicSpacing * 0.6)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(110)
        }

        categoriesGridStackView.snp.makeConstraints { make in
            make.top.equalTo(banner.snp.bottom).offset(dynamicSpacing)
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }

    private func configureCategoriesWithChatbot() {
        let buttonSize = UIScreen.main.bounds.width * 0.28
        let chatbotSize = buttonSize * 0.8
        let chatbotIconSize = chatbotSize * 0.93
        
        let firstRowStackView = UIStackView().then {
            $0.axis = .horizontal
            $0.spacing = 14
            $0.alignment = .fill
            $0.distribution = .fillEqually
        }
        categoriesGridStackView.addArrangedSubview(firstRowStackView)

        let secondRowStackView = UIStackView().then {
            $0.axis = .horizontal
            $0.spacing = 14
            $0.alignment = .fill
            $0.distribution = .fillEqually
        }
        categoriesGridStackView.addArrangedSubview(secondRowStackView)

        for (index, category) in categories.enumerated() {
            let button = CategoryButton().then {
                $0.iconImageView.image = UIImage(named: category.iconName)
                $0.customTitleLabel.text = category.title
                $0.tag = index
                $0.addTarget(self, action: #selector(categoryButtonTapped(_:)), for: .touchUpInside)
            }
            button.snp.makeConstraints { make in
                make.width.height.equalTo(buttonSize)
            }
            button.iconImageView.snp.makeConstraints { make in
                make.width.height.equalTo(buttonSize * 0.5)
            }
            if index < 3 {
                firstRowStackView.addArrangedSubview(button)
            } else {
                secondRowStackView.addArrangedSubview(button)
            }
        }
        categoriesGridStackView.setCustomSpacing(14, after: firstRowStackView)
        
        let chatbotButtonContainer = UIView().then {
            $0.snp.makeConstraints { make in
                make.width.height.equalTo(buttonSize)
            }
        }
        
        let chatbotButton = UIView().then {
            $0.backgroundColor = AppColor.green300
            $0.layer.cornerRadius = chatbotSize / 2
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOpacity = 0.15
            $0.layer.shadowOffset = CGSize(width: 0, height: chatbotSize * 0.05)
            $0.layer.shadowRadius = chatbotSize * 0.15
        }
        chatbotButtonContainer.addSubview(chatbotButton)
        
        chatbotButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-1)
            make.trailing.equalToSuperview().offset(-3)
            make.width.height.equalTo(chatbotSize)
        }
        let chatbotIcon = UIImageView(image: UIImage(named: "chatbot")).then {
            $0.contentMode = .scaleAspectFit
        }
        chatbotButton.addSubview(chatbotIcon)

        chatbotIcon.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-4)
            make.trailing.equalToSuperview().offset(-1)
            make.width.height.equalTo(chatbotIconSize)
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
    
    private let categoryMapping: [String: String] = [
        "일자리": "JOBS",
        "주거": "HOUSING",
        "교육": "EDUCATION",
        "복지,문화": "WELFARE_CULTURE",
        "참여,권리": "PARTICIPATION_RIGHTS"
    ]
    
    @objc private func categoryButtonTapped(_ sender: UIButton) {
        let categoryTitle = categories[sender.tag].title
        guard let categoryKey = categoryMapping[categoryTitle] else {
            print("⚠️ 지원되지 않는 카테고리: \(categoryTitle)")
            return
        }
        let categoryVC = CategoryPolicyViewController()
        categoryVC.configure(categoryTitle: categoryTitle)
        categoryVC.fetchCategoryPolicy(category: categoryKey, cursor: 0)
        navigationController?.pushViewController(categoryVC, animated: true)
    }
}
