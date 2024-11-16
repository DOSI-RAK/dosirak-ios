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


class UserAgreeViewController: UIViewController, CLLocationManagerDelegate {

    private let disposeBag = DisposeBag()
    private let locationManager = CLLocationManager()
    
    let nextButtonTapped = PublishRelay<Void>()
 

    private let allAgree = BehaviorRelay<Bool>(value: false)
    private let serviceAgree = BehaviorRelay<Bool>(value: false)
    private let marketingAgree = BehaviorRelay<Bool>(value: false)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        locationManager.delegate = self
    }

    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(allAgreeButton)
        view.addSubview(separatorView)
        view.addSubview(serviceAgreeButton)
        view.addSubview(marketingAgreeButton)
        view.addSubview(infoLabel)
        view.addSubview(nextButton)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            make.leading.equalTo(view).inset(24)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(30)
            make.leading.equalTo(view).inset(24)
            make.trailing.equalTo(view)
        }
        
        allAgreeButton.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(30)
            make.leading.equalToSuperview().inset(24)
        }
        
       
        separatorView.snp.makeConstraints { make in
            make.top.equalTo(allAgreeButton.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(1)
        }
        
        
        serviceAgreeButton.snp.makeConstraints { make in
            make.top.equalTo(separatorView.snp.bottom).offset(40)
            make.leading.equalToSuperview().inset(24)
        }
        
        
        marketingAgreeButton.snp.makeConstraints { make in
            make.top.equalTo(serviceAgreeButton.snp.bottom).offset(30)
            make.leading.equalToSuperview().inset(24)
            make.trailing.equalToSuperview()
        }
        
        
        infoLabel.snp.makeConstraints { make in
            make.top.equalTo(marketingAgreeButton.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().inset(52)
        }
        
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(40)
        }
    }

    private func setupBindings() {
        // 전체 동의 버튼 로직
        allAgreeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let newValue = !self.allAgree.value
                self.allAgree.accept(newValue)
                self.serviceAgree.accept(newValue) // 서비스 동의 상태 동기화
                self.marketingAgree.accept(newValue) // 마케팅 동의 상태 동기화
                self.updateAllAgreeButtonImage(isChecked: newValue) // 전체 동의 이미지 업데이트
                self.updateButtonImage(
                    button: self.serviceAgreeButton,
                    isChecked: newValue,
                    checkedImageName: "check02_hover",
                    uncheckedImageName: "check02"
                )
                self.updateButtonImage(
                    button: self.marketingAgreeButton,
                    isChecked: newValue,
                    checkedImageName: "check02_hover",
                    uncheckedImageName: "check02"
                )
                print("All agree button tapped. New value for allAgree: \(newValue)")
            })
            .disposed(by: disposeBag)

        // 개별 동의 버튼 로직 (서비스 약관 동의)
        serviceAgreeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let newValue = !self.serviceAgree.value
                self.serviceAgree.accept(newValue)
                self.updateAllAgreeState() // 전체 동의 상태 업데이트
                self.updateButtonImage(
                    button: self.serviceAgreeButton,
                    isChecked: newValue,
                    checkedImageName: "check02_hover",
                    uncheckedImageName: "check02"
                )
                print("Service agree button tapped. New value for serviceAgree: \(newValue)")
            })
            .disposed(by: disposeBag)

        // 개별 동의 버튼 로직 (마케팅 정보 동의)
        marketingAgreeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let newValue = !self.marketingAgree.value
                self.marketingAgree.accept(newValue)
                self.updateAllAgreeState() // 전체 동의 상태 업데이트
                self.updateButtonImage(
                    button: self.marketingAgreeButton,
                    isChecked: newValue,
                    checkedImageName: "check02_hover",
                    uncheckedImageName: "check02"
                )
                print("Marketing agree button tapped. New value for marketingAgree: \(newValue)")
            })
            .disposed(by: disposeBag)

        // "다음" 버튼 활성화 상태
        Observable.combineLatest(serviceAgree, allAgree) { $0 && $1 }
            .bind(to: nextButton.rx.isEnabled)
            .disposed(by: disposeBag)

        Observable.combineLatest(serviceAgree, allAgree) { $0 && $1 }
            .map { $0 ? UIColor.mainColor : UIColor.lightGray }
            .bind(to: nextButton.rx.backgroundColor)
            .disposed(by: disposeBag)
        
        nextButton.rx.tap
                .subscribe(onNext: { [weak self] in
                    self?.navigationController?.pushViewController(AddressInputViewController(), animated: true)
                    
                })
                .disposed(by: disposeBag)
    }
    
    
    private func updateAllAgreeState() {
        // 모든 개별 동의 버튼이 체크되었는지 확인
        let isAllChecked = serviceAgree.value && marketingAgree.value
        allAgree.accept(isAllChecked)
        updateAllAgreeButtonImage(isChecked: isAllChecked)
    }
    private func updateAllAgreeButtonImage(isChecked: Bool) {
        let imageName = isChecked ? "check01_hover" : "check01"
        allAgreeButton.setImage(UIImage(named: imageName), for: .normal)
    }

    private func updateButtonImage(button: UIButton, isChecked: Bool, checkedImageName: String, uncheckedImageName: String) {
        let imageName = isChecked ? checkedImageName : uncheckedImageName
        button.setImage(UIImage(named: imageName), for: .normal)
    }


    
    private func handleServiceAgreeButtonTap() {
        let status = locationManager.authorizationStatus
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            print("위치 권한이 거부되었습니다.")
        case .authorizedWhenInUse, .authorizedAlways:
            serviceAgree.accept(!serviceAgree.value)
            print("위치 권한이 이미 부여되었습니다.")
        @unknown default:
            break
        }
    }
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "반갑습니다!"
        label.font = UIFont.systemFont(ofSize: 28, weight: .heavy)
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
            attributedText.addAttribute(.foregroundColor, value: UIColor.mainColor, range: nsRange)
        }
        label.font = UIFont.systemFont(ofSize: 16)
        label.attributedText = attributedText
        label.numberOfLines = 2
        label.textAlignment = .left
        return label
    }()

    private let allAgreeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "check01"), for: .normal)
        button.setTitle("전체 동의", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.contentHorizontalAlignment = .left
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        
        // 텍스트가 잘리지 않도록 설정
        button.titleLabel?.lineBreakMode = .byClipping
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.8
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        return button
    }()

    private let serviceAgreeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "check02"), for: .normal)
        button.contentHorizontalAlignment = .left
        let fullText = ". 위치 기반 서비스 약관 동의 (필수)"
        let attributedText = NSMutableAttributedString(string: fullText)
        
        if let range = fullText.range(of: "(필수)") {
            let nsRange = NSRange(range, in: fullText)
            attributedText.addAttribute(.foregroundColor, value: UIColor.red, range: nsRange)
        }
        
        button.setAttributedTitle(attributedText, for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        
        // 텍스트가 잘리지 않도록 설정
        button.titleLabel?.lineBreakMode = .byClipping
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.8
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        return button
    }()

    private let marketingAgreeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "check02"), for: .normal)
        button.setTitle("  마케팅 정보 앱 푸시 알림 수신 동의 (선택)", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.contentHorizontalAlignment = .left
        //button.backgroundColor = .green
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        return button
    }()

    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.4)
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
