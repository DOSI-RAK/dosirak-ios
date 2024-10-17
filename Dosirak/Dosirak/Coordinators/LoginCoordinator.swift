//
//  LoginCoordinator.swift
//  Dosirak
//
//  Created by 권민재 on 10/17/24.
//

import UIKit


class LoginCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    
    var nav: UINavigationController
    
    
    init(nav: UINavigationController) {
        self.nav = nav
    }
    
    
    func start() {
        let loginVC = LoginViewController()
        nav.pushViewController(loginVC, animated: true)
    }
    
    
}
