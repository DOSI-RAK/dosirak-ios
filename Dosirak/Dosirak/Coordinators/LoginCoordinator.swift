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
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        // 로그인 화면을 표시
        start()
    }
    
    func start()  {
        
        
    }
}
