//
//  GreenGuideViewController.swift
//  Dosirak
//
//  Created by 권민재 on 11/1/24.
//
import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit
import NMapsMap
import CoreLocation

// MARK: - GreenGuideViewController

class GreenGuideViewController: UIViewController {
    
    let mapView = NMFMapView()
    private let disposeBag = DisposeBag()
    private let reactor: GreenGuideReactor
    private let overlayView = UIView()
    private var bottomSheetVC: BottomSheetViewController?

    private let categoryTitles = ["전체", "한식", "일식", "양식", "분식", "카페", "디저트"]
    private var selectedCategoryButton: UIButton?
    private var userLocation: CLLocation?
    private let locationManager = CLLocationManager()
    private var hasInitializedMapView = false
    
    
    init(reactor: GreenGuideReactor) {
        self.reactor = reactor
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLayout()
        setupBottomSheet()
        bindReactor()
        navigationController?.delegate = self
        setupLocationManager()

        
    }
    //테스트
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // 강남역 기본 좌표 설정
        let userLocation = AppSettings.userLocation
        let gangnamLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        initializeMapToUserLocation(location: gangnamLocation)
        updateUserMarker(location: gangnamLocation)

        // 실제 위치 권한 요청 및 업데이트
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    //실제 사용
//    private func setupLocationManager() {
//        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.startUpdatingLocation()
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        //self.mapView.isHidden = true
        setupBottomSheet()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    private func setupView() {
        view.addSubview(mapView)
        
        overlayView.backgroundColor = .clear // 터치 우선 오버레이 설정
        overlayView.isUserInteractionEnabled = true
        view.addSubview(overlayView)
        
        overlayView.addSubview(searchTextField)
        overlayView.addSubview(findRouteButton)
        overlayView.addSubview(homeButton)
        setupCategoryButtons()
        
        // myLocationButton을 mapView에 추가
        mapView.addSubview(myLocationButton)
    }
    
    private func setupLayout() {
        mapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        overlayView.snp.makeConstraints {
            $0.leading.trailing.equalTo(view)
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(120)
        }
        
        searchTextField.snp.makeConstraints {
            $0.top.equalTo(overlayView.safeAreaLayoutGuide).offset(10)
            $0.leading.equalTo(overlayView).inset(20)
            $0.width.equalTo(252)
            $0.height.equalTo(52)
        }
        
        findRouteButton.snp.makeConstraints {
            $0.leading.equalTo(searchTextField.snp.trailing).offset(10)
            $0.width.height.equalTo(52)
            $0.top.equalTo(searchTextField)
        }
        
        homeButton.snp.makeConstraints {
            $0.leading.equalTo(findRouteButton.snp.trailing).offset(5)
            $0.width.height.equalTo(52)
            $0.trailing.equalTo(mapView.snp.trailing).inset(5)
            $0.top.equalTo(searchTextField)
        }
        
        myLocationButton.snp.makeConstraints {
            $0.leading.equalTo(view).inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20) // 지도 위 아래쪽에 고정
            $0.width.height.equalTo(52)
        }
    }
    
    
    private func setupBottomSheet() {
        bottomSheetVC = BottomSheetViewController()
        bottomSheetVC?.reactor = self.reactor

        bottomSheetVC?.storeSelected
            .subscribe(onNext: { [weak self] store in
                self?.bottomSheetVC?.dismiss(animated: false) {
                    let detailVC = StoreDetailViewController(storeId: store.storeId,reactor: self!.reactor)
                    self?.bottomSheetVC?.view.isHidden = true
                    self?.navigationController?.pushViewController(detailVC, animated: true)
                }
                
            })
            .disposed(by: disposeBag)
        
        if let sheet = bottomSheetVC?.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.selectedDetentIdentifier = .medium
            sheet.delegate = self
        }
        
        if let bottomSheetVC = bottomSheetVC {
            present(bottomSheetVC, animated: true)
        }
    }
    
    private func setupCategoryButtons() {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        
        categoryTitles.forEach { title in
            let button = UIButton()
            button.setTitle(title, for: .normal)
            button.backgroundColor = .white
            button.setTitleColor(.black, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 14)
            button.layer.cornerRadius = 15
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.lightGray.cgColor
            button.layer.masksToBounds = true
            button.addTarget(self, action: #selector(categoryButtonTapped(_:)), for: .touchUpInside)
            
            if title == "전체" {
                selectCategoryButton(button)
            }
            
            stackView.addArrangedSubview(button)
        }
        
        overlayView.addSubview(stackView)
        
       
        stackView.snp.makeConstraints {
            $0.top.equalTo(searchTextField.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(overlayView).inset(20)
            $0.height.equalTo(30)
        }
    }
    
    
    @objc private func categoryButtonTapped(_ sender: UIButton) {
           guard let category = sender.currentTitle else { return }
           print("\(category) 버튼이 탭되었습니다.")
           selectCategoryButton(sender)
           
    
           if category == "전체" {
               reactor.action.onNext(.loadAllStores) // 전체 카테고리일 때
           } else {
               reactor.action.onNext(.loadStoresByCategory(category)) // 특정 카테고리일 때
           }
       }
    
    private func selectCategoryButton(_ button: UIButton) {
        // 기존 선택된 버튼 스타일 초기화
        selectedCategoryButton?.backgroundColor = .white
        selectedCategoryButton?.setTitleColor(.black, for: .normal)
        selectedCategoryButton?.layer.borderColor = UIColor.lightGray.cgColor
        
        // 새로 선택된 버튼 스타일 적용
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        
        // 현재 선택된 버튼 업데이트
        selectedCategoryButton = button
    }

    // MARK: - Reactor Binding
    private func bindReactor() {
        // Reactor Action: 초기 상점 목록 불러오기
        reactor.action.onNext(.loadAllStores)
        
        // Reactor State Binding 예시: 로딩 상태 관찰
        reactor.state
            .map { $0.isLoading }
            .distinctUntilChanged()
            .subscribe(onNext: { isLoading in
                if isLoading {
                    print("로딩 중...")
                } else {
                    print("로딩 완료")
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state
               .map { $0.selectedCategory }
               .distinctUntilChanged()
               .subscribe(onNext: { category in
                   print("Selected category updated to: \(category)")
               })
               .disposed(by: disposeBag)
        
           
           reactor.state
               .map { $0.isLoading }
               .distinctUntilChanged()
               .subscribe(onNext: { isLoading in
                   print(isLoading ? "Loading..." : "Loading completed")
               })
               .disposed(by: disposeBag)
        
        
        
        
        homeButton.rx.tap
            .bind { [weak self] in
                print("homeButton tapped")
                self?.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.stores } // 내 주변 데이터
            .subscribe(onNext: { [weak self] stores in
                self?.updateMapMarkers(stores: stores)
            })
            .disposed(by: disposeBag)
        
        searchTextField.rx.text.orEmpty
               .debounce(.milliseconds(300), scheduler: MainScheduler.instance) // 입력 후 300ms 대기
               .distinctUntilChanged()
               .filter { !$0.isEmpty } // 빈 입력 무시
               .map { GreenGuideReactor.Action.searchStores($0) } // 구체적 타입 명시
               .bind(to: reactor.action)
               .disposed(by: disposeBag)
        
        
        findRouteButton.rx.tap
            .bind { [weak self] in
                self?.navigationController?.pushViewController(GreenTrackViewController(), animated: true)
            }
            .disposed(by: disposeBag)
        
        
        
    }
    
    private func updateMapMarkers(stores: [Store]) {
        
        // 새로운 마커 추가
        stores.forEach { store in
            print("Store \(store.storeName): (\(store.mapX), \(store.mapY))") // 디버깅용 출력
            let marker = NMFMarker(position: NMGLatLng(lat: store.mapY, lng: store.mapX))
            marker.iconImage = NMFOverlayImage(name: "marker")
            marker.captionText = store.storeName
            marker.mapView = mapView
        }
    }
    private var userMarker: NMFMarker?
    
    private func initializeMapToUserLocation(location: CLLocation) {
        let cameraPosition = NMGLatLng(lat: location.coordinate.latitude, lng: location.coordinate.longitude)
        mapView.moveCamera(NMFCameraUpdate(scrollTo: cameraPosition))
        mapView.positionMode = .compass // 현재 위치 중심
    }

    private func updateUserMarker(location: CLLocation) {

        // 새로운 마커 추가
        let marker = NMFMarker(position: NMGLatLng(lat: location.coordinate.latitude, lng: location.coordinate.longitude))
        marker.iconImage = NMFOverlayImage(name: "marker")
        marker.iconTintColor = .blue
        //marker.iconTintColor = .systemBlue // 마커 색상
        marker.width = 30
        marker.height = 30
        marker.mapView = mapView // 지도에 마커 표시
        userMarker = marker
    }
    
    // MARK: UI Components
    lazy var searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "장소, 주소 검색"
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 12
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always // 항상 leftView가 보이도록 설정
        return textField
    }()
    
    lazy var findRouteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "goto"), for: .normal)
        //button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        return button
    }()
    
    lazy var myLocationButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "mylocation"), for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        return button
    }()
    
    lazy var homeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "home_green"), for: .normal)
        button.backgroundColor = .clear
        return button
    }()
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension GreenGuideViewController: UISheetPresentationControllerDelegate {
    private func presentationControllerDidChangeSelectedDetentIdentifier(_ presentationController: UIPresentationController) {
        guard let sheet = presentationController as? UISheetPresentationController else { return }
        
        // Bottom sheet가 large일 때 myLocationButton 숨기기
        if sheet.selectedDetentIdentifier == .large {
            myLocationButton.isHidden = true
        } else {
            myLocationButton.isHidden = false
        }
    }
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        if let sheet = presentationController as? UISheetPresentationController {
            sheet.selectedDetentIdentifier = .medium
        }
    }
}

extension GreenGuideViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        // 뒤로 이동할 때, BottomSheet 표시
        if viewController is GreenGuideViewController {
            bottomSheetVC?.view.isHidden = false
        }
    }
}


extension GreenGuideViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location
        
        if !hasInitializedMapView {
            // 지도 초기 위치 설정
            initializeMapToUserLocation(location: location)
            hasInitializedMapView = true
        }
        updateUserMarker(location: location) // 사용자 위치 마커 추가
        reactor.action.onNext(.loadStoresNearMyLocation(location.coordinate.latitude, location.coordinate.longitude))
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location: \(error.localizedDescription)")
    }
}
