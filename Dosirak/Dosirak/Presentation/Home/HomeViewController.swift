//
//  HomeViewController.swift
//  Dosirak
//
//  Created by 권민재 on 10/31/24.
//
import CoreLocation
import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SnapKit
import RxGesture

struct GuideData {
    let title: String
    let subtitle: String
    let imageName: String
}



struct GuideSection {
    var header: String
    var items: [GuideData]
}

extension GuideSection: SectionModelType {
    typealias Item = GuideData
    
    init(original: GuideSection, items: [GuideData]) {
        self = original
        self.items = items
    }
}

class HomeViewController: BaseViewController, UICollectionViewDelegateFlowLayout, CLLocationManagerDelegate {
    
    private let disposeBag = DisposeBag()
    var coordinator = HomeCoordinator()
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    let guideSections = Observable.just([
        GuideSection(header: "Large Section", items: [
            GuideData(title: "Green Guide", subtitle: "내 주변 다회용기 포장\n가능 매장 찾기", imageName: "greenguide_bg")
        ]),
        GuideSection(header: "Grid Section", items: [
            GuideData(title: "Green Club", subtitle: "내 주변 마감\n세일 확인하기", imageName: "greenclub_bg"),
            GuideData(title: "Green Talk", subtitle: "내 주변 환경 지킴이들과\n이야기하기", imageName: "greentalk_bg")
        ]),
        GuideSection(header: "List Section", items: [
            GuideData(title: "Green Elite", subtitle: "환경 문제 풀고 리워드 받자!", imageName: "greenelite"),
            GuideData(title: "Green Heros", subtitle: "지구를 지키는 주역! 내 순위 보기", imageName: "greenheros"),
            GuideData(title: "Green Auth", subtitle: "다회용기 사용 인증하기", imageName: "greenauth")
        ])
    ])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupLocationManager()
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    override func setupView() {
        view.addSubview(collectionView)
        collectionView.backgroundColor = .bgColor
        collectionView.register(GuideCell.self, forCellWithReuseIdentifier: GuideCell.identifier)
        collectionView.register(DoubleGridCell.self, forCellWithReuseIdentifier: DoubleGridCell.identifier)
        collectionView.register(ListCell.self, forCellWithReuseIdentifier: ListCell.identifier)
        
        collectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    override func setupLayout() {
        collectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalTo(view)
        }
    }
    
    override func bindRX() {
        let dataSource = RxCollectionViewSectionedReloadDataSource<GuideSection>(
            configureCell: { dataSource, collectionView, indexPath, item in
                let identifier: String
                switch indexPath.section {
                case 0:
                    identifier = GuideCell.identifier
                case 1:
                    identifier = DoubleGridCell.identifier
                default:
                    identifier = ListCell.identifier
                }
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
                
                if let guideCell = cell as? GuideCell {
                    guideCell.configure(image: UIImage(named: item.imageName), title: item.title, subtitle: item.subtitle)
                } else if let gridCell = cell as? DoubleGridCell {
                    gridCell.configure(image: UIImage(named: item.imageName), title: item.title, subtitle: item.subtitle)
                    gridCell.titleLabel.textColor = indexPath.row == 0 ? .white : .black
                } else if let listCell = cell as? ListCell {
                    listCell.configure(icon: UIImage(named: item.imageName), title: item.title, subTitle: item.subtitle)
                    listCell.backgroundColor = .white
                }
                return cell
            }
        )
        
        guideSections
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
            .bind { [weak self] indexPath in
                self?.coordinator.navigateToDetail(for: indexPath)
            }
            .disposed(by: disposeBag)
        
        locationButton.rx.tap
            .bind { [weak self] in
                self?.requestLocationPermission()
            }
            .disposed(by: disposeBag)
    }
    
    private func requestLocationPermission() {
        guard CLLocationManager.locationServicesEnabled() else {
            print("위치 서비스가 비활성화되었습니다.")
            return
        }
        
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func setupNavigationBar() {
        locationButton.setImage(UIImage(named: "mylocation"), for: .normal)
        locationButton.setTitleColor(.black, for: .normal)
        locationButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        locationButton.tintColor = .black
        locationButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 5)
        
        let locationStackView = UIStackView(arrangedSubviews: [locationButton, myLocationLabel])
        locationStackView.axis = .horizontal
        locationStackView.spacing = 5
        locationStackView.alignment = .center
        
        let locationItem = UIBarButtonItem(customView: locationStackView)
        navigationItem.leftBarButtonItem = locationItem
        
        locationButton.snp.makeConstraints { make in
            make.height.equalTo(30)
        }
    }
    
    private let locationButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "mylocation"), for: .normal)
        return button
    }()
    
    private let myLocationLabel: UILabel = {
        let label = UILabel()
        label.text = "위치 정보 설정이 필요합니다."
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        return label
    }()

    // 위치 권한 상태 변경 시 호출
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            myLocationLabel.text = "위치 권한을 허용해 주세요."
            print("위치 권한이 거부되었습니다. 설정에서 권한을 활성화해주세요.")
        case .notDetermined:
            print("위치 권한 요청 중입니다.")
        @unknown default:
            break
        }
    }
    
    // 위치 업데이트 성공 시 호출
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        geocodeLocation(location)
        locationManager.stopUpdatingLocation() // 위치 업데이트 후 멈춤
    }
    
    // 위치 업데이트 실패 시 호출
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("위치 업데이트 실패: \(error.localizedDescription)")
    }
    
    // 위치 정보를 주소로 변환하는 메서드
    private func geocodeLocation(_ location: CLLocation) {
        geocoder.reverseGeocodeLocation(location, preferredLocale: Locale(identifier: "ko_KR")) { [weak self] placemarks, error in
            if let error = error {
                print("역지오코딩 실패: \(error.localizedDescription)")
                return
            }
            
            guard let placemark = placemarks?.first,
                  let locality = placemark.locality,
                  let subLocality = placemark.subLocality else {
                return
            }
            
            let address = "\(locality) \(subLocality)"
            self?.myLocationLabel.text = address
        }
    }
    
    // MARK: - UICollectionView
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        switch indexPath.section {
        case 0:
            return CGSize(width: width - 32, height: 200)
        case 1:
            let gridWidth = (width - 48) / 2 - 10
            return CGSize(width: gridWidth, height: 130)
        default:
            return CGSize(width: width - 32, height: 60)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch section {
        case 0:
            return UIEdgeInsets(top: 20, left: 20, bottom: 10, right: 20)
        case 1:
            return UIEdgeInsets(top: 20, left: 20, bottom: 10, right: 20)
        default:
            return UIEdgeInsets(top: 25, left: 20, bottom: 10, right: 20)
        }
    }
}
