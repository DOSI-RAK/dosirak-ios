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
    func moveLogin(window: UIWindow)
    func moveHome(window: UIWindow)
}

import UIKit
import KeychainAccess
import Moya
import RxSwift
import CoreLocation

class AppCoordinator: Coordinator, AppCoordinatorBindable {
    
    private let keychain = Keychain(service: "com.dosirak.user")
    private let provider = MoyaProvider<UserAPI>()
    private let disposeBag = DisposeBag()
    let locationManager = CLLocationManager()
    let geocoder = CLGeocoder()
    var childCoordinators: [Coordinator] = []
    
    func start() {
        print("Hello")
    }
    
    func start(window: UIWindow) {
        //moveHome(window: window)
        guard let accessToken = keychain["accessToken"],
              let refreshToken = keychain["refreshToken"]
              //let nickname = keychain["nickname"]
        else {
            moveLogin(window: window)
            print("로그인 시작")
            return
        }
        validateAccessToken(accessToken, refreshToken: refreshToken, window: window)
//        window.rootViewController = UserInfoSettingViewController()
        
    }
    
    private func validateAccessToken(_ accessToken: String, refreshToken: String, window: UIWindow) {
        provider.rx.request(.isValidToken(accessToken: accessToken))
            .map { response -> Bool in response.statusCode == 200 }
            .subscribe(onSuccess: { [weak self] isValid in
                if isValid {
                    self?.moveHome(window: window)
                } else {
                    self?.reissueAccessToken(refreshToken: refreshToken, window: window)
                }
            }, onFailure: { [weak self] _ in
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
                    self?.keychain["accessToken"] = token
                    self?.moveHome(window: window)
                } else {
                    self?.clearTokensAndMoveToLogin(window: window)
                }
            }, onFailure: { [weak self] _ in
                self?.clearTokensAndMoveToLogin(window: window)
            })
            .disposed(by: disposeBag)
    }
    
    private func clearTokensAndMoveToLogin(window: UIWindow) {
        try? keychain.remove("accessToken")
        try? keychain.remove("refreshToken")
        moveLogin(window: window)
    }
    
    func moveLogin(window: UIWindow) {
        guard let reactor = DIContainer.shared.resolve(LoginReactor.self) else {
            fatalError("LoginReactor cannot be resolved")
        }
        
        let loginVC = WhiteLoginViewController(reactor: reactor, appCoordinator: self)
        window.rootViewController = loginVC
        window.makeKeyAndVisible()
        
    }
    
    func moveHome(window: UIWindow) {
        let tabBarController = TabbarViewController()
        let tabBarCoordinator = TabBarCoordinator(tabBarController: tabBarController)
        childCoordinators.append(tabBarCoordinator)
        tabBarCoordinator.start()
        
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
}
