//
//  LocationService.swift
//  Dosirak
//
//  Created by 권민재 on 10/30/24.
//

import Foundation
import CoreLocation
import RxSwift
import RxCocoa

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    private let addressSubject = PublishSubject<String>() // 주소 정보를 발행할 Subject
    
    override private init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // 주소 Observable
    var address: Observable<String> {
        return addressSubject.asObservable()
    }
    
    // 위치 업데이트 요청 (버튼 클릭 시 호출)
    func requestLocationUpdate() {
        guard CLLocationManager.locationServicesEnabled() else {
            print("위치 서비스가 비활성화되었습니다.")
            return
        }
        
        if #available(iOS 14.0, *) {
            // iOS 14 이상에서는 locationManager의 authorizationStatus 사용
            switch locationManager.authorizationStatus {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .authorizedWhenInUse, .authorizedAlways:
                checkLocationAccuracy()
            case .denied, .restricted:
                print("위치 권한이 거부되었습니다. 설정에서 권한을 활성화해주세요.")
            @unknown default:
                break
            }
        } else {
            // iOS 13 이하에서는 CLLocationManager의 클래스 메서드 사용
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .authorizedWhenInUse, .authorizedAlways:
                checkLocationAccuracy()
            case .denied, .restricted:
                print("위치 권한이 거부되었습니다. 설정에서 권한을 활성화해주세요.")
            @unknown default:
                break
            }
        }
    }
    
    // 권한 상태 변경 시 호출되는 콜백
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            checkLocationAccuracy() // 권한이 허용되면 위치 업데이트 시작
        case .denied, .restricted:
            print("위치 권한이 거부되었습니다. 설정에서 권한을 활성화해주세요.")
        case .notDetermined:
            print("위치 권한 요청 중입니다.")
        @unknown default:
            break
        }
    }
    
    // 권한이 허용되었는지 및 정확한 위치 권한 여부 확인 후 위치 업데이트 시작
    private func checkLocationAccuracy() {
        if #available(iOS 14.0, *), locationManager.accuracyAuthorization == .reducedAccuracy {
            print("정확한 위치 권한이 거부됨. 대략적인 위치로만 업데이트합니다.")
            locationManager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "PreciseLocation") { [weak self] _ in
                self?.locationManager.startUpdatingLocation()
            }
        } else {
            locationManager.startUpdatingLocation() // 정확한 위치 권한이 있거나 iOS 14 미만에서는 그대로 시작
        }
    }
    
    // CLLocationManagerDelegate - 위치 업데이트 성공
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        geocodeLocation(location)
        locationManager.stopUpdatingLocation() // 일회성 위치 업데이트 후 멈춤
    }
    
    // 위치 업데이트 실패
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("위치 업데이트 실패: \(error.localizedDescription)")
    }
    
    // 역지오코딩으로 위경도를 주소로 변환
    private func geocodeLocation(_ location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            if let error = error {
                print("역지오코딩 실패: \(error.localizedDescription)")
                return
            }
            
            guard let placemark = placemarks?.first,
                  let locality = placemark.locality,
                  let subLocality = placemark.subLocality
            else {
                return
            }
            
            let address = "\(locality) \(subLocality)"
            self?.addressSubject.onNext(address)
        }
    }
}
