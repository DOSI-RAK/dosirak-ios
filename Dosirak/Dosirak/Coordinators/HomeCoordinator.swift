//
//  HomeCoordinator.swift
//  Dosirak
//
//  Created by 권민재 on 10/17/24.
//

import UIKit

class HomeCoordinator: Coordinator {
    var childCoordinators: [any Coordinator] = []
    
    var nav: UINavigationController
    
    init(nav: UINavigationController) {
        self.nav = nav
    }
    
    func start() {
        let homeVC = HomeViewController()
        nav.pushViewController(homeVC, animated: true)
    }
    
    
}
