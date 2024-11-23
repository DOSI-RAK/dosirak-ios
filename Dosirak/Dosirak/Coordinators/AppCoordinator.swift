//
//  AppCoordinator.swift
//  Dosirak
//
//  Created by 권민재 on 10/17/24.
//
import UIKit
import Moya
import RxMoya
import RxSwift
import CoreLocation

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
        
//        let vc = UINavigationController(rootViewController: GreenTrackViewController()
//                                        )
//        window.rootViewController = vc
//        window.makeKeyAndVisible()
        
        if !AppSettings.isFitstLaunch {
            moveOnboarding(window: window)
        } else {
            
            guard let accessToken = AppSettings.accessToken,
                  let refreshToken = AppSettings.refreshToken else {
                // 토큰이 없으면 로그인 화면으로 이동
                moveLogin(window: window)
                return
            }
            
            // 액세스 토큰 유효성 검사
            validateAccessToken(accessToken, refreshToken: refreshToken, window: window)
        }
    }

    private func validateAccessToken(_ accessToken: String, refreshToken: String, window: UIWindow) {
        provider.rx.request(.isValidToken(accessToken: accessToken))
            .map { response -> Bool in
                response.statusCode == 200
            }
            .subscribe(onSuccess: { [weak self] isValid in
                if isValid {
                    print("토큰 유효: 홈 화면으로 이동")
                    self?.moveHome(window: window)
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
                    self?.moveHome(window: window)
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
    
    func moveOnboarding(window: UIWindow) {
        let onboardingVC = OnboardingViewController()
        window.rootViewController = onboardingVC
        window.makeKeyAndVisible()
    }
    
    

    func moveLogin(window: UIWindow) {
        let loginVC = LoginViewController()
        let navigationController = UINavigationController(rootViewController: loginVC)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }

    func moveHome(window: UIWindow) {
        let tabBarController = TabbarViewController()
        let tabBarCoordinator = TabBarCoordinator(tabBarController: tabBarController)
        childCoordinators.append(tabBarCoordinator)

        // TabBarCoordinator 시작
        tabBarCoordinator.start()

        // TabBarController를 윈도우의 rootViewController로 설정
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
}
