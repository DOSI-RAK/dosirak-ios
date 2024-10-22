//
//  LoginCoordinator.swift
//  Dosirak
//
//  Created by 권민재 on 10/17/24.
//

import UIKit


class LoginCoordinator: Coordinator {
    func start(window: UIWindow) {
        print("Hello")
    }
    
    var childCoordinators: [Coordinator] = []
    let nav = UINavigationController()
    
    func start() {
        let loginVC = LoginViewController()
        nav.pushViewController(loginVC, animated: true)
    }
    
    
}
