//
//  AppCoordinator.swift
//  Dosirak
//
//  Created by 권민재 on 10/17/24.
//
import UIKit
import Moya
import RxSwift
import CoreLocation

struct AppSettings {
    @UserDefault(key: "accessToken", defaultValue: nil)
    static var accessToken: String?
    
    @UserDefault(key: "refreshToken", defaultValue: nil)
    static var refreshToken: String?
    
    @UserDefault(key: "isLoggedIn", defaultValue: false)
    static var isLoggedIn: Bool
    
}
protocol Coordinator {
    var childCoordinators: [Coordinator] { get set }
}

protocol AppCoordinatorBindable {
    func moveLogin(window: UIWindow)
    func moveHome(window: UIWindow)
}

class AppCoordinator: Coordinator, AppCoordinatorBindable {
  
    

    private let provider = MoyaProvider<UserAPI>()
    private let disposeBag = DisposeBag()

    var childCoordinators: [Coordinator] = []

  
    let locationManager = CLLocationManager()
    let geocoder = CLGeocoder()

    func start(window: UIWindow) {
//        window.rootViewController = UINavigationController(rootViewController: EditNickNameViewController())
        let tabBarController = TabbarViewController()
        let tabBarCoordinator = TabBarCoordinator(tabBarController: tabBarController)
        childCoordinators.append(tabBarCoordinator)
        
        // TabBarCoordinator 시작
        tabBarCoordinator.start()
        
        // TabBarController를 윈도우의 rootViewController로 설정
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        
    }

    private func validateAccessToken(_ accessToken: String, refreshToken: String, window: UIWindow) {
        provider.rx.request(.isValidToken(accessToken: accessToken))
            .map { response -> Bool in
                response.statusCode == 200
            }
            .subscribe(onSuccess: { [weak self] isValid in
                if isValid {
                    print("토큰 유효: 홈 유지")
                } else {
                    print("토큰 만료: 재발급 시도")
                    self?.reissueAccessToken(refreshToken: refreshToken, window: window)
                }
            }, onFailure: { [weak self] _ in
                print("토큰 검증 실패: 재발급 시도")
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
                    print("토큰 재발급 성공")
                    AppSettings.accessToken = token
                } else {
                    print("토큰 재발급 실패: 로그인 필요")
                    self?.clearTokensAndMoveToLogin(window: window)
                }
            }, onFailure: { [weak self] _ in
                print("토큰 재발급 요청 실패: 로그인 필요")
                self?.clearTokensAndMoveToLogin(window: window)
            })
            .disposed(by: disposeBag)
    }

    private func clearTokensAndMoveToLogin(window: UIWindow) {
        AppSettings.accessToken = nil
        AppSettings.refreshToken = nil
        moveLogin(window: window)
    }

    func moveLogin(window: UIWindow) {
        let loginVC = LoginViewController()
        let navigationController = UINavigationController(rootViewController: loginVC)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }

    func moveHome(window: UIWindow) {
        let homeVC = HomeViewController()
        let navigationController = UINavigationController(rootViewController: homeVC)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}
