//
//  GreenTrackViewController.swift
//  Dosirak
//
//  Created by 권민재 on 11/18/24.
//
import UIKit
import MapKit
import SnapKit
import CoreLocation
import RxSwift
import RxCocoa

extension Decimal {
    var doubleValue: Double {
        return NSDecimalNumber(decimal: self).doubleValue
    }
}

extension CLPlacemark {
    var compactAddress: String? {
        if let name = name {
            return name
        } else if let thoroughfare = thoroughfare, let subThoroughfare = subThoroughfare {
            return "\(subThoroughfare) \(thoroughfare)"
        } else {
            return nil
        }
    }
}


class GreenTrackViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var destination: String?

    private let locationManager = CLLocationManager()
    private var userCoordinate: CLLocationCoordinate2D?
    private var destinationCoordinate: CLLocationCoordinate2D?
    private var userCoordinates: [CLLocationCoordinate2D] = []
    private var userPathPolyline: MKPolyline?
    private var isMeasuring: Bool = false
    
    
    private var bicycles: [Track] = []
    
    //MARK: ViewModel
    private let viewModel = GreenTrackViewModel()
    
    private var calculatedRouteDistance: Double = 0.0
    private var actualTravelDistance: Double = 0.0
    
    
    private let disposeBag = DisposeBag()
    
    
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Green Track"
        setupUI()
        setupLayout()
        setupLocationManager()
        mapView.delegate = self
        
        if let destination = destination {
            destinationField.text = destination
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }

    // MARK: - Setup UI
    private func setupUI() {
        view.addSubview(mapView)
        view.addSubview(startLocationField)
        view.addSubview(destinationField)
        view.addSubview(searchRouteButton)
        view.addSubview(walkingButton)
        view.addSubview(cyclingButton)
        view.addSubview(startMeasurementButton)

        walkingButton.addSubview(walkingLabel)
        walkingButton.addSubview(walkingTimeLabel)

        cyclingButton.addSubview(cyclingLabel)
        cyclingButton.addSubview(cyclingTimeLabel)
        
        searchRouteButton.addTarget(self, action: #selector(searchRoute), for: .touchUpInside)
        startMeasurementButton.addTarget(self, action: #selector(toggleMeasurement), for: .touchUpInside)
    }

    private func setupLayout() {
        
        mapView.snp.makeConstraints { make in
            make.top.equalTo(destinationField.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview()
        }


        startLocationField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.equalToSuperview().inset(16)
            make.trailing.equalToSuperview().offset(-120)
            make.height.equalTo(40)
        }

        destinationField.snp.makeConstraints { make in
            make.top.equalTo(startLocationField.snp.bottom).offset(8)
            make.leading.equalToSuperview().inset(16)
            make.trailing.equalToSuperview().offset(-120)
            make.height.equalTo(40)
        }

        searchRouteButton.snp.makeConstraints { make in
            make.top.equalTo(startLocationField)
            make.leading.equalTo(startLocationField.snp.trailing).offset(8)
            make.trailing.equalToSuperview().inset(16)
            make.height.equalTo(88)
        }
        

        walkingButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalTo(startMeasurementButton.snp.top).offset(-16)
            make.width.equalTo(160)
            make.height.equalTo(100)
        }

        walkingLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(10)
        }

        walkingTimeLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(walkingLabel.snp.bottom).offset(5)
        }

        cyclingButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalTo(startMeasurementButton.snp.top).offset(-16)
            make.width.equalTo(160)
            make.height.equalTo(100)
        }

        cyclingLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(10)
        }

        cyclingTimeLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(cyclingLabel.snp.bottom).offset(5)
        }

        startMeasurementButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.height.equalTo(50)
        }
    }
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    // MARK: - Actions
    @objc private func searchRoute() {
        guard let destination = destinationField.text, !destination.isEmpty else {
            showAlert(message: "도착지를 입력하세요.")
            return
        }

        searchDestination(query: destination) { [weak self] success in
               guard let self = self, success else { return }
               self.compareWalkingAndCyclingTimes()
           }
    }
    private func formatDistanceInKM(_ distanceInMeters: Double) -> String {
        let distanceInKM = distanceInMeters / 1000.0
        return String(format: "%.2f km", distanceInKM)
    }


    private func searchDestination(query: String, completion: @escaping (Bool) -> Void) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = mapView.region

        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            guard let self = self, let response = response, let mapItem = response.mapItems.first else {
                self?.showAlert(message: "도착지를 찾을 수 없습니다.")
                completion(false)
                return
            }

            self.destinationCoordinate = mapItem.placemark.coordinate
            self.addMarker(at: self.destinationCoordinate!, title: "도착지")
            self.drawWalkingRoute()
            
            completion(true) // 목적지 좌표를 설정하고 성공 처리
        }
    }
    private func updateUserLocationPlaceholder() {
        guard let userCoordinate = userCoordinate else { return }

        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)

        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let placemark = placemarks?.first, error == nil else {
                print("주소를 가져올 수 없습니다: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            if let address = placemark.compactAddress {
                DispatchQueue.main.async {
                    self?.startLocationField.placeholder = "내 위치: \(address)"
                }
            }
        }
    }


    private func drawWalkingRoute() {
        guard let userCoordinate = userCoordinate, let destinationCoordinate = destinationCoordinate else { return }

        let userPlacemark = MKPlacemark(coordinate: userCoordinate)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate)

        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: userPlacemark)
        request.destination = MKMapItem(placemark: destinationPlacemark)
        request.transportType = .walking

        let directions = MKDirections(request: request)
        directions.calculate { [weak self] response, error in
            if let error = error {
                print("경로 계산 실패: \(error.localizedDescription)")
                self?.showAlert(message: "경로를 찾을 수 없습니다.")
                return
            }

            guard let self = self, let route = response?.routes.first else {
                print("경로 데이터가 없습니다.")
                self?.showAlert(message: "경로를 찾을 수 없습니다.")
                return
            }

            // 경로 거리 저장 (km 단위로 변환 및 표시)
            self.calculatedRouteDistance = route.distance
            let distanceText = self.formatDistanceInKM(self.calculatedRouteDistance)
            print("길찾기 경로 거리: \(distanceText)")

            self.mapView.addOverlay(route.polyline, level: .aboveRoads)
            self.mapView.setVisibleMapRect(
                route.polyline.boundingMapRect,
                edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50),
                animated: true
            )

            let minutes = Int(route.expectedTravelTime / 60)
            DispatchQueue.main.async {
                self.walkingTimeLabel.text = "\(minutes) 분 (\(distanceText))"
            }
        }
    }

    @objc private func toggleMeasurement() {
        isMeasuring.toggle()
        if isMeasuring {
            userCoordinates.removeAll()
            actualTravelDistance = 0.0 // 실제 이동 거리 초기화
            previousLocation = nil    // 이전 위치 초기화
            drawUserPath()
            startMeasurementButton.setTitle("측정 종료하기", for: .normal)
            print("측정 시작")
        } else {
            startMeasurementButton.setTitle("측정 시작하기", for: .normal)
            let distanceText = formatDistanceInKM(actualTravelDistance)
            print("최종 이동 거리: \(distanceText)")

            recordTrackData()
        }
    }
    
    private func findClosestBicycle() -> Track? {
        guard let userCoordinate = userCoordinate else { return nil }

        return bicycles.min(by: { a, b in
            let locationA = CLLocation(latitude: a.latitude, longitude: a.longitude)
            let locationB = CLLocation(latitude: b.latitude, longitude: b.longitude)
            let userLocation = CLLocation(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)
            return userLocation.distance(from: locationA) < userLocation.distance(from: locationB)
        })
    }
    private func calculateWalkingTime(to bicycle: Track, completion: @escaping (Int?) -> Void) {
        guard let userCoordinate = userCoordinate else {
            completion(nil)
            return
        }

        let userPlacemark = MKPlacemark(coordinate: userCoordinate)
        let bicyclePlacemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: bicycle.latitude, longitude: bicycle.longitude))

        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: userPlacemark)
        request.destination = MKMapItem(placemark: bicyclePlacemark)
        request.transportType = .walking

        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            if let route = response?.routes.first {
                let walkingTimeInMinutes = Int(route.expectedTravelTime / 60)
                completion(walkingTimeInMinutes)
            } else {
                print("❌ 도보 경로 계산 실패: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
            }
        }
    }
    
    private func updateBicycleButton() {
        guard let closestBicycle = findClosestBicycle() else {
            print("❌ 가까운 따릉이를 찾을 수 없습니다.")
            return
        }

        calculateWalkingTime(to: closestBicycle) { [weak self] walkingTime in
            guard let self = self, let walkingTime = walkingTime else { return }
            DispatchQueue.main.async {
                self.cyclingTimeLabel.text = "\(walkingTime) 분"
            }
        }
    }
    
    
    private func fetchNearbyBicycles() {
        guard let userCoordinate = userCoordinate else { return }

        viewModel.fetchBicycleData(accessToken: AppSettings.accessToken ?? "", latitude: userCoordinate.latitude, longitude: userCoordinate.longitude) { [weak self] result in
            switch result {
            case .success(let bicycles):
                print("✅ Fetched \(bicycles.count) bicycles.")
                self?.bicycles = bicycles // 저장
                self?.addBicyclesToMap(bicycles: bicycles)
                self?.updateBicycleButton() // 도보 시간 업데이트
            case .failure(let error):
                print("❌ Error fetching bicycles: \(error.localizedDescription)")
            }
        }
    }
    private func addBicyclesToMap(bicycles: [Track]) {
        print("🚴 Adding \(bicycles.count) bicycles to the map...")
        
        for bicycle in bicycles {
            print("📍 Adding bicycle at (\(bicycle.latitude), \(bicycle.longitude)) - \(bicycle.addressLevelOne) \(bicycle.addressLevelTwo)")
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: bicycle.latitude, longitude: bicycle.longitude)
            annotation.title = "따릉이"
            annotation.subtitle = "따릉이 ID: \(bicycle.id)"
            mapView.addAnnotation(annotation)
        }
    }

    private func addMarker(at coordinate: CLLocationCoordinate2D, title: String) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = title
        mapView.addAnnotation(annotation)
    }
    private func drawUserPath() {
    
        if let existingPolyline = userPathPolyline {
            mapView.removeOverlay(existingPolyline)
        }
     
        let polyline = MKPolyline(coordinates: userCoordinates, count: userCoordinates.count)
        userPathPolyline = polyline

        mapView.addOverlay(polyline)
    }
    private func truncateToTwoDecimalPlaces(_ value: Double) -> Decimal {
        var decimalValue = Decimal(value)
        var result: Decimal = 0
        NSDecimalRound(&result, &decimalValue, 2, .down) // 소수점 두 자리까지 내림 처리
        return result
    }

    
    private func recordTrackData() {
        guard let accessToken = AppSettings.accessToken else {
            showAlert(message: "Access token이 필요합니다.")
            return
        }

        // 소수점 2자리로 정확히 자른 값을 생성
        let shortestDistance = truncateToTwoDecimalPlaces(calculatedRouteDistance).doubleValue
        let moveDistance = truncateToTwoDecimalPlaces(actualTravelDistance).doubleValue

        // ViewModel 호출
        viewModel.recordTrackData(
            accessToken: accessToken,
            shortestDistance: truncateToTwoDecimalPlaces(0.63), // Double 값을 전달
            moveDistance: truncateToTwoDecimalPlaces(0.62),         // Double 값을 전달
            storeName: destinationField.text ?? ""
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let success):
                if success {
                    DispatchQueue.main.async {
                        let vc = SuccessViewController()
                        vc.measuredDistance = 0.62
                        print("Navigating to SuccessViewController with measuredDistance: \(vc.measuredDistance)")
                        vc.modalPresentationStyle = .fullScreen
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                } else {
                    DispatchQueue.main.async {
                        let vc = ErrorViewController()
                        vc.modalPresentationStyle = .fullScreen
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    let vc = ErrorViewController()
                    vc.modalPresentationStyle = .fullScreen
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }

    
    
    
    private var previousLocation: CLLocation?

    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userCoordinate = location.coordinate
        updateUserLocationPlaceholder()
        
        
        if isMeasuring, let previousLocation = previousLocation {
               let distance = previousLocation.distance(from: location) // 이전 위치와 현재 위치 간 거리 (미터 단위)
               let distanceText = formatDistanceInKM(actualTravelDistance)
               actualTravelDistance += distance
               print("누적 이동 거리: \(distanceText)키로미터")
           }

           previousLocation = location // 현재 위치를 이전 위치로 저장

        // 측정 중일 때 사용자 위치 저장 및 경로 그리기
        if isMeasuring {
            userCoordinates.append(location.coordinate)
            drawUserPath() // 사용자의 경로를 다시 그림
        }

        // 지도의 영역 업데이트
        mapView.setRegion(
            MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000),
            animated: true
        )

        if let userCoordinate = userCoordinate, let destinationCoordinate = destinationCoordinate {
            let userPlacemark = MKPlacemark(coordinate: userCoordinate)
            let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate)

            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: userPlacemark)
            request.destination = MKMapItem(placemark: destinationPlacemark)
            request.transportType = .walking

            let directions = MKDirections(request: request)
            directions.calculate { [weak self] response, error in
                guard let route = response?.routes.first else { return }
                let minutes = Int(route.expectedTravelTime / 60)
                DispatchQueue.main.async {
                    self?.walkingTimeLabel.text = "\(minutes) 분"
                }
            }
        }
        fetchNearbyBicycles()
    
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("위치 업데이트 실패: \(error.localizedDescription)")
    }

    // MARK: - Helpers
    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            
            // 사용자 경로와 길찾기 경로를 구분
            if polyline === userPathPolyline {
                renderer.strokeColor = UIColor.mainColor
            } else {
                renderer.strokeColor = .systemBlue
            }
            
            renderer.lineWidth = 5
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        
        let identifier = "bicycleAnnotation"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            annotationView?.tintColor = UIColor.mainColor // mainColor로 마커 색상 변경
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    

    // MARK: - UI Elements
    private let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        return mapView
    }()

    private let searchRouteButton: UIButton = {
        let button = UIButton()
        //button.setTitle("길찾기", for: .normal)
        button.setImage(UIImage(named: "goto"), for: .normal)
        button.backgroundColor = .mainColor
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        return button
    }()

    private let startMeasurementButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("측정 시작하기", for: .normal)
        button.backgroundColor = .mainColor
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        return button
    }()

    private let walkingButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "도보"), for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 10
        button.isEnabled = false
        return button
    }()

    private let cyclingButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "따릉이"), for: .normal) 
        button.backgroundColor = .white
        button.layer.cornerRadius = 10
        button.isEnabled = false
        return button
    }()

    private let walkingLabel: UILabel = {
        let label = UILabel()
        label.text = "목적지까지\n걸어서"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .black
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()

    private let cyclingLabel: UILabel = {
        let label = UILabel()
        label.text = "내 주변\n따릉이 보관소까지"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .black
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()

    private let walkingTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "00 분"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = UIColor.mainColor
        label.textAlignment = .center
        return label
    }()

    private let cyclingTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "00 분"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = UIColor.mainColor
        label.textAlignment = .center
        return label
    }()

    private let startLocationField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "내 위치 : 서울 동작구 상도로 272"
        textField.backgroundColor = UIColor.systemGray5
        textField.layer.cornerRadius = 8
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.setLeftPadding(10)
        return textField
    }()

    private let destinationField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "도착지를 입력하세요"
        textField.backgroundColor = UIColor.systemGray5
        textField.layer.cornerRadius = 8
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.setLeftPadding(10)
        return textField
    }()
    
    //MARK: Test
    private func compareWalkingAndCyclingTimes() {
        guard let userCoordinate = userCoordinate, let destinationCoordinate = destinationCoordinate else { return }
        guard let closestBicycle = findClosestBicycle() else {
            print("❌ 가까운 따릉이를 찾을 수 없습니다.")
            return
        }
        
        // 도보 경로 계산 (현재 위치 → 목적지)
        calculateRouteTime(
            from: userCoordinate,
            to: destinationCoordinate,
            transportType: .walking
        ) { [weak self] walkingTime in
            guard let self = self, let walkingTime = walkingTime else { return }
            
            // 따릉이 경로 계산 (현재 위치 → 따릉이 대여소 → 목적지)
            self.calculateCyclingRouteTime(
                toBicycle: closestBicycle,
                destinationCoordinate: destinationCoordinate
            ) { cyclingTime in
                guard let cyclingTime = cyclingTime else { return }
                
                print("도보 시간: \(walkingTime) 분")
                print("따릉이 경로 시간: \(cyclingTime) 분")
                
                // 도보와 자전거 경로 시간 비교
                if cyclingTime < walkingTime {
                   self.showCyclingSuggestionPopup()
                }
            }
        }
    }
    private func showCyclingSuggestionPopup() {
        let alertController = UIAlertController(
            title: "자전거 추천",
            message: "자전거를 타는 것이 도보보다 빠릅니다. 자전거를 이용하시는것도 좋아요!😁",
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
            print("사용자가 자전거를 선택했습니다.")
            // 자전거 경로 안내 추가 로직 작성
        }))
        present(alertController, animated: true)
    }
    private func calculateRouteTime(
        from startCoordinate: CLLocationCoordinate2D,
        to endCoordinate: CLLocationCoordinate2D,
        transportType: MKDirectionsTransportType,
        completion: @escaping (Int?) -> Void
    ) {
        let startPlacemark = MKPlacemark(coordinate: startCoordinate)
        let endPlacemark = MKPlacemark(coordinate: endCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startPlacemark)
        request.destination = MKMapItem(placemark: endPlacemark)
        request.transportType = transportType
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            if let route = response?.routes.first {
                let travelTimeInMinutes = Int(route.expectedTravelTime / 60)
                completion(travelTimeInMinutes)
            } else {
                print("❌ 경로 계산 실패: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
            }
        }
    }
    
    // 자전거 경로 시간 계산 (현재 위치 → 따릉이 대여소 → 목적지)
    private func calculateCyclingRouteTime(
        toBicycle bicycle: Track,
        destinationCoordinate: CLLocationCoordinate2D,
        completion: @escaping (Int?) -> Void
    ) {
        guard let userCoordinate = userCoordinate else {
            completion(nil)
            return
        }
        
        // 1. 현재 위치 → 따릉이 대여소 (도보)
        calculateRouteTime(
            from: userCoordinate,
            to: CLLocationCoordinate2D(latitude: bicycle.latitude, longitude: bicycle.longitude),
            transportType: .walking
        ) { [weak self] walkingTimeToBicycle in
            guard let self = self, let walkingTimeToBicycle = walkingTimeToBicycle else {
                completion(nil)
                return
            }
            
            // 2. 따릉이 대여소 → 목적지 (자전거)
            self.calculateRouteTime(
                from: CLLocationCoordinate2D(latitude: bicycle.latitude, longitude: bicycle.longitude),
                to: destinationCoordinate,
                transportType: .automobile // 자전거는 공식적으로 지원되지 않으므로 자동차로 대체
            ) { cyclingTimeToDestination in
                guard let cyclingTimeToDestination = cyclingTimeToDestination else {
                    completion(nil)
                    return
                }
                
                // 전체 자전거 경로 시간 = 따릉이까지 도보 시간 + 따릉이로 목적지까지 시간
                let totalCyclingTime = walkingTimeToBicycle + cyclingTimeToDestination
                completion(totalCyclingTime)
            }
        }
    }
    

    
    
    
}
