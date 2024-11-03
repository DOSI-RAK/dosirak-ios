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

// MARK: - GreenGuideViewController

class GreenGuideViewController: UIViewController {
    
    // MARK: - Properties
    let mapView = NMFMapView()
    private let disposeBag = DisposeBag()
    private let reactor: GreenGuideReactor
    
    // MARK: - Initializer
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
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        view.addSubview(mapView)
        mapView.addSubview(searchTextField)
        mapView.addSubview(findRouteButtton)
        mapView.addSubview(myLocationButton)
    }
    
    private func setupLayout() {
        mapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        searchTextField.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.equalTo(view.snp.leading).inset(30)
            $0.width.equalTo(252)
            $0.height.equalTo(52)
        }
        
        findRouteButtton.snp.makeConstraints {
            $0.leading.equalTo(searchTextField.snp.trailing).offset(10)
            $0.width.height.equalTo(52)
            $0.top.equalTo(searchTextField)
        }
        myLocationButton.snp.makeConstraints {
            $0.leading.equalTo(view).inset(20)
            $0.width.height.equalTo(52)
        }
    }
    
    private func setupBottomSheet() {
        let bottomSheetVC = BottomSheetViewController()
        bottomSheetVC.reactor = reactor // GuideReactor 주입
        
        if let sheet = bottomSheetVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.selectedDetentIdentifier = .medium
        }
        
        present(bottomSheetVC, animated: true)
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
        
        // Reactor State Binding 예시: 상점 목록을 지도에 표시
//        reactor.state
//            .map { $0.stores }
//            .observe(on: MainScheduler.instance)
//            .subscribe(onNext: { [weak self] stores in
//                self?.updateMapMarkers(with: stores)
//            })
//            .disposed(by: disposeBag)
    }
    
    // 지도에 상점 마커 추가
//    private func updateMapMarkers(with stores: [Store]) {
//        mapView.mapViewOverlays.removeAll() // 기존 마커 제거
//        
//        for store in stores {
//            let marker = NMFMarker()
//            marker.position = NMGLatLng(lat: store.latitude, lng: store.longitude)
//            marker.mapView = mapView
//            marker.captionText = store.name
//        }
//    }
    
    //MARK: UI Components
    lazy var searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "상호 동 검색"
        textField.backgroundColor = .white
        return textField
    }()
    
    lazy var findRouteButtton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "goto"), for: .normal)
        button.backgroundColor = .systemBlue
        return button
    }()
    lazy var myLocationButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "mylocation"), for: .normal)
        button.backgroundColor = .white
        return button
    }()
}
