//
//  LoginCoordinator.swift
//  Dosirak
//
//  Created by 권민재 on 10/17/24.
//

import UIKit


import UIKit

class LoginCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController // UINavigationController를 변수로 정의
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start(window: UIWindow) {
        // 앱의 윈도우를 설정하고 루트 뷰 컨트롤러로 내비게이션 컨트롤러를 설정
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        // 로그인 화면을 표시
        start()
    }
    
    func start() {
        // LoginReactor를 초기화하여 LoginViewController에 주입
        let loginReactor = LoginReactor(loginManager: LoginManager.shared) // LoginReactor의 초기화
        let loginVC = LoginViewController(reactor: loginReactor)
        navigationController.pushViewController(loginVC, animated: true)
    }
}
