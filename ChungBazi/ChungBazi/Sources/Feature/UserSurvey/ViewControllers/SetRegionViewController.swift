//
//  SetRegionViewController.swift
//  ChungBazi
//

import UIKit
import Then

class SetRegionViewController: UIViewController {
    
    private let firstSlotItems = Constants.regionSiMenu
    private let secondSlotItems = Constants.regionGuMenu
    private var selectedFirstSlot: String?
    private var selectedSecondSlot: String?
    
    private lazy var baseSurveyView = BasicSurveyView(title: "정책 확인을 원하는 지역을\n선택해주세요", logo: "fifthPageLogo").then {
        $0.backBtn.addTarget(self, action: #selector(goToback), for: .touchUpInside)
        $0.nextBtn.addTarget(self, action: #selector(goToSetPlus), for: .touchUpInside)
    }
    
    private lazy var regionPickerView = UIPickerView().then {
        $0.delegate = self
        $0.dataSource = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        addComoponents()
        setConstraints()
    }
    
    private func addComoponents() {
        view.addSubview(baseSurveyView)
        baseSurveyView.addSubview(regionPickerView)
    }
    
    private func setConstraints() {
        baseSurveyView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        regionPickerView.snp.makeConstraints {
            $0.top.equalTo(baseSurveyView.title.snp.bottom).offset(48)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(60)
            $0.height.equalTo(200)
        }
    }
    
    private func updateNextButtonState() {
        let isEnabled = selectedSecondSlot != nil
        baseSurveyView.nextBtn.setEnabled(isEnabled: isEnabled)
    }
    
    @objc private func goToback() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func goToSetPlus() {
        let vc = SetInterestViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension SetRegionViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return firstSlotItems.count
        } else {
            return secondSlotItems.count
        }
    }
    
    // 피커 뷰 행의 높이
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return firstSlotItems[row]
        } else {
            return secondSlotItems[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            selectedFirstSlot = firstSlotItems[row]
        } else {
            selectedSecondSlot = secondSlotItems[row]
        }
        updateNextButtonState()
    }
}
