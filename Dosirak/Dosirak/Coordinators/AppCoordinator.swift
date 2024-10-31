//
//  AppCoordinator.swift
//  Dosirak
//
//  Created by 권민재 on 10/17/24.
//
import UIKit
import KeychainAccess
import Moya
import RxSwift
import CoreLocation

protocol Coordinator {
    var childCoordinators: [Coordinator] { get set }
    func start()
}

protocol AppCoordinatorBindable {
    func moveOnboarding()
    func moveLogin(window: UIWindow)
    func moveHome(window: UIWindow)
}

class AppCoordinator: Coordinator, AppCoordinatorBindable {
    
  
    private let keychain = Keychain(service: "com.dosirak.user")
    private let provider = MoyaProvider<UserAPI>()
    private let disposeBag = DisposeBag()
    let locationManager = CLLocationManager()
    let geocoder = CLGeocoder()
   
    func start() {
        print("Hello")
    }
    
    
    var childCoordinators: [Coordinator] = []
    
    func start(window: UIWindow) {
            // Keychain에서 accessToken과 refreshToken 가져오기
            guard let accessToken = keychain["accessToken"],
                  let refreshToken = keychain["refreshToken"] else {
                // 토큰이 없으면 로그인 화면으로 이동
                moveLogin(window: window)
                return
            }
            // 액세스 토큰 유효성 검사
            validateAccessToken(accessToken, refreshToken: refreshToken, window: window)
        }
        
        private func validateAccessToken(_ accessToken: String, refreshToken: String, window: UIWindow) {
            provider.rx.request(.isValidToken(accessToken: accessToken))
                .map { response -> Bool in
                    // 응답 코드가 200이면 토큰이 유효함을 의미
                    return response.statusCode == 200
                }
                .subscribe(onSuccess: { [weak self] isValid in
                    if isValid {
                        // 토큰이 유효한 경우 홈 화면으로 이동
                        self?.moveHome(window: window)
                    } else {
                        // 토큰이 유효하지 않으면 리프레시 토큰으로 액세스 토큰 재발급 시도
                        self?.reissueAccessToken(refreshToken: refreshToken, window: window)
                    }
                }, onFailure: { [weak self] _ in
                    // 에러가 발생하면 리프레시 토큰으로 재발급 시도
                    self?.reissueAccessToken(refreshToken: refreshToken, window: window)
                })
                .disposed(by: disposeBag)
        }
        
        private func reissueAccessToken(refreshToken: String, window: UIWindow) {
            provider.rx.request(.reissueToken(refreshToken: refreshToken))
                .map { response -> String? in
                    guard response.statusCode == 200,
                          let data = try? response.mapJSON() as? [String: Any],
                          let newAccessToken = (data["data"] as? [String: Any])?["accessToken"] as? String else {
                        return nil
                    }
                    return newAccessToken
                }
                .subscribe(onSuccess: { [weak self] newAccessToken in
                    if let token = newAccessToken {
                        // 새로운 액세스 토큰을 Keychain에 저장하고 홈 화면으로 이동
                        self?.keychain["accessToken"] = token
                        self?.moveHome(window: window)
                    } else {
                        // 재발급 실패 시 모든 토큰 삭제 후 로그인 화면으로 이동
                        self?.clearTokensAndMoveToLogin(window: window)
                    }
                }, onFailure: { [weak self] _ in
                    // 요청 실패 시 모든 토큰 삭제 후 로그인 화면으로 이동
                    self?.clearTokensAndMoveToLogin(window: window)
                })
                .disposed(by: disposeBag)
        }
        
        private func clearTokensAndMoveToLogin(window: UIWindow) {
            // Keychain에서 모든 토큰 삭제
            try? keychain.remove("accessToken")
            try? keychain.remove("refreshToken")
            
            // 로그인 화면으로 이동
            moveLogin(window: window)
        }
    
    private func isFirstLaunch() -> Bool {
        let userDefaults = UserDefaults.standard
        let isOnboardingShown = userDefaults.bool(forKey: "isOnboardingShown")
        return !isOnboardingShown
    }
    
    private func setupOnboardingComplete() {
        let userDefaults = UserDefaults.standard
        userDefaults.set(true, forKey: "isOnboardingShown")
        userDefaults.synchronize()
    }
    
    func moveOnboarding() {
        let onboardingCoordinator = OnboardingCoordinator()
        childCoordinators.append(onboardingCoordinator)
        onboardingCoordinator.start()
        
        onboardingCoordinator.onboardingDidFinish = { [weak self] in
            self?.setupOnboardingComplete()
            self?.childCoordinators.removeAll()
            //self?.moveLogin()
        }
    }
    
    func moveLogin(window: UIWindow) {
        guard let reactor = DIContainer.shared.resolve(LoginReactor.self) else {
            fatalError("LoginReactor cannot be resolved")
        }
        
        let loginVC = LoginViewController(reactor: reactor)
        window.rootViewController = loginVC
    }
    
    func moveHome(window: UIWindow) {
        let tabbarVC = TabbarViewController()
        
        // Home 탭에 대한 Coordinator
        let homeCoordinator = HomeCoordinator()
        childCoordinators.append(homeCoordinator)
        homeCoordinator.start()
        let homeNavController = homeCoordinator.nav
        homeNavController.tabBarItem = UITabBarItem(title: "홈", image: UIImage(named: "home"),selectedImage: UIImage(named: "home_active"))

        let communityCoordinator = CommuityCoordinator()
        childCoordinators.append(communityCoordinator)
        
        let communityNavController = communityCoordinator.nav
        communityNavController.tabBarItem = UITabBarItem(title: "커뮤니티", image: UIImage(named: "activities"),selectedImage: UIImage(named: "activities_active"))
        
        let profileCoordinator = UserProfileCoordinator()
        childCoordinators.append(profileCoordinator)
        profileCoordinator.start()
        
        let profileNavController = profileCoordinator.nav
        profileNavController.tabBarItem = UITabBarItem(title: "내정보", image: UIImage(named: "person"),selectedImage: UIImage(named: "person_active"))
        
        
        tabbarVC.viewControllers = [homeNavController,communityNavController,profileNavController]
        
        
        
        
        
        window.rootViewController = tabbarVC
        window.makeKeyAndVisible()
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            // 권한이 승인되면 위치 업데이트 시작
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            print("위치 정보 사용이 거부되었습니다.")
        case .notDetermined:
            print("위치 권한이 아직 설정되지 않았습니다.")
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let placemark = placemarks?.first, error == nil else {
                print("Failed to get address: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            if let gu = placemark.locality, let dong = placemark.subLocality {
                let guDong = "\(gu) \(dong)"
                
                let userDefaults = UserDefaults.standard
                userDefaults.set(guDong, forKey: "userGuDong")
                userDefaults.synchronize()
                
                print("GuDong saved: \(guDong)")
            } else {
                print("Address components not available")
            }
            
            self?.locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to fetch location: \(error.localizedDescription)")
    }
    
}

