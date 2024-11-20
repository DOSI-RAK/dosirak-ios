//
//  GreenTrackViewController.swift
//  Dosirak
//
//  Created by 권민재 on 11/18/24.
//

import UIKit
import NMapsMap
import SnapKit
import CoreLocation

class GreenTrackViewController: UIViewController {

    // MARK: - UI Elements
    private let mapView: NMFMapView = {
        let mapView = NMFMapView()
        return mapView
    }()

    private let findRouteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("강남역 -> 메가박스 길찾기", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        return button
    }()

    private let naverClientID = "kq6strtnog"
    private let naverClientSecret = "YCRg2zlEe3pjeHXTOpNdTVqxLv3oDOmjzYywbPji"

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Green Track"
        setupUI()

        findRouteButton.addTarget(self, action: #selector(findRoute), for: .touchUpInside)
    }

    // MARK: - Setup UI
    private func setupUI() {
        view.addSubview(mapView)
        view.addSubview(findRouteButton)

        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        findRouteButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.height.equalTo(50)
        }
    }

    // MARK: - 길찾기 실행
    @objc private func findRoute() {
           let startLat = 37.501347
           let startLng = 127.026230

           // 도착지: 서초초등학교
           let endLat = 37.494636
           let endLng = 127.014263

        addMarker(at: CLLocationCoordinate2D(latitude: startLat, longitude: startLng), title: "강남역")
        addMarker(at: CLLocationCoordinate2D(latitude: endLat, longitude: endLng), title: "강남 메가박스")

        requestRoute(startLat: startLat, startLng: startLng, endLat: endLat, endLng: endLng)
    }

    private func requestRoute(startLat: Double, startLng: Double, endLat: Double, endLng: Double) {
        let urlString = "https://naveropenapi.apigw.ntruss.com/map-direction/v1/driving?start=\(startLng),\(startLat)&goal=\(endLng),\(endLat)&option=pedestrian"
        guard let url = URL(string: urlString) else {
            print("잘못된 URL입니다.")
            return
        }

        var request = URLRequest(url: url)
        request.addValue(naverClientID, forHTTPHeaderField: "X-NCP-APIGW-API-KEY-ID")
        request.addValue(naverClientSecret, forHTTPHeaderField: "X-NCP-APIGW-API-KEY")

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }

            if let error = error {
                print("네트워크 오류: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showAlert(message: "네트워크 요청 중 오류가 발생했습니다.")
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("응답 상태 코드: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    DispatchQueue.main.async {
                        self.showAlert(message: "API 호출 실패: 상태 코드 \(httpResponse.statusCode)")
                    }
                    return
                }
            }

            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("응답 데이터:\n\(dataString)")
            }

            do {
                guard let data = data else {
                    print("응답 데이터가 비어 있습니다.")
                    DispatchQueue.main.async {
                        self.showAlert(message: "응답 데이터를 가져올 수 없습니다.")
                    }
                    return
                }

                let result = try JSONDecoder().decode(DirectionsResponse.self, from: data)
                print("디코딩된 데이터:\n\(result)")

                // trafast 경로 사용
                if let route = result.route?.traoptimal?.first {
                    DispatchQueue.main.async {
                        self.drawRoute(path: route.path) // 경로 그리기
                    }
                } else {
                    print("trafast 경로 데이터가 없습니다.")
                    DispatchQueue.main.async {
                        self.showAlert(message: "경로를 찾을 수 없습니다.")
                    }
                }
            } catch {
                print("디코딩 오류: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showAlert(message: "경로 데이터를 처리하는 중 오류가 발생했습니다.")
                }
            }
        }
        task.resume()
    }

    private func drawRoute(path: [[Double]]) {
        print("경로 데이터 전달 성공: \(path.count)개의 점")

        // 좌표 데이터를 NMGLatLng 배열로 변환
        let points = path.map { NMGLatLng(lat: $0[1], lng: $0[0]) }
        print("좌표 변환 완료: \(points.count)개의 좌표")

        // Polyline 생성
        let polyline = NMFPolylineOverlay(points)
        polyline?.color = UIColor.mainColor // 경로 색상
        polyline?.width = 5 // 경로 두께
        polyline?.mapView = mapView // 지도에 추가
        print("Polyline 경로 추가 완료")

        // 경로에 맞춰 카메라 이동
        moveCameraToFitPath(points: points)
    }
    private func moveCameraToFitPath(points: [NMGLatLng]) {
        guard !points.isEmpty else {
            print("경로 데이터가 비어 있습니다.")
            return
        }

        // 경로의 좌표 중 최소/최대 경도와 위도를 계산
        let lats = points.map { $0.lat }
        let lngs = points.map { $0.lng }

        let southWest = NMGLatLng(lat: lats.min()!, lng: lngs.min()!) // 좌측 하단 (최소값)
        let northEast = NMGLatLng(lat: lats.max()!, lng: lngs.max()!) // 우측 상단 (최대값)

        // 경로를 포함하는 NMFBound 생성
        let bounds = NMGLatLngBounds(southWest: southWest, northEast: northEast)

        // 카메라를 경로 범위에 맞게 이동
        let cameraUpdate = NMFCameraUpdate(fit: bounds, padding: 50) // 경로와 가장자리 간격 50
        cameraUpdate.animation = .easeIn // 애니메이션 설정
        mapView.moveCamera(cameraUpdate)

        print("카메라 이동 완료: \(southWest) ~ \(northEast)")
    }
    private func addMarker(at coordinate: CLLocationCoordinate2D, title: String) {
        let marker = NMFMarker(position: NMGLatLng(lat: coordinate.latitude, lng: coordinate.longitude))
        marker.captionText = title
        marker.mapView = mapView
    }

    // MARK: - Helpers
    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Models
struct DirectionsResponse: Decodable {
    let route: RouteResponse?
}

struct RouteResponse: Decodable {
    let trafast: [Route]?
    let traoptimal: [Route]? // traoptimal 필드 추가
}

struct Route: Decodable {
    let path: [[Double]]
    let summary: Summary?
}

struct Summary: Decodable {
    let distance: Int
    let duration: Int
}
