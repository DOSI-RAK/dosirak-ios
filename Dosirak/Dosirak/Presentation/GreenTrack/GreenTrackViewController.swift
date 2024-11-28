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


class GreenTrackViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    private let locationManager = CLLocationManager()
    private var userCoordinate: CLLocationCoordinate2D?
    private var destinationCoordinate: CLLocationCoordinate2D?
    private var userCoordinates: [CLLocationCoordinate2D] = []
    private var userPathPolyline: MKPolyline?
    private var isMeasuring: Bool = false
    
    //MARK: ViewModel
    private let viewModel = GreenTrackViewModel()
    
    private var calculatedRouteDistance: Double = 0.0
    private var actualTravelDistance: Double = 0.0
    
    
    
    
    
    

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Green Track"
        setupUI()
        setupLayout()
        setupLocationManager()
        mapView.delegate = self
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

        searchDestination(query: destination)
    }


    private func searchDestination(query: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = mapView.region

        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            guard let self = self, let response = response, let mapItem = response.mapItems.first else {
                self?.showAlert(message: "도착지를 찾을 수 없습니다.")
                return
            }

            self.destinationCoordinate = mapItem.placemark.coordinate
            self.addMarker(at: self.destinationCoordinate!, title: "도착지")
            self.drawWalkingRoute()
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

            // 경로 거리 저장
            self.calculatedRouteDistance = route.distance
            print("길찾기 경로 거리: \(self.calculatedRouteDistance) 미터")
        
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)
            self.mapView.setVisibleMapRect(
                route.polyline.boundingMapRect,
                edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50),
                animated: true
            )

            let minutes = Int(route.expectedTravelTime / 60)
            DispatchQueue.main.async {
                self.walkingTimeLabel.text = "\(minutes) 분"
            }
        }
    }
    @objc private func toggleMeasurement() {
        isMeasuring.toggle()
        if isMeasuring {
            // 트래킹 시작
            userCoordinates.removeAll()
            actualTravelDistance = 0.0 // 실제 이동 거리 초기화
            previousLocation = nil    // 이전 위치 초기화
            drawUserPath()
            startMeasurementButton.setTitle("측정 종료하기", for: .normal)
            print("측정 시작")
        } else {
            // 트래킹 종료
            startMeasurementButton.setTitle("측정 시작하기", for: .normal)
            print("최종 이동 거리: \(actualTravelDistance) 미터")

            let vc = SuccessViewController()
            vc.navigationController?.navigationBar.isHidden = true
            navigationController?.pushViewController(vc, animated: true)
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
    
    private var previousLocation: CLLocation?

    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userCoordinate = location.coordinate
        
        
        if isMeasuring, let previousLocation = previousLocation {
               let distance = previousLocation.distance(from: location) // 이전 위치와 현재 위치 간 거리 (미터 단위)
               actualTravelDistance += distance
               print("누적 이동 거리: \(actualTravelDistance) 미터")
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
        label.textColor = UIColor.systemGreen
        label.textAlignment = .center
        return label
    }()

    private let cyclingTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "00 분"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = UIColor.systemGreen
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
        textField.placeholder = "도착지"
        textField.backgroundColor = UIColor.systemGray5
        textField.layer.cornerRadius = 8
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.setLeftPadding(10)
        return textField
    }()
}
