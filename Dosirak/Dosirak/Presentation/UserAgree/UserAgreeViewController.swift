//
//  UserAgreeViewController.swift
//  Dosirak
//
//  Created by 권민재 on 11/13/24.
//
import UIKit
import SnapKit
import RxSwift
import RxCocoa
import CoreLocation

class UserAgreeViewController: BaseViewController, CLLocationManagerDelegate {

    private let disposeBag = DisposeBag()
    private let locationManager = CLLocationManager()

    // Reactive 변수
    private let allAgree = BehaviorRelay<Bool>(value: false)
    private let serviceAgree = BehaviorRelay<Bool>(value: false)
    private let marketingAgree = BehaviorRelay<Bool>(value: false)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        
        locationManager.delegate = self
        print("Location manager delegate set.")
    }

    private func setupUI() {
        view.backgroundColor = .white
        nextButton.setTitle("다음", for: .normal)
        nextButton.backgroundColor = .lightGray
        nextButton.layer.cornerRadius = 8
        nextButton.isEnabled = false
        
        // StackView 구성
        let stackView = UIStackView(arrangedSubviews: [
            titleLabel, descriptionLabel, allAgreeButton, separatorView, serviceAgreeButton, marketingAgreeButton, infoLabel, nextButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .leading
        view.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(40)
        }
    }

    private func setupBindings() {
        allAgreeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let newValue = !self.allAgree.value
                self.allAgree.accept(newValue)
                self.serviceAgree.accept(newValue)
                self.marketingAgree.accept(newValue)
                print("All agree button tapped. New value for allAgree: \(newValue)")
            })
            .disposed(by: disposeBag)
        
        // 위치 기반 서비스 동의 버튼 클릭 시
        serviceAgreeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                print("Service agree button tapped.")
                self.handleServiceAgreeButtonTap()
            })
            .disposed(by: disposeBag)
        
        marketingAgreeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.marketingAgree.accept(!self.marketingAgree.value)
                print("Marketing agree button tapped. New value for marketingAgree: \(self.marketingAgree.value)")
            })
            .disposed(by: disposeBag)
        
        serviceAgree
            .bind(to: nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        serviceAgree
            .map { $0 ? UIColor.systemGreen : UIColor.lightGray }
            .bind(to: nextButton.rx.backgroundColor)
            .disposed(by: disposeBag)
    }
    
    private func updateButton(_ button: UIButton?, isChecked: Bool) {
        let image = UIImage(named: !isChecked ? "check01" : "check01_hover")
        button?.setImage(image, for: .normal)
        button?.tintColor = isChecked ? .mainColor : .gray
        print("Updated button \(button?.titleLabel?.text ?? "") to checked state: \(isChecked)")
    }
    
    private func handleServiceAgreeButtonTap() {
        // 현재 위치 권한 상태를 확인
        let status = locationManager.authorizationStatus
        print("Location authorization status: \(status.rawValue)")
        
        switch status {
        case .notDetermined:
            print("Location permission not determined. Requesting authorization.")
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            print("Location permission denied or restricted.")
            showLocationPermissionAlert()
        case .authorizedWhenInUse, .authorizedAlways:
            print("Location permission already granted.")
            serviceAgree.accept(!serviceAgree.value)
        @unknown default:
            print("Unknown authorization status.")
            break
        }
    }
    
    private func showLocationPermissionAlert() {
        print("Showing location permission alert.")
        
        let alertController = UIAlertController(
            title: "위치 권한 필요",
            message: "위치 서비스를 사용하려면 설정에서 위치 권한을 활성화해주세요.",
            preferredStyle: .alert
        )
        
        let settingsAction = UIAlertAction(title: "설정으로 이동", style: .default) { _ in
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(settingsURL) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                print("Navigating to settings.")
            }
        }
        alertController.addAction(settingsAction)
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alertController, animated: true, completion: nil)
    }
    
    // 위치 권한 변경 시 호출되는 CLLocationManagerDelegate 메서드
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("Location authorization changed: \(status.rawValue)")
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            print("Location permission granted.")
            serviceAgree.accept(true)
        case .denied, .restricted:
            print("Location permission denied or restricted.")
        default:
            print("Other authorization status.")
            break
        }
    }

    // UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "반갑습니다!"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .black
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        let fullText = "아래 약관에 동의하시면\n지구를 지키기 위한 '용기'가 시작됩니다."
        let attributedText = NSMutableAttributedString(string: fullText)
        
        attributedText.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: fullText.count))
        
        if let range = fullText.range(of: "'용기'") {
            let nsRange = NSRange(range, in: fullText)
            attributedText.addAttribute(.foregroundColor, value: UIColor.systemGreen, range: nsRange)
        }
        
        label.attributedText = attributedText
        label.numberOfLines = 2
        return label
    }()

    private let allAgreeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "check01"), for: .normal)
        button.setTitle("  전체 동의", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.contentHorizontalAlignment = .left
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        return button
    }()

    private let serviceAgreeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "check02"), for: .normal)
        button.contentHorizontalAlignment = .left
        let fullText = "위치 기반 서비스 약관 동의 (필수)"
        let attributedText = NSMutableAttributedString(string: fullText)
        
        if let range = fullText.range(of: "(필수)") {
            let nsRange = NSRange(range, in: fullText)
            attributedText.addAttribute(.foregroundColor, value: UIColor.red, range: nsRange)
        }
        
        button.setAttributedTitle(attributedText, for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        return button
    }()

    private let marketingAgreeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "check02"), for: .normal)
        button.setTitle("  마케팅 정보 앱 푸시 알림 수신 동의 (선택)", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.contentHorizontalAlignment = .left
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        return button
    }()

    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.4)
        view.snp.makeConstraints { $0.height.equalTo(1) }
        return view
    }()

    private let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "이벤트 및 혜택 정보를 받아보실 수 있습니다."
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .systemBlue
        return label
    }()

    private let nextButton: UIButton = {
        let button = UIButton()
        button.setTitle("다음", for: .normal)
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 8
        button.isEnabled = false
        return button
    }()
}
