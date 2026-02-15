//
//  EmailVerificationCodeViewController.swift
//  ChungBazi
//
//  Created by 엄민서 on 8/28/25.
//

import UIKit
import SnapKit
import Then

final class EmailVerificationCodeViewController: UIViewController {
    
    private let registerInfo: RegisterRequestDto
    private let emailService = EmailService()
    private let authService = AuthService.shared
    
    private let descriptionLabel = UILabel().then {
        $0.text = "회원님의 이메일로\n코드를 전송했어요!"
        $0.numberOfLines = 2
        $0.font = UIFont.ptdSemiBoldFont(ofSize: 20)
        $0.textColor = .black
    }
    
    // MARK: - 이메일 그룹
    private let codeLabel = UILabel().then {
        $0.text = "코드 입력"
        $0.font = UIFont.ptdMediumFont(ofSize: 14)
        $0.textColor = .gray500
    }

    private let codeRow = UIView()

    private let codeTextField = UITextField().then {
        $0.placeholder = "코드를 입력하세요."
        $0.font = UIFont.ptdMediumFont(ofSize: 16)
        $0.textColor = .black
        $0.keyboardType = .numberPad
        $0.autocapitalizationType = .none
        $0.autocorrectionType = .no
        $0.attributedPlaceholder = NSAttributedString(
            string: "코드를 입력하세요.",
            attributes: [.foregroundColor: UIColor.gray300]
        )
        $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }

    private let timerLabel = UILabel().then {
        $0.text = "3:00초 남음"
        $0.font = UIFont.ptdRegularFont(ofSize: 16)
        $0.textColor = .gray800
        $0.textAlignment = .right
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    private let codeUnderline = UIView().then {
        $0.backgroundColor = .gray500
    }

    private let resendActionButton = UIButton(type: .system).then {
        let image = UIImage(resource: .resendbutton)
        $0.setImage(image, for: .normal)
        $0.contentHorizontalAlignment = .leading

        let title = "재전송하기"
        let attr = NSAttributedString(
            string: title,
            attributes: [
                .font: UIFont.ptdMediumFont(ofSize: 14),
                .foregroundColor: UIColor.gray500
            ]
        )
        $0.setAttributedTitle(attr, for: .normal)

        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.plain()
            config.contentInsets = .zero
            config.imagePadding = 6
            $0.configuration = config
        } else {
            $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 0)
            $0.contentEdgeInsets = .zero
        }
        $0.tintColor = .blue
        $0.isUserInteractionEnabled = true
        $0.alpha = 1.0
        $0.accessibilityLabel = "재전송하기"
    }

    private let verifyButton = CustomActiveButton(
        title: "다음으로",
        isEnabled: false
    )

    private var countdownTimer: Timer?
    private var remainingSeconds: Int = 180

    // MARK: - Init
    init(registerInfo: RegisterRequestDto) {
        self.registerInfo = registerInfo
        super.init(nibName: nil, bundle: nil)
    }
    @available(*, unavailable) required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    deinit { countdownTimer?.invalidate() }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addCustomNavigationBar(titleText: "이메일 인증", showBackButton: true)
        setupViews()
        setupActions()
        hideKeyboardWhenTappedAround()
        
        requestEmailVerification()
    }

    private func setupViews() {
        view.addSubview(descriptionLabel)
        view.addSubview(codeLabel)
        view.addSubview(codeRow)
        codeRow.addSubview(codeTextField)
        codeRow.addSubview(timerLabel)
        view.addSubview(codeUnderline)
        view.addSubview(resendActionButton)
        view.addSubview(verifyButton)

        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(86)
            $0.leading.trailing.equalToSuperview().inset(45)
        }

        codeLabel.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(143)
            $0.leading.equalToSuperview().offset(45)
        }

        codeRow.snp.makeConstraints {
            $0.top.equalTo(codeLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(45)
            $0.height.equalTo(27)
        }

        timerLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview()
        }

        codeTextField.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(timerLabel.snp.leading).offset(-8)
            $0.height.equalTo(27)
        }

        codeUnderline.snp.remakeConstraints {
            $0.top.equalTo(codeRow.snp.bottom).offset(4)
            $0.leading.equalTo(codeRow.snp.leading)
            $0.trailing.equalTo(codeRow.snp.trailing)
            $0.height.equalTo(1)
        }

        resendActionButton.snp.makeConstraints {
            $0.top.equalTo(codeUnderline.snp.bottom).offset(8)
            $0.leading.equalTo(codeTextField)
        }

        verifyButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(48)
        }
    }

    private func setupActions() {
        verifyButton.addTarget(self, action: #selector(verifyCodeTapped), for: .touchUpInside)
        resendActionButton.addTarget(self, action: #selector(resendTapped), for: .touchUpInside)
        codeTextField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
    }
    
    @objc private func textFieldEditingChanged() {
        let raw = codeTextField.text ?? ""
        let trimmed = raw.replacingOccurrences(of: "\\s", with: "", options: .regularExpression)
        let digits  = trimmed.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        if raw != digits { codeTextField.text = digits }

        verifyButton.setEnabled(isEnabled: !digits.isEmpty) // ← 배경/텍스트 컬러 자동 통일
    }

    
    @objc private func resendTapped() {
        requestEmailVerification()
    }

    private func requestEmailVerification() {
        emailService.requestEmailVerificationNoAuth(email: registerInfo.email) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                self.startCountdown(from: 180)
                self.codeTextField.becomeFirstResponder()
            case .failure(let error):
                self.showCustomAlert(title: "이메일 인증 요청에 실패하였습니다. \n다시 시도해 주세요.", buttonText: "확인", buttonAction: nil)
            }
        }
    }

    @objc private func verifyCodeTapped() {
        let code = (codeTextField.text ?? "")
            .replacingOccurrences(of: "\\s", with: "", options: .regularExpression)

        guard !code.isEmpty else {
            showCustomAlert(title: "코드를 입력해주세요.", buttonText: "확인", buttonAction: nil)
            return
        }
        
        verifyEmail(code: code, registerInfo: registerInfo)
    }
    
    private func verifyEmail(code: String, registerInfo: RegisterRequestDto) {
        emailService.verifyEmailCode(email: registerInfo.email, code: code) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success:
                    // 2단계: 회원가입
                    self.registerUser(registerInfo: registerInfo)
                    
                case .failure(let error):
                    self.showVerificationFailureAlert(error: error)
                }
            }
        }
    }
    
    private func registerUser(registerInfo: RegisterRequestDto) {
        authService.register(data: registerInfo) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success:
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    self.navigateToNextStep()
                    
                case .failure(let error):
                    self.showRegisterFailureAlert(error: error)
                }
            }
        }
    }

    private func navigateToNextStep() {
        let nickNameRegisterVC = NicknameRegisterViewController(email: registerInfo.email, fromLogin: true)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = nickNameRegisterVC
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        }
    }

    private func startCountdown(from seconds: Int) {
        countdownTimer?.invalidate()
        remainingSeconds = seconds
        updateTimerLabel()

        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] t in
            guard let self else { return }
            self.remainingSeconds = max(0, self.remainingSeconds - 1)
            if self.remainingSeconds <= 0 {
                t.invalidate()
                self.remainingSeconds = 0
                self.updateTimerLabel()
                self.verifyButton.setEnabled(isEnabled: false)
                self.showCustomAlert(title: "인증 시간이 만료되었습니다.", buttonText: "확인", buttonAction: {
                    self.navigationController?.popViewController(animated: false)
                })
            } else {
                self.updateTimerLabel()
            }
        }
        RunLoop.main.add(countdownTimer!, forMode: .common)
    }

    private func updateTimerLabel() {
        if remainingSeconds > 0 {
            let m = remainingSeconds / 60
            let s = remainingSeconds % 60
            timerLabel.text = String(format: "%d:%02d초 남음", m, s)
        } else {
            timerLabel.text = "0:00초 남음"
        }
    }
    
    private func showRegisterFailureAlert(error: NetworkError) {
        let message: String
        
        switch error {
        case .serverError(let statusCode, let serverMessage):
            if statusCode == 409 {
                message = "이미 가입된 이메일입니다."
            } else {
                message = serverMessage
            }
        case .networkError:
            message = "네트워크 오류가 발생했습니다."
        case .decodingError:
            message = "데이터 처리 중 오류가 발생했습니다."
        default:
            message = "회원가입에 실패했습니다."
        }
        
        showCustomAlert(
            title: message,
            buttonText: "확인",
            buttonAction: nil
        )
    }
    
    private func showVerificationFailureAlert(error: NetworkError) {
        let message: String
        
        switch error {
        case .serverError(_, let serverMessage):
            message = serverMessage
        default:
            message = "인증 코드가 올바르지 않습니다."
        }
        
        showCustomAlert(
            title: message,
            buttonText: "확인",
            buttonAction: nil
        )
    }
}
