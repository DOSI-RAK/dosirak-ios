//
//  AddressInputViewController.swift
//  Dosirak
//
//  Created by 권민재 on 11/14/24.
//
import UIKit
import SnapKit
import RxSwift
import RxCocoa
import CoreLocation
import PanModal

class AddressInputViewController: UIViewController, CLLocationManagerDelegate {
    
    private let disposeBag = DisposeBag()
    private let locationManager = CLLocationManager()
    
    private var coordinator: AppCoordinator?
    
    private let districtTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "구 선택"
        textField.backgroundColor = .white
        textField.borderStyle = .none
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.setLeftPadding(10)
        textField.setRightPadding(10)
        return textField
    }()
    
    private let neighborhoodTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "동 선택"
        textField.backgroundColor = .white
        textField.borderStyle = .none
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.setLeftPadding(10)
        textField.setRightPadding(10)
        return textField
    }()
    
    private let currentLocationButton: UIButton = {
        let button = UIButton()
        button.setTitle("현재 위치로 찾기", for: .normal)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.setImage(UIImage(named: "location"), for: .normal)
        button.tintColor = .white
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        return button
    }()
    
    private let startButton: UIButton = {
        let button = UIButton()
        button.setTitle("시작하기", for: .normal)
        button.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.5)
        button.layer.cornerRadius = 8
        button.isEnabled = true
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.systemGray6
        
        let titleLabel = UILabel()
        titleLabel.text = "지구를 위한 용기\n시작해볼까요?"
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .heavy)
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 2
        let attributedText = NSMutableAttributedString(string: titleLabel.text!)
        attributedText.addAttribute(.foregroundColor, value: UIColor.mainColor, range: (titleLabel.text! as NSString).range(of: "용기"))
        titleLabel.attributedText = attributedText
        
        view.addSubview(titleLabel)
        view.addSubview(districtTextField)
        view.addSubview(neighborhoodTextField)
        view.addSubview(currentLocationButton)
        view.addSubview(startButton)
        
        // Layout
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            make.leading.equalTo(view.snp.leading).inset(24)
            make.centerX.equalToSuperview()
        }
        
        districtTextField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(30)
            make.leading.equalToSuperview().inset(24)
            make.height.equalTo(50)
        }
        
        neighborhoodTextField.snp.makeConstraints { make in
            make.top.equalTo(districtTextField)
            make.leading.equalTo(districtTextField.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(24)
            make.height.equalTo(districtTextField)
            make.width.equalTo(districtTextField)
        }
        
        currentLocationButton.snp.makeConstraints { make in
            make.top.equalTo(districtTextField.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(50)
        }
        
        startButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(50)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(40)
        }
    }
    
    private func setupBindings() {
        currentLocationButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.requestLocationPermission()
            })
            .disposed(by: disposeBag)
        
        // districtTextField가 선택되면 AddressPicker를 구 선택으로 호출
        districtTextField.rx.controlEvent(.editingDidBegin)
            .subscribe(onNext: { [weak self] in
                self?.showAddressPicker(isDistrictSelection: true)
            })
            .disposed(by: disposeBag)
        
        // neighborhoodTextField가 선택되면 AddressPicker를 동 선택으로 호출
        neighborhoodTextField.rx.controlEvent(.editingDidBegin)
            .subscribe(onNext: { [weak self] in
                guard let self = self, let selectedDistrict = self.districtTextField.text, !selectedDistrict.isEmpty else {
                    self?.showAlert("먼저 구를 선택해주세요.")
                    return
                }
                self.showAddressPicker(isDistrictSelection: false, district: selectedDistrict)
            })
            .disposed(by: disposeBag)
        
        // 텍스트 필드의 값이 모두 채워지면 startButton을 즉시 활성화
        Observable.combineLatest(
            districtTextField.rx.text.orEmpty,
            neighborhoodTextField.rx.text.orEmpty
        )
        .map { !$0.isEmpty && !$1.isEmpty } // 두 필드가 비어있지 않으면 true
        .distinctUntilChanged() // 값이 변경될 때만 트리거
        .bind(to: startButton.rx.isEnabled) // isEnabled 바인딩
        .disposed(by: disposeBag)

        // startButton의 배경색을 즉시 업데이트
        Observable.combineLatest(
            districtTextField.rx.text.orEmpty,
            neighborhoodTextField.rx.text.orEmpty
        )
        .map { $0.isEmpty || $1.isEmpty ? UIColor.systemGreen.withAlphaComponent(0.5) : UIColor.systemGreen }
        .bind(to: startButton.rx.backgroundColor) // backgroundColor 바인딩
        .disposed(by: disposeBag)
        
        // startButton이 눌렸을 때의 동작
        startButton.rx.tap
            .subscribe(onNext: {[weak self] in
                print("startButton Tapped")
                guard let window = self?.view.window else { return }
                self?.coordinator?.moveHome(window: window)
            })
            .disposed(by: disposeBag)
    }
    
    private func showAddressPicker(isDistrictSelection: Bool, district: String? = nil) {
        let addressPickerVC = AddressPickerViewController()
        addressPickerVC.isDistrictSelection = isDistrictSelection
        addressPickerVC.currentDistrict = district
        
      
        if isDistrictSelection {
            addressPickerVC.selectedDistrict
                .subscribe(onNext: { [weak self] selectedDistrict in
                    self?.districtTextField.text = selectedDistrict
                    self?.neighborhoodTextField.text = ""
                })
                .disposed(by: disposeBag)
        } else {
        
            addressPickerVC.selectedNeighborhood
                .bind(to: neighborhoodTextField.rx.text)
                .disposed(by: disposeBag)
        }
        
        presentPanModal(addressPickerVC)
    }
    
    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
    private func requestLocationPermission() {
        let status = locationManager.authorizationStatus
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            showLocationPermissionAlert()
        @unknown default:
            break
        }
    }
    
    private func showLocationPermissionAlert() {
        let alertController = UIAlertController(
            title: "위치 권한 필요",
            message: "위치 서비스를 사용하려면 설정에서 위치 권한을 활성화해주세요.",
            preferredStyle: .alert
        )
        
        let settingsAction = UIAlertAction(title: "설정으로 이동", style: .default) { _ in
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(settingsURL)
        }
        alertController.addAction(settingsAction)
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        present(alertController, animated: true)
    }
    
    // 위치 업데이트 시 호출
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            fetchAddress(for: location)
        }
    }
    
    private func fetchAddress(for location: CLLocation) {
        let geocoder = CLGeocoder()
        let locale = Locale(identifier: "ko_KR")
        geocoder.reverseGeocodeLocation(location, preferredLocale: locale) { [weak self] placemarks, error in
            guard let self = self, let placemark = placemarks?.last, error == nil else { return }
            self.districtTextField.text = placemark.locality
            self.neighborhoodTextField.text = placemark.subLocality
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
}

// UITextField에 padding 추가
extension UITextField {
    func setLeftPadding(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func setRightPadding(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
