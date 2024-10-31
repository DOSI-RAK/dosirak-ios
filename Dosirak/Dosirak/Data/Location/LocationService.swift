//
//  LocationService.swift
//  Dosirak
//
//  Created by 권민재 on 10/30/24.
//

import Foundation
import CoreLocation

class LocationService: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    var didUpdateLocation: ((String?, String?) -> Void)?
    var didFailWithError: ((Error) -> Void)?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // 위치 권한 요청
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    // 위치 업데이트 시작
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    // 특정 위도와 경도로부터 구/동 정보 가져오기
    func getDistrictAndDong(from latitude: CLLocationDegrees, longitude: CLLocationDegrees, completion: @escaping (String?, String?) -> Void) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("역지오코딩 실패: \(error.localizedDescription)")
                completion(nil, nil)
                return
            }
            
            guard let placemark = placemarks?.first else {
                print("위치 정보 없음")
                completion(nil, nil)
                return
            }
            
            // 구와 동 정보 추출
            let gu = placemark.locality // 구 정보
            let dong = placemark.subLocality // 동 정보
            
            completion(gu, dong)
        }
    }
    
    // CLLocationManagerDelegate - 위치 업데이트 시 호출
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // 위치가 업데이트되면 역지오코딩 수행
        getDistrictAndDong(from: location.coordinate.latitude, longitude: location.coordinate.longitude) { [weak self] gu, dong in
            self?.didUpdateLocation?(gu, dong)
        }
        
        // 위치 업데이트 멈춤 (필요 시 계속 업데이트 가능)
        locationManager.stopUpdatingLocation()
    }
    
    // CLLocationManagerDelegate - 위치 업데이트 실패 시 호출
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("사용자의 위치를 가져오지 못했습니다: \(error.localizedDescription)")
        didFailWithError?(error)
    }
}
